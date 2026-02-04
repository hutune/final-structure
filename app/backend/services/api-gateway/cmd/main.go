package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	pkgconfig "rmn-backend/pkg/config"
	"rmn-backend/pkg/logger"
	"rmn-backend/services/api-gateway/internal/handlers"
	"rmn-backend/services/api-gateway/internal/middleware"
	"rmn-backend/services/api-gateway/pkg/config"
	rds "rmn-backend/services/api-gateway/pkg/redis"
)

func main() {
	ctx := context.Background()
	cfg := &config.Config{}
	configDir := pkgconfig.GetConfigPath()
	if err := pkgconfig.LoadConfig(configDir, cfg); err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// --------------- Logger ---------------------------- //
	zeroLogger, err := logger.NewLogger(logger.Config{
		Level:         logger.Level(cfg.LogLevel),
		Service:       "sp-gateway-architect",
		DisableCaller: true,
	})
	if err != nil {
		log.Println("Failed to initialize zerolog", err)
		return
	}

	// --------------- Setup Local Rate Limiter ---------------------------- //
	localLimiter := rds.NewTokenBucketLimiter(
		cfg.RateLimit.RequestsPerSecond,
		cfg.RateLimit.Burst,
	)
	var redisLimiter *rds.RedisSlidingWindowLimiter = nil
	var rateLimiter rds.RateLimiter = localLimiter
	// Try to initialize Redis limiter if configured
	if cfg.Redis.Host != "" {
		redisLimiter, err = rds.NewRedisSlidingWindowLimiter(
			&cfg.Redis,
			cfg.RateLimit.RequestsPerSecond,
			time.Second,
		)
		if err != nil {
			zeroLogger.Error(ctx, "Failed to connect to Redis, using local limiter", "error", err)
		} else {
			rateLimiter = redisLimiter
		}
	}

	zeroLogger.Info(ctx, "API Gateway initialized", "rate_limiter", fmt.Sprintf("%T", rateLimiter))
	// Initialize handlers
	proxyHandler := handlers.NewProxyHandler(cfg, rateLimiter, redisLimiter, *zeroLogger)

	// Setup HTTP server with middlewares
	mux := http.NewServeMux()

	// Apply global middleware
	handler := middleware.Logger(
		middleware.CORS(
			proxyHandler,
		),
		*zeroLogger,
	)

	// Register routes
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy","service":"api-gateway"}`))
	})

	mux.Handle("/", handler)

	// Start server
	addr := fmt.Sprintf(":%d", cfg.Server.Port)
	zeroLogger.Info(ctx, "API Gateway starting on", "addr", addr)
	zeroLogger.Info(ctx, "Configured services", "count", len(cfg.Services))
	if err := http.ListenAndServe(addr, mux); err != nil {
		zeroLogger.Error(ctx, "Server failed to start", "error", err)
	}
}
