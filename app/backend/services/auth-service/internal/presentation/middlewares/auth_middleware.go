package middleware

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/o1egl/paseto"
	"rmn-backend/services/auth-service/internal/common/errors"
	"rmn-backend/services/auth-service/internal/dto"
)

// TokenClaims represents the JWT/PASETO token claims
type TokenClaims struct {
	UserID       uuid.UUID `json:"user_id"`
	Email        string    `json:"email"`
	IsSuperAdmin bool      `json:"is_super_admin"`
	jwt.RegisteredClaims
}

// AuthMiddleware validates JWT/PASETO tokens and sets user context
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Try to get token from Authorization header first
		authHeader := c.GetHeader("Authorization")
		var token string

		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token = strings.TrimPrefix(authHeader, "Bearer ")
		} else {
			// Fallback to direct headers (for backward compatibility)
			userIDStr := c.GetHeader("X-User-ID")
			companyIDStr := c.GetHeader("X-Company-ID")
			isSuperAdminStr := c.GetHeader("X-Is-Super-Admin")

			if userIDStr != "" {
				userID, err := uuid.Parse(userIDStr)
				if err == nil {
					c.Set("user_id", userID)
					if companyIDStr != "" {
						c.Set("company_id", companyIDStr)
					}
					if isSuperAdminStr == "true" {
						c.Set("is_super_admin", true)
					}
					c.Next()
					return
				}
			}

			c.JSON(http.StatusUnauthorized, dto.Response{
				Code:    strconv.Itoa(http.StatusUnauthorized),
				Message: "Authorization token required",
				Data:    nil,
			})
			c.Abort()
			return
		}

		// Validate token
		claims, err := validateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, dto.Response{
				Code:    strconv.Itoa(http.StatusUnauthorized),
				Message: "Invalid or expired token",
				Data:    nil,
			})
			c.Abort()
			return
		}

		// Set user context
		c.Set("user_id", claims.UserID)
		c.Set("email", claims.Email)
		c.Set("is_super_admin", claims.IsSuperAdmin)

		c.Next()
	}
}

// OptionalAuthMiddleware sets user context if token is present, but doesn't require it
func OptionalAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")

		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token := strings.TrimPrefix(authHeader, "Bearer ")

			if claims, err := validateToken(token); err == nil {
				c.Set("user_id", claims.UserID)
				c.Set("email", claims.Email)
				c.Set("is_super_admin", claims.IsSuperAdmin)
			}
		}

		c.Next()
	}
}

// SuperAdminMiddleware requires super admin privileges
func SuperAdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		isSuperAdmin, exists := c.Get("is_super_admin")
		if !exists || !isSuperAdmin.(bool) {
			c.JSON(http.StatusForbidden, dto.Response{
				Code:    strconv.Itoa(http.StatusForbidden),
				Message: "Super admin privileges required",
				Data:    nil,
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// ApiKeyMiddleware validates API keys for service-to-service communication
func ApiKeyMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		apiKey := c.GetHeader("X-API-Key")

		if apiKey == "" {
			c.JSON(http.StatusUnauthorized, dto.Response{
				Code:    strconv.Itoa(http.StatusUnauthorized),
				Message: "API key required",
				Data:    nil,
			})
			c.Abort()
			return
		}

		// TODO: Implement API key validation logic
		// This would involve checking the database for a valid API key
		// and setting the user context accordingly

		c.JSON(http.StatusNotImplemented, dto.Response{
			Code:    strconv.Itoa(http.StatusNotImplemented),
			Message: "API key authentication not yet implemented",
			Data:    nil,
		})
		c.Abort()
		return
	}
}

// validateToken validates both JWT and PASETO tokens
func validateToken(tokenString string) (*TokenClaims, error) {
	// Try JWT first
	if claims, err := validateJWT(tokenString); err == nil {
		return claims, nil
	}

	// Try PASETO
	if claims, err := validatePASETO(tokenString); err == nil {
		return claims, nil
	}

	return nil, errors.ErrUnauthorized
}

// validateJWT validates JWT token
func validateJWT(tokenString string) (*TokenClaims, error) {
	// TODO: Get secret from configuration
	secret := []byte("your-super-secret-jwt-key-change-in-production")

	token, err := jwt.ParseWithClaims(tokenString, &TokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.ErrUnauthorized
		}
		return secret, nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*TokenClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.ErrUnauthorized
}

// validatePASETO validates PASETO token
func validatePASETO(tokenString string) (*TokenClaims, error) {
	// TODO: Get secret from configuration
	secret := []byte("your-super-secret-paseto-key-change-in-production")

	var claims TokenClaims
	err := paseto.NewV2().Decrypt(tokenString, secret, &claims, nil)
	if err != nil {
		return nil, err
	}

	return &claims, nil
}
