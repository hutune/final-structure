---
id: "STORY-1.3"
epic_id: "EPIC-001"
title: "JWT Authentication Service"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "auth", "jwt", "security"]
story_points: 8
sprint: null
start_date: null
due_date: null
time_estimate: "3d"
clickup_task_id: null
---

# JWT Authentication Service

## User Story

**As a** User,
**I want** đăng ký và đăng nhập bằng email với JWT token,
**So that** tôi có thể truy cập hệ thống một cách bảo mật.

## Acceptance Criteria

- [ ] User có thể đăng ký với email, password, role
- [ ] Password được hash bằng bcrypt với cost 10
- [ ] User có thể đăng nhập và nhận JWT token
- [ ] JWT token có expiry 24h
- [ ] Token chứa claims: user_id, email, role
- [ ] JWT signing sử dụng HMAC-SHA256
- [ ] User có thể refresh token
- [ ] Validation email được gửi (optional cho MVP)

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

## Checklist (Subtasks)

- [ ] Tạo Auth Service structure
- [ ] Tạo users table migration
- [ ] Implement user registration endpoint
- [ ] Implement password hashing với bcrypt
- [ ] Implement login endpoint
- [ ] Implement JWT token generation
- [ ] Implement token refresh endpoint
- [ ] Implement logout (token blacklist - optional)
- [ ] Unit tests cho auth handlers
- [ ] Integration tests cho auth flow

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
