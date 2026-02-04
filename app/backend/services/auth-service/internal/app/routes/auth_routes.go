package routes

import (
	"github.com/gin-gonic/gin"
	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/presentation/handlers/auth"
	middleware "rmn-backend/services/auth-service/internal/presentation/middlewares"
)

func SetupAuthRoutes(engine *gin.Engine, app *common.App, handler *auth.AuthHandler) {
	// Health check (no rate limit)
	engine.GET("/api/v1/auth/health", handler.HealthCheck)

	// Public auth routes with rate limiting to prevent brute-force attacks
	public := engine.Group("/api/v1/auth")
	public.Use(middleware.RateLimitAuth())
	{
		public.POST("/register", handler.Register)
		public.POST("/login", handler.Login)
		public.POST("/refresh", handler.RefreshToken)
		public.POST("/logout", handler.Logout)
		public.POST("/verify-email", handler.VerifyEmail)
	}

	// Sensitive routes with strict rate limiting
	sensitive := engine.Group("/api/v1/auth")
	sensitive.Use(middleware.RateLimitStrict())
	{
		sensitive.POST("/forgot-password", handler.RequestForgotPassword)
		sensitive.POST("/verify-forgot-password", handler.VerifyForgotPassword)
	}

	// Protected auth routes (authentication required)
	protected := engine.Group("/api/v1/auth")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("/change-password", handler.ChangePassword)
		protected.GET("/session", handler.GetSession)
	}

	// Super admin routes (super admin required)
	superAdmin := engine.Group("/api/v1/super-admin")
	superAdmin.Use(middleware.AuthMiddleware(), middleware.SuperAdminMiddleware())
	superAdmin.Use(middleware.RateLimitStrict()) // Extra protection for admin routes
	{
		superAdmin.POST("/forgot-password", handler.RequestForgotPassword)
		superAdmin.POST("/forgot-password/verify", handler.VerifyForgotPassword)
		superAdmin.POST("/change-password", handler.ChangePassword)
	}
}
