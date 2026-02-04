package auth

import (
	"time"

	"github.com/google/uuid"
)

// Authentication DTOs
type LoginEmailReq struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

type RegisterEmailReq struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"` // Minimum 8 chars for security
}

// PasswordValidation provides password strength requirements
// - Minimum 8 characters
// - At least one uppercase letter
// - At least one lowercase letter
// - At least one digit
// Note: Add custom validator in handler for full validation

type LoginResp struct {
	AccessToken     string    `json:"access_token,omitempty"`
	RefreshToken    string    `json:"refresh_token,omitempty"`
	TokenType       string    `json:"token_type,omitempty"`
	ExpiresIn       int64     `json:"expires_in,omitempty"`
	UserID          uuid.UUID `json:"user_id"`
	Email           string    `json:"email"`
	IsSuperAdmin    bool      `json:"is_super_admin"`
	EmailVerified   bool      `json:"email_verified"`
	VerificationMsg string    `json:"verification_msg,omitempty"`
}

// Token Management DTOs
type RefreshTokenReq struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

type RefreshTokenResp struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
	ExpiresIn    int64  `json:"expires_in"`
}

type LogoutReq struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// Password Management DTOs
type ChangePasswordReq struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

type RequestForgotReq struct {
	Email string `json:"email" binding:"required,email"`
}

type VerifyForgotReq struct {
	Email    string `json:"email" binding:"required,email"`
	OTP      string `json:"otp" binding:"required,len=6"`
	Password string `json:"password" binding:"required,min=6"`
}

// Email Verification DTOs
type VerifyEmailReq struct {
	Token string `json:"token" binding:"required"`
}

// User Invitation DTOs
type InviteUserReq struct {
	Email string `json:"email" binding:"required,email"`
}

type ResendInviteReq struct {
	Email string `json:"email" binding:"required,email"`
}

type VerifySetPasswordReq struct {
	Token    string `json:"token" binding:"required"`
	Password string `json:"password" binding:"required,min=6"`
}

// Session Management DTOs
type SessionResp struct {
	ID           uuid.UUID  `json:"id"`
	UserID       uuid.UUID  `json:"user_id"`
	IPAddress    string     `json:"ip_address"`
	UserAgent    string     `json:"user_agent"`
	ExpiredAt    time.Time  `json:"expired_at"`
	RevokedAt    *time.Time `json:"revoked_at"`
	IsSuperAdmin bool       `json:"is_super_admin"`
	CreatedAt    time.Time  `json:"created_at"`
}

// API Key Management DTOs
type ApiKeyResp struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	Key       string    `json:"key"`
	Enabled   bool      `json:"enabled"`
	Expiry    int64     `json:"expiry"`
	CreatedAt time.Time `json:"created_at"`
}

type CreateApiKeyReq struct {
	UserID uuid.UUID `json:"user_id" binding:"required"`
}

type RenewApiKeyReq struct {
	Key string `json:"key" binding:"required"`
}

// OAuth2 DTOs
type OAuth2CallbackReq struct {
	Code  string `json:"code" binding:"required"`
	State string `json:"state" binding:"required"`
}

// Super Admin DTOs
type SuperAdminLoginReq struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

type SuperAdminChangePasswordReq struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

// Token Claims DTOs
type EmailVerifyTokenClaims struct {
	UserID uuid.UUID `json:"user_id"`
	Email  string    `json:"email"`
}

type ForgotTokenClaims struct {
	UserID uuid.UUID `json:"user_id"`
	Email  string    `json:"email"`
}

type EmailInviteTokenClaims struct {
	UserID uuid.UUID `json:"user_id"`
	Email  string    `json:"email"`
}
