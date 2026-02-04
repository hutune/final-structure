package middleware

import (
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

// RateLimiter manages request limits per client IP
type RateLimiter struct {
	limiters map[string]*rate.Limiter
	mu       sync.RWMutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter creates a new rate limiter
// rate: requests per second
// burst: maximum burst size
func NewRateLimiter(r rate.Limit, burst int) *RateLimiter {
	return &RateLimiter{
		limiters: make(map[string]*rate.Limiter),
		rate:     r,
		burst:    burst,
	}
}

// getLimiter retrieves or creates a rate limiter for a client IP
func (rl *RateLimiter) getLimiter(clientIP string) *rate.Limiter {
	rl.mu.RLock()
	limiter, exists := rl.limiters[clientIP]
	rl.mu.RUnlock()

	if exists {
		return limiter
	}

	rl.mu.Lock()
	defer rl.mu.Unlock()

	// Double-check after acquiring write lock
	if limiter, exists = rl.limiters[clientIP]; exists {
		return limiter
	}

	limiter = rate.NewLimiter(rl.rate, rl.burst)
	rl.limiters[clientIP] = limiter
	return limiter
}

// Middleware returns a Gin middleware for rate limiting
func (rl *RateLimiter) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		clientIP := c.ClientIP()

		if !rl.getLimiter(clientIP).Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"code":    "429",
				"message": "Too many requests. Please try again later.",
				"data":    nil,
			})
			return
		}

		c.Next()
	}
}

// Default rate limiters for different endpoints
var (
	// AuthRateLimiter: 5 requests per second, burst of 10
	// For login, register, forgot-password
	AuthRateLimiter = NewRateLimiter(5, 10)

	// StrictRateLimiter: 1 request per second, burst of 3
	// For sensitive operations like password reset
	StrictRateLimiter = NewRateLimiter(1, 3)
)

// RateLimitAuth returns rate limiter for auth endpoints
func RateLimitAuth() gin.HandlerFunc {
	return AuthRateLimiter.Middleware()
}

// RateLimitStrict returns strict rate limiter for sensitive endpoints
func RateLimitStrict() gin.HandlerFunc {
	return StrictRateLimiter.Middleware()
}
