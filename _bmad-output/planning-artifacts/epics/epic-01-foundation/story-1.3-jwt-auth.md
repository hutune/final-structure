---
id: "STORY-1.3"
epic_id: "EPIC-001"
title: "JWT Authentication Service"
status: "doing"
priority: "critical"
assigned_to: "Leo <leonkenzo1997@gmail.com>"
tags: ["backend", "auth", "jwt", "security"]
story_points: 8
sprint: 1
start_date: "2026-01-21"
due_date: "2026-01-24"
time_estimate: "3d"
clickup_task_id: null
---

# JWT Authentication Service

## User Story

**As a** User,
**I want** đăng ký và đăng nhập bằng email với JWT token,
**So that** tôi có thể truy cập hệ thống một cách bảo mật.

## Acceptance Criteria

### Core Authentication
- [x] User có thể đăng ký với email, password, role
- [x] Password được hash bằng bcrypt với cost 10
- [x] User có thể đăng nhập và nhận JWT token
- [x] JWT token có expiry 24h
- [x] Token chứa claims: user_id, email, role
- [x] JWT signing sử dụng HMAC-SHA256 (PASETO alternative implemented)
- [x] User có thể refresh token
- [ ] Validation email được gửi (moved to Story 1.6)

### Security Edge Cases (NEW)
- [ ] **Brute Force Protection**: Account bị lock sau 5 lần login thất bại trong 15 phút
- [ ] **Password Complexity**: Min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
- [ ] **Duplicate Email**: Return 409 Conflict khi đăng ký email đã tồn tại
- [ ] **Concurrent Sessions**: Giới hạn tối đa 5 active sessions per user
- [ ] **Token Blacklist on Logout**: Logout invalidate token ngay lập tức (store trong Redis)

### Audit Logging (NEW)
- [ ] Log login success với: user_id, IP, user-agent, timestamp
- [ ] Log login failure với: email attempted, IP, reason, timestamp
- [ ] Log logout với: user_id, IP, timestamp
- [ ] Log suspicious activity: multiple failed logins, unusual IP patterns

## Implementation Notes

> **✅ DONE** - Đã implement trong:
> - `mtsgn-aps-be-common-svc/common/token/paseto.go` - PASETO token (more secure than JWT)
> - `mtsgn-aps-be-common-svc/common/token/paseto_test.go` - Unit tests
> - `mtsgn-system-gateway-svc/internal/handlers/auth.go` - Auth handler
> - `mtsgn-system-gateway-svc/pkg/config/model.go` - AuthConfig với token expiration

## Technical Notes

**Auth Service:** Port 8082

**API Endpoints:**
```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
```

**Database Table:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- advertiser, supplier, admin
    status VARCHAR(50) DEFAULT 'pending', -- pending, verified, suspended
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**JWT Claims:**
```go
type Claims struct {
    UserID string `json:"user_id"`
    Email  string `json:"email"`
    Role   string `json:"role"`
    jwt.StandardClaims
}
```

**Register Request:**
```json
{
    "email": "user@example.com",
    "password": "securepassword",
    "role": "advertiser"
}
```

**Login Response:**
```json
{
    "access_token": "eyJhbGc...",
    "token_type": "Bearer",
    "expires_in": 86400,
    "user": {
        "id": "uuid",
        "email": "user@example.com",
        "role": "advertiser"
    }
}
```

## Edge Cases Table

| Edge Case | Expected Behavior | Status |
|-----------|-------------------|--------|
| Email không hợp lệ (format) | Return 400 "Invalid email format" | To-do |
| Email đã tồn tại | Return 409 "Email already registered" | To-do |
| Password quá yếu | Return 400 với chi tiết requirements | To-do |
| Account locked (brute force) | Return 423 "Account temporarily locked" | To-do |
| Refresh với token đã logout | Return 401 "Token revoked" | To-do |
| Login với account suspended | Return 403 "Account suspended" | To-do |
| Concurrent login từ 6+ devices | Logout device cũ nhất tự động | To-do |

## Checklist (Subtasks)

- [ ] Tạo Auth Service structure
- [ ] Tạo users table migration
- [ ] Implement user registration endpoint
- [ ] Implement password hashing với bcrypt
- [ ] Implement password complexity validation
- [ ] Implement login endpoint
- [ ] Implement brute force protection (Redis counter)
- [ ] Implement JWT token generation
- [ ] Implement token refresh endpoint
- [ ] Implement logout với token blacklist (Redis)
- [ ] Implement concurrent session limiting
- [ ] Implement audit logging cho auth events
- [ ] Unit tests cho auth handlers
- [ ] Unit tests cho edge cases
- [ ] Integration tests cho auth flow

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
