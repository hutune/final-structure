---
id: "STORY-1.2"
epic_id: "EPIC-001"
title: "Middleware Stack Implementation"
status: "doing"
priority: "critical"
assigned_to: "Leo <leonkenzo1997@gmail.com>"
tags: ["backend", "middleware", "cors", "logging", "rate-limit"]
story_points: 5
sprint: 1
start_date: "2026-01-18"
due_date: "2026-01-20"
time_estimate: "2d"
clickup_task_id: "86ewgdmc0"
---

# Middleware Stack Implementation

## User Story

**As a** Developer,
**I want** middleware stack hoàn chỉnh (CORS, Logger, Rate Limiter),
**So that** API Gateway có các tính năng bảo mật và monitoring cơ bản.

## Acceptance Criteria

- [x] CORS middleware thêm headers vào response
- [x] CORS xử lý preflight OPTIONS requests
- [x] Logger middleware log: method, path, remote_addr, status_code, duration
- [x] Rate limiter sử dụng token bucket algorithm
- [x] Rate limiter trả về 429 khi vượt quá limit (100 req/min mặc định)
- [x] Rate limiter configurable per-service hoặc globally
- [x] Middleware chain order: CORS → Logger → RateLimiter → Auth → Proxy

## Implementation Notes

> **✅ DONE** - Đã implement trong:
> - `mtsgn-aps-be-common-svc/common/middleware/cors.go` - CORS với unit tests
> - `mtsgn-aps-be-common-svc/common/middleware/ratelimit.go` - Rate limiting với tests
> - `mtsgn-system-gateway-svc/internal/middleware/` - Logger, CORS, Metrics
> - `mtsgn-system-gateway-svc/pkg/redis/silding_window_rds.go` - Redis-based rate limit

## Technical Notes

**File Locations:**
- `internal/middleware/cors.go`
- `internal/middleware/logger.go`
- `internal/middleware/ratelimit.go`

**CORS Middleware:**
```go
func CORS(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

**Logger Middleware:**
- Log format: `[timestamp] method path remote_addr status_code duration`
- Use structured logging (zerolog hoặc zap)

**Rate Limiter:**
- Token bucket algorithm
- Per-IP limiting
- Configurable: `rate_limit.default_limit: 100`
- Automatic cleanup of stale entries

## Checklist (Subtasks)

- [ ] Implement CORS middleware
- [ ] Implement Logger middleware với structured logging
- [ ] Implement Rate Limiter với token bucket
- [ ] Implement middleware chaining helper
- [ ] Add rate limit config to config.yaml
- [ ] Unit tests cho CORS middleware
- [ ] Unit tests cho Rate Limiter
- [ ] Integration test cho middleware chain

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
