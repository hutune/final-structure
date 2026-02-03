package auth

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/dto"
	authdto "rmn-backend/services/auth-service/internal/dto/auth"
	"rmn-backend/services/auth-service/internal/logic/auth"
)

type AuthHandler struct {
	authLogic *auth.AuthService
}

func NewAuthHandler(app *common.App) *AuthHandler {
	return &AuthHandler{
		authLogic: auth.NewAuthService(app),
	}
}

func (h *AuthHandler) sendError(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, dto.Response{
		Code:    strconv.Itoa(statusCode),
		Message: message,
		Data:    nil,
	})
}

// Register godoc
// @Summary Register a new user
// @Description Create a new user account with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.RegisterEmailReq true "Registration request"
// @Success 200 {object} auth.LoginResp
// @Failure 400 {object} dto.Response
// @Failure 409 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req authdto.RegisterEmailReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	result, err := h.authLogic.RegisterEmail(c.Request.Context(), &req)
	if err != nil {
		h.sendError(c, http.StatusBadRequest, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "User registered successfully", result)
}

// Login godoc
// @Summary Login user
// @Description Authenticate user with email and password
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.LoginEmailReq true "Login request"
// @Success 200 {object} auth.LoginResp
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req authdto.LoginEmailReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	result, err := h.authLogic.LoginEmail(c.Request.Context(), &req)
	if err != nil {
		h.sendError(c, http.StatusUnauthorized, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Login successful", result)
}

// RefreshToken godoc
// @Summary Refresh access token
// @Description Refresh access token using refresh token
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.RefreshTokenReq true "Refresh token request"
// @Success 200 {object} auth.RefreshTokenResp
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req authdto.RefreshTokenReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	result, err := h.authLogic.RefreshToken(c.Request.Context(), &req)
	if err != nil {
		h.sendError(c, http.StatusUnauthorized, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Token refreshed successfully", result)
}

// Logout godoc
// @Summary Logout user
// @Description Logout user and invalidate refresh token
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.LogoutReq true "Logout request"
// @Success 200 {object} dto.Response
// @Failure 400 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
	var req authdto.LogoutReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	err := h.authLogic.Logout(c.Request.Context(), &req)
	if err != nil {
		h.sendError(c, http.StatusInternalServerError, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Logout successful", nil)
}

// VerifyEmail godoc
// @Summary Verify email
// @Description Verify user email using verification token
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.VerifyEmailReq true "Email verification request"
// @Success 200 {object} dto.Response
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/verify-email [post]
func (h *AuthHandler) VerifyEmail(c *gin.Context) {
	var req authdto.VerifyEmailReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	err := h.authLogic.VerifyUserEmail(c.Request.Context(), req.Token)
	if err != nil {
		h.sendError(c, http.StatusUnauthorized, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Email verified successfully", nil)
}

// RequestForgotPassword godoc
// @Summary Request password reset
// @Description Send OTP for password reset
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.RequestForgotReq true "Forgot password request"
// @Success 200 {object} dto.Response
// @Failure 400 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/forgot-password [post]
func (h *AuthHandler) RequestForgotPassword(c *gin.Context) {
	var req authdto.RequestForgotReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	err := h.authLogic.RequestForgotOTP(c.Request.Context(), &req)
	if err != nil {
		h.sendError(c, http.StatusInternalServerError, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Password reset OTP sent successfully", nil)
}

// VerifyForgotPassword godoc
// @Summary Verify and reset password
// @Description Verify OTP and reset password
// @Tags auth
// @Accept json
// @Produce json
// @Param request body auth.VerifyForgotReq true "Verify forgot password request"
// @Success 200 {object} dto.Response
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/verify-forgot-password [post]
func (h *AuthHandler) VerifyForgotPassword(c *gin.Context) {
	var req authdto.VerifyForgotReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	err := h.authLogic.VerifyForgotOTP(c.Request.Context(), &req)
	if err != nil {
		h.sendError(c, http.StatusUnauthorized, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Password reset successfully", nil)
}

// ChangePassword godoc
// @Summary Change password
// @Description Change user password (requires authentication)
// @Tags auth
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body auth.ChangePasswordReq true "Change password request"
// @Success 200 {object} dto.Response
// @Failure 400 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/change-password [post]
func (h *AuthHandler) ChangePassword(c *gin.Context) {
	var req authdto.ChangePasswordReq
	if err := c.ShouldBindJSON(&req); err != nil {
		h.sendError(c, http.StatusBadRequest, "Invalid request format")
		return
	}

	userIDValue, exists := c.Get("user_id")
	if !exists {
		h.sendError(c, http.StatusUnauthorized, "User not authenticated")
		return
	}

	userID, ok := userIDValue.(uuid.UUID)
	if !ok {
		h.sendError(c, http.StatusUnauthorized, "Invalid user ID")
		return
	}

	err := h.authLogic.ChangePassword(c.Request.Context(), userID, &req)
	if err != nil {
		h.sendError(c, http.StatusInternalServerError, err.Error())
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Password changed successfully", nil)
}

// GetSession godoc
// @Summary Get user session
// @Description Get current user session info (requires authentication)
// @Tags auth
// @Produce json
// @Security BearerAuth
// @Success 200 {object} dto.Response
// @Failure 401 {object} dto.Response
// @Failure 500 {object} dto.Response
// @Router /api/v1/auth/session [get]
func (h *AuthHandler) GetSession(c *gin.Context) {
	userIDValue, exists := c.Get("user_id")
	emailValue, _ := c.Get("email")
	isSuperAdminValue, _ := c.Get("is_super_admin")

	if !exists {
		h.sendError(c, http.StatusUnauthorized, "User not authenticated")
		return
	}

	userID, ok := userIDValue.(uuid.UUID)
	if !ok {
		h.sendError(c, http.StatusUnauthorized, "Invalid user ID")
		return
	}

	email, _ := emailValue.(string)
	isSuperAdmin, _ := isSuperAdminValue.(bool)

	sessionData := gin.H{
		"user_id":        userID,
		"email":          email,
		"is_super_admin": isSuperAdmin,
	}

	dto.SuccessResponse(c, http.StatusOK, "Session retrieved successfully", sessionData)
}

// HealthCheck godoc
// @Summary Health check
// @Description Check if auth service is running
// @Tags health
// @Produce json
// @Success 200 {object} dto.Response
// @Router /api/v1/auth/health [get]
func (h *AuthHandler) HealthCheck(c *gin.Context) {
	dto.SuccessResponse(c, http.StatusOK, "Auth service is running", gin.H{
		"status": "healthy",
	})
}
