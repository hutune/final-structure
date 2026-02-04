package auth

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/common/errors"
	authdto "rmn-backend/services/auth-service/internal/dto/auth"
	authmodels "rmn-backend/services/auth-service/internal/models/auth"
)

type AuthService struct {
	app *common.App
}

func NewAuthService(app *common.App) *AuthService {
	return &AuthService{
		app: app,
	}
}

// RegisterEmail creates a new user account with email verification
func (s *AuthService) RegisterEmail(ctx context.Context, req *authdto.RegisterEmailReq) (*authdto.LoginResp, error) {
	// Check if user already exists
	var existingAccount authmodels.Account
	err := s.app.DB.Where("email = ?", req.Email).First(&existingAccount).Error
	if err == nil {
		return nil, errors.ErrAlreadyExists
	}
	if err != gorm.ErrRecordNotFound {
		return nil, err
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// Create user account
	userID := uuid.New()
	account := authmodels.Account{
		UserID:   userID,
		Email:    req.Email,
		Password: string(hashedPassword),
		AuthType: authmodels.AuthTypeCredential,
		Status:   authmodels.AccountStatusUnverified,
	}

	err = s.app.DB.Create(&account).Error
	if err != nil {
		return nil, err
	}

	// Generate email verification token
	verificationToken, err := s.generateEmailVerificationToken(userID, req.Email)
	if err != nil {
		return nil, err
	}

	// TODO(ISSUE-001): Implement email sending service
	// Store verification token in Redis for later verification
	verifyKey := fmt.Sprintf("email_verify:%s", userID.String())
	if err := s.app.Redis.Set(ctx, verifyKey, verificationToken, 24*time.Hour); err != nil {
		// Log error but don't fail registration
		_ = err
	}

	// Return registration response WITHOUT tokens
	// User must verify email before getting access tokens
	return &authdto.LoginResp{
		UserID:          userID,
		Email:           req.Email,
		IsSuperAdmin:    false,
		EmailVerified:   false,
		VerificationMsg: "Please check your email to verify your account before logging in",
	}, nil
}

// LoginEmail authenticates user with email and password
func (s *AuthService) LoginEmail(ctx context.Context, req *authdto.LoginEmailReq) (*authdto.LoginResp, error) {
	var account authmodels.Account
	err := s.app.DB.Where("email = ? AND auth_type = ?", req.Email, authmodels.AuthTypeCredential).First(&account).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, errors.ErrNotFound
		}
		return nil, err
	}

	// Check account status
	if account.Status != authmodels.AccountStatusActive {
		return nil, errors.ErrUnauthorized
	}

	// Verify password
	err = bcrypt.CompareHashAndPassword([]byte(account.Password), []byte(req.Password))
	if err != nil {
		return nil, errors.ErrUnauthorized
	}

	// Generate tokens
	return s.generateTokens(account.UserID, account.Email, false)
}

// RefreshToken generates new access and refresh tokens
func (s *AuthService) RefreshToken(ctx context.Context, req *authdto.RefreshTokenReq) (*authdto.RefreshTokenResp, error) {
	// Validate refresh token and get session
	var session authmodels.Session
	err := s.app.DB.Where("refresh_token = ? AND revoked_at IS NULL AND expired_at > ?",
		req.RefreshToken, time.Now()).First(&session).Error
	if err != nil {
		return nil, errors.ErrUnauthorized
	}

	// Check if session is expired
	if time.Now().After(session.ExpiredAt) {
		return nil, errors.ErrTokenExpired
	}

	// Get user account
	var account authmodels.Account
	err = s.app.DB.Where("user_id = ?", session.UserID).First(&account).Error
	if err != nil {
		return nil, err
	}

	// Revoke old session
	session.RevokedAt = &[]time.Time{time.Now()}[0]
	err = s.app.DB.Save(&session).Error
	if err != nil {
		return nil, err
	}

	// Generate new tokens
	tokens, err := s.generateTokens(session.UserID, account.Email, session.IsSuperAdmin)
	if err != nil {
		return nil, err
	}

	return &authdto.RefreshTokenResp{
		AccessToken:  tokens.AccessToken,
		RefreshToken: tokens.RefreshToken,
		TokenType:    tokens.TokenType,
		ExpiresIn:    tokens.ExpiresIn,
	}, nil
}

// Logout revokes the refresh token and session
func (s *AuthService) Logout(ctx context.Context, req *authdto.LogoutReq) error {
	err := s.app.DB.Model(&authmodels.Session{}).Where("refresh_token = ?", req.RefreshToken).
		Update("revoked_at", time.Now()).Error
	if err != nil {
		return err
	}

	return nil
}

// ChangePassword changes user password
func (s *AuthService) ChangePassword(ctx context.Context, userID uuid.UUID, req *authdto.ChangePasswordReq) error {
	var account authmodels.Account
	err := s.app.DB.Where("user_id = ?", userID).First(&account).Error
	if err != nil {
		return err
	}

	// Verify old password
	err = bcrypt.CompareHashAndPassword([]byte(account.Password), []byte(req.OldPassword))
	if err != nil {
		return errors.ErrUnauthorized
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	// Update password
	account.Password = string(hashedPassword)
	err = s.app.DB.Save(&account).Error
	if err != nil {
		return err
	}

	return nil
}

// generateTokens creates JWT access token and PASETO refresh token
func (s *AuthService) generateTokens(userID uuid.UUID, email string, isSuperAdmin bool) (*authdto.LoginResp, error) {
	// Generate JWT access token
	accessToken, expiresIn, err := s.generateJWT(userID, email, isSuperAdmin)
	if err != nil {
		return nil, err
	}

	// Generate refresh token
	refreshToken, err := s.generateRefreshToken()
	if err != nil {
		return nil, err
	}

	// Create session
	session := authmodels.Session{
		UserID:       userID,
		RefreshToken: refreshToken,
		ExpiredAt:    time.Now().Add(time.Duration(s.app.Cfg.Token.RefreshTokenExpirationTime) * time.Second),
		IsSuperAdmin: isSuperAdmin,
	}

	err = s.app.DB.Create(&session).Error
	if err != nil {
		return nil, err
	}

	return &authdto.LoginResp{
		AccessToken:   accessToken,
		RefreshToken:  refreshToken,
		TokenType:     "Bearer",
		ExpiresIn:     expiresIn,
		UserID:        userID,
		Email:         email,
		IsSuperAdmin:  isSuperAdmin,
		EmailVerified: true, // Only return tokens for verified accounts
	}, nil
}

// generateJWT creates a JWT access token
func (s *AuthService) generateJWT(userID uuid.UUID, email string, isSuperAdmin bool) (string, int64, error) {
	expiresIn := int64(s.app.Cfg.Token.AccessTokenExpirationTime)
	claims := jwt.MapClaims{
		"user_id":        userID,
		"email":          email,
		"is_super_admin": isSuperAdmin,
		"exp":            time.Now().Add(time.Duration(s.app.Cfg.Token.AccessTokenExpirationTime) * time.Second).Unix(),
		"iat":            time.Now().Unix(),
		"nbf":            time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(s.app.Cfg.Token.Secret))
	return tokenString, expiresIn, err
}

// generateRefreshToken creates a PASETO refresh token
func (s *AuthService) generateRefreshToken() (string, error) {
	tokenBytes := make([]byte, 32)
	_, err := rand.Read(tokenBytes)
	if err != nil {
		return "", err
	}

	return base64.URLEncoding.EncodeToString(tokenBytes), nil
}

// generateEmailVerificationToken creates a token for email verification
func (s *AuthService) generateEmailVerificationToken(userID uuid.UUID, email string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"email":   email,
		"type":    "email_verification",
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.app.Cfg.Token.Secret))
}

// VerifyUserEmail verifies user email using token
func (s *AuthService) VerifyUserEmail(ctx context.Context, tokenStr string) error {
	token, err := jwt.ParseWithClaims(tokenStr, jwt.MapClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.app.Cfg.Token.Secret), nil
	})

	if err != nil {
		return errors.ErrUnauthorized
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		// Check if this is an email verification token
		if tokenType, ok := claims["type"].(string); !ok || tokenType != "email_verification" {
			return errors.ErrUnauthorized
		}

		userIDStr, ok := claims["user_id"].(string)
		if !ok {
			return errors.ErrUnauthorized
		}

		userID, err := uuid.Parse(userIDStr)
		if err != nil {
			return errors.ErrUnauthorized
		}

		// Update account status
		err = s.app.DB.Model(&authmodels.Account{}).Where("user_id = ?", userID).
			Update("status", authmodels.AccountStatusActive).Error
		if err != nil {
			return err
		}

		return nil
	}

	return errors.ErrUnauthorized
}

// RequestForgotOTP generates and sends OTP for password reset
func (s *AuthService) RequestForgotOTP(ctx context.Context, req *authdto.RequestForgotReq) error {
	var account authmodels.Account
	err := s.app.DB.Where("email = ?", req.Email).First(&account).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// Don't reveal that user doesn't exist
			return nil
		}
		return err
	}

	// Generate OTP
	otp := generateOTP()

	// Store OTP in Redis with 5 minute expiration
	key := fmt.Sprintf("forgot_otp:%s", req.Email)
	err = s.app.Redis.Set(ctx, key, otp, 5*time.Minute)
	if err != nil {
		return err
	}

	// TODO: Send OTP via email
	_ = otp // TODO: Remove this line when implementing email sending

	return nil
}

// VerifyForgotOTP verifies OTP and allows password reset
func (s *AuthService) VerifyForgotOTP(ctx context.Context, req *authdto.VerifyForgotReq) error {
	// Verify OTP
	key := fmt.Sprintf("forgot_otp:%s", req.Email)
	storedOTP, err := s.app.Redis.Get(ctx, key)
	if err != nil {
		return errors.ErrUnauthorized
	}

	if storedOTP != req.OTP {
		return errors.ErrUnauthorized
	}

	// Delete OTP after verification
	s.app.Redis.Del(ctx, key)

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	// Update password
	err = s.app.DB.Model(&authmodels.Account{}).Where("email = ?", req.Email).
		Update("password", string(hashedPassword)).Error
	if err != nil {
		return err
	}

	return nil
}

// generateOTP generates a cryptographically secure 6-digit OTP
func generateOTP() string {
	// Use crypto/rand for secure random number generation
	b := make([]byte, 4)
	_, err := rand.Read(b)
	if err != nil {
		// Fallback to less secure but still random method
		return fmt.Sprintf("%06d", time.Now().UnixNano()%1000000)
	}
	// Convert to number and take modulo to get 6 digits
	num := int(b[0])<<24 | int(b[1])<<16 | int(b[2])<<8 | int(b[3])
	if num < 0 {
		num = -num
	}
	return fmt.Sprintf("%06d", num%1000000)
}
