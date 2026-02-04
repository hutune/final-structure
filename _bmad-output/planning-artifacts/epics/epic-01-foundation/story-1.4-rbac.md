---
id: "STORY-1.4"
epic_id: "EPIC-001"
title: "Role-Based Authorization Middleware"
status: "doing"
priority: "critical"
assigned_to: "Leo <leonkenzo1997@gmail.com>"
tags: ["backend", "auth", "rbac", "middleware"]
story_points: 3
sprint: 1
start_date: "2026-01-25"
due_date: "2026-01-26"
time_estimate: "1d"
clickup_task_id: "86ewgdmax"
---

# Role-Based Authorization Middleware

## User Story

**As a** System,
**I want** phân quyền dựa trên role trong JWT token,
**So that** chỉ user có quyền mới truy cập được các endpoint tương ứng.

## Acceptance Criteria

### Core Authorization
- [x] Request có valid JWT với role "advertiser" được access `/api/v1/campaigns/*`
- [x] Request có valid JWT với role "supplier" bị reject khi access `/api/v1/admin/*` (403)
- [x] Request không có JWT bị reject với 401 Unauthorized
- [x] Request có expired JWT bị reject với 401
- [x] Request có invalid JWT bị reject với 401
- [x] User context được extract và forward to downstream services

### Advanced Authorization (NEW)
- [ ] **Token Revocation Check**: Middleware kiểm tra token có trong blacklist không (Redis)
- [ ] **Role Change Handling**: Khi admin đổi role user → tokens cũ bị invalidate
- [ ] **Resource Ownership**: User chỉ access được resources của mình (không access campaign của user khác)
- [ ] **Rate Limit per User**: Giới hạn API calls per user (không chỉ per IP)
- [ ] **Admin Permission Inheritance**: Admin có tất cả quyền của advertiser + supplier

## Implementation Notes

> **✅ DONE** - Đã implement trong:
> - `mtsgn-system-gateway-svc/internal/handlers/auth.go` - Auth validation
> - `mtsgn-system-gateway-svc/internal/server/server.go` - Priority Router với SkipAuth config
> - `mtsgn-source-base-svc/internal/presentation/middlewares/auth.go` - Auth middleware
> - `mtsgn-system-gateway-svc/pkg/config/model.go` - ServiceConfig.SkipAuth

## Technical Notes

**File Location:** `internal/middleware/auth.go`

**Roles:**
- `advertiser` - Access to campaign, wallet, content APIs
- `supplier` - Access to store, device, revenue APIs
- `admin` - Access to all APIs including admin endpoints

**Role Permissions Matrix:**

| Endpoint Pattern | advertiser | supplier | admin |
|------------------|------------|----------|-------|
| `/api/v1/campaigns/*` | ✅ | ❌ | ✅ |
| `/api/v1/stores/*` | ❌ | ✅ | ✅ |
| `/api/v1/devices/*` | ❌ | ✅ | ✅ |
| `/api/v1/admin/*` | ❌ | ❌ | ✅ |
| `/api/v1/wallet` | ✅ | ✅ | ✅ |
| `/api/v1/content/*` | ✅ | ❌ | ✅ |

**Auth Middleware Implementation:**
```go
func RequireAuth(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        token := extractToken(r)
        claims, err := validateToken(token)
        if err != nil {
            http.Error(w, "Unauthorized", 401)
            return
        }
        ctx := context.WithValue(r.Context(), "user", claims)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

func RequireRole(roles ...string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            claims := r.Context().Value("user").(*Claims)
            if !contains(roles, claims.Role) {
                http.Error(w, "Forbidden", 403)
                return
            }
            next.ServeHTTP(w, r)
        })
    }
}
```

**Header Forwarding:**
- `X-User-ID`: User ID from token
- `X-User-Email`: Email from token
- `X-User-Role`: Role from token

## Edge Cases Table

| Edge Case | Expected Behavior | Status |
|-----------|-------------------|--------|
| Token expired giữa request | Return 401, client refresh token | To-do |
| Role thay đổi sau khi token issued | Check Redis cho role version, invalidate nếu mismatch | To-do |
| Access resource của user khác | Return 403 "Access denied to this resource" | To-do |
| Token trong blacklist | Return 401 "Token revoked" | To-do |
| Missing Authorization header | Return 401 "Authorization header required" | To-do |
| Malformed token format | Return 401 "Invalid token format" | To-do |
| User account suspended sau login | Return 403 "Account suspended" on next request | To-do |

## Checklist (Subtasks)

- [ ] Implement token extraction from Authorization header
- [ ] Implement JWT validation
- [ ] Implement RequireAuth middleware
- [ ] Implement RequireRole middleware
- [ ] Implement user context forwarding
- [ ] Implement token blacklist check (Redis lookup)
- [ ] Implement role version check for invalidation
- [ ] Implement resource ownership validation helper
- [ ] Implement per-user rate limiting
- [ ] Configure route groups với role requirements
- [ ] Unit tests cho auth middleware
- [ ] Test unauthorized access scenarios
- [ ] Test forbidden access scenarios
- [ ] Test token revocation scenarios
- [ ] Test resource ownership scenarios

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
