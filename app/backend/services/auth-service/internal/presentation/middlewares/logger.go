package middleware

import (
	"time"

	"rmn-backend/pkg/logger"
	"github.com/gin-gonic/gin"
)

func Logger(logger *logger.ZeroLogger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		method := c.Request.Method

		// Retrieve the Request-ID from the context
		requestID := c.GetString(RequestIDKey)
		if requestID == "" {
			requestID = "unknown"
		}

		// Process the request

		// After request processing
		duration := time.Since(start)
		status := c.Writer.Status()

		// Log the request details
		logger.Info(c.Request.Context(), "request processed",
			"request_id", requestID,
			"method", method,
			"path", path,
			"status", status,
			"duration", duration)

		c.Next()
	}
}
