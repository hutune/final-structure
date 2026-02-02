---
id: "STORY-1.4"
epic_id: "EPIC-001"
title: "Role-Based Authorization Middleware"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "auth", "rbac", "middleware"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# Role-Based Authorization Middleware

## User Story

**As a** System,
**I want** phân quyền dựa trên role trong JWT token,
**So that** chỉ user có quyền mới truy cập được các endpoint tương ứng.

## Acceptance Criteria

- [ ] Request có valid JWT với role "advertiser" được access `/api/v1/campaigns/*`
- [ ] Request có valid JWT với role "supplier" bị reject khi access `/api/v1/admin/*` (403)
- [ ] Request không có JWT bị reject với 401 Unauthorized
- [ ] Request có expired JWT bị reject với 401
- [ ] Request có invalid JWT bị reject với 401
- [ ] User context được extract và forward to downstream services

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

## Checklist (Subtasks)

- [ ] Implement token extraction from Authorization header
- [ ] Implement JWT validation
- [ ] Implement RequireAuth middleware
- [ ] Implement RequireRole middleware
- [ ] Implement user context forwarding
- [ ] Configure route groups với role requirements
- [ ] Unit tests cho auth middleware
- [ ] Test unauthorized access scenarios
- [ ] Test forbidden access scenarios

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
