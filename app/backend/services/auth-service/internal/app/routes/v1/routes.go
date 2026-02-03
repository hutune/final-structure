package v1

import (
	"rmn-backend/services/auth-service/internal/common"
	"rmn-backend/services/auth-service/internal/presentation/handler"
	middleware "rmn-backend/services/auth-service/internal/presentation/middlewares"

	"github.com/gin-gonic/gin"
)

func SetupV1APIRoutes(router *gin.RouterGroup, ctx *common.App) {
	// Example routes - replace with your own business logic
	exampleHandler := handler.NewExampleHandler(ctx.Logger)
	exampleGroup := router.Group("/examples")
	exampleGroup.Use(middleware.AuthCompanyID())
	{
		exampleGroup.POST("", exampleHandler.Create)
		exampleGroup.GET("", exampleHandler.GetAll)
		exampleGroup.GET("/:id", exampleHandler.GetByID)
		exampleGroup.PUT("/:id", exampleHandler.Update)
		exampleGroup.DELETE("/:id", exampleHandler.Delete)
	}
}
