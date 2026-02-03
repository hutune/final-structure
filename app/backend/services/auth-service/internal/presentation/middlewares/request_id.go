package middleware

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const RequestIDKey = "request_id"

func RequestID() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Check if the request already has a Request-ID
		requestID := c.GetHeader(RequestIDKey)
		if requestID == "" {
			requestID = uuid.New().String()
		}

		currentCtx := c.Request.Context()
		newCtx := context.WithValue(currentCtx, RequestIDKey, requestID)
		// Update the request with the new context
		c.Request = c.Request.WithContext(newCtx)
		// Add Request-ID to the context and response header
		c.Set(RequestIDKey, requestID)
		c.Writer.Header().Set(RequestIDKey, requestID)
		c.Next()
	}
}
