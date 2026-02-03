package middleware

import (
	"github.com/gin-gonic/gin"

	"rmn-backend/pkg/apperror"
	"rmn-backend/pkg/ctx"
	"rmn-backend/services/auth-service/internal/dto"
)

func AuthCompanyID() gin.HandlerFunc {
	return func(c *gin.Context) {
		locale := c.GetHeader(ctx.LocaleHeader.Str())
		cid := c.GetHeader(ctx.CompanyIDHeader.Str())
		if cid == "" {
			dto.ErrorResponse(c, &apperror.ErrCompanyIDRequired, locale)
			c.Abort()
			return
		}
		c.Set(ctx.CompanyIDHeader.Str(), cid)
		c.Next()
	}
}

func AuthUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		locale := c.GetHeader(ctx.LocaleHeader.Str())
		userID := c.GetHeader(ctx.UserIDHeader.Str())
		if userID == "" {
			dto.ErrorResponse(c, &apperror.ErrUserIDRequired, locale)
			c.Abort()
			return
		}
		c.Set(ctx.UserIDHeader.Str(), userID)
		c.Next()
	}
}
