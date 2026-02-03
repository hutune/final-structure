package routes

import (
	"github.com/gin-gonic/gin"
	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/presentation/handlers/auth"
	middlewares "rmn-backend/services/auth-service/internal/presentation/middlewares"
)

func SetupAuthRoutes(engine *gin.Engine, app *common.App, handler *auth.AuthHandler) {
	// Apply global middleware
	// TODO: Add request ID and logger middleware

	// Auth routes (no authentication required)
	engine.POST("/api/v1/auth/register", handler.Register)
	engine.POST("/api/v1/auth/login", handler.Login)
	engine.POST("/api/v1/auth/refresh", handler.RefreshToken)
	engine.POST("/api/v1/auth/logout", handler.Logout)
	engine.POST("/api/v1/auth/verify-email", handler.VerifyEmail)
	engine.POST("/api/v1/auth/forgot-password", handler.RequestForgotPassword)
	engine.POST("/api/v1/auth/verify-forgot-password", handler.VerifyForgotPassword)
	engine.GET("/api/v1/auth/health", handler.HealthCheck)

	// Protected auth routes (authentication required)
	protected := engine.Group("/api/v1/auth")
	protected.Use(middlewares.AuthMiddleware())
	{
		protected.POST("/change-password", handler.ChangePassword)
		protected.GET("/session", handler.GetSession)
	}

	// Super admin routes (super admin required)
	superAdmin := engine.Group("/api/v1/super-admin")
	superAdmin.Use(middlewares.AuthMiddleware(), middlewares.SuperAdminMiddleware())
	{
		// TODO: Add super admin specific routes
		superAdmin.POST("/forgot-password", handler.RequestForgotPassword)
		superAdmin.POST("/forgot-password/verify", handler.VerifyForgotPassword)
		superAdmin.POST("/change-password", handler.ChangePassword)
	}
}
