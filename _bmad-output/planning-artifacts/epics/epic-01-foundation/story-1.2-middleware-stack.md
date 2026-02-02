---
id: "STORY-1.2"
epic_id: "EPIC-001"
title: "Middleware Stack Implementation"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "middleware", "cors", "logging", "rate-limit"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Middleware Stack Implementation

## User Story

**As a** Developer,
**I want** middleware stack hoàn chỉnh (CORS, Logger, Rate Limiter),
**So that** API Gateway có các tính năng bảo mật và monitoring cơ bản.

## Acceptance Criteria

- [ ] CORS middleware thêm headers vào response
- [ ] CORS xử lý preflight OPTIONS requests
- [ ] Logger middleware log: method, path, remote_addr, status_code, duration
- [ ] Rate limiter sử dụng token bucket algorithm
- [ ] Rate limiter trả về 429 khi vượt quá limit (100 req/min mặc định)
- [ ] Rate limiter configurable per-service hoặc globally
- [ ] Middleware chain order: CORS → Logger → RateLimiter → Auth → Proxy

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
