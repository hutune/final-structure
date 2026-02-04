---
id: "STORY-1.6"
epic_id: "EPIC-001"
title: "Email Verification Flow"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "auth", "email", "security"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1.5d"
clickup_task_id: "86ewgdmag"
---

# Email Verification Flow

## User Story

**As a** User,
**I want** xác thực email của tôi sau khi đăng ký,
**So that** tài khoản của tôi được kích hoạt và tôi có thể sử dụng đầy đủ tính năng.

## Acceptance Criteria

### AC1: Send Verification Email on Register
- [ ] **Given** user hoàn tất đăng ký thành công
- [ ] **When** registration được xử lý
- [ ] **Then** hệ thống tự động gửi email verification
- [ ] **And** user account status = "pending"
- [ ] **And** verification token valid trong 24 giờ

### AC2: Verify Email
- [ ] **Given** user có verification token từ email
- [ ] **When** user click link verification hoặc gửi token
- [ ] **Then** account status chuyển từ "pending" sang "verified"
- [ ] **And** verification token bị invalidate
- [ ] **And** user có thể login bình thường

### AC3: Resend Verification Email
- [ ] **Given** user chưa verify email
- [ ] **When** user request resend verification
- [ ] **Then** token cũ bị invalidate
- [ ] **And** token mới được gửi qua email
- [ ] **And** rate limit: max 3 lần trong 1 giờ

### AC4: Login Restriction for Unverified Users
- [ ] **Given** user chưa verify email
- [ ] **When** user cố gắng login
- [ ] **Then** login thành công nhưng response có flag `email_verified: false`
- [ ] **And** một số API bị restricted cho đến khi verify

### AC5: Expired Token Handling
- [ ] **Given** verification token đã hết hạn (>24h)
- [ ] **When** user cố verify với token cũ
- [ ] **Then** trả về 400 "Token expired"
- [ ] **And** suggest user resend verification email

## Edge Cases

| Edge Case | Expected Behavior |
|-----------|-------------------|
| Email đã verified trước đó | Return 400 "Email already verified" |
| Token không hợp lệ | Return 400 "Invalid token" |
| User bị suspended | Không cho verify, return 403 |
| Concurrent verify requests | Chỉ request đầu tiên thành công |
| Email thay đổi | Yêu cầu verify lại email mới |

## Technical Notes

**API Endpoints:**
```
POST /api/v1/auth/verify-email
POST /api/v1/auth/resend-verification
```

**Database Table:**
```sql
CREATE TABLE email_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Hoặc thêm fields vào users table:
ALTER TABLE users ADD COLUMN email_verified_at TIMESTAMP;
ALTER TABLE users ADD COLUMN verification_token VARCHAR(255);
ALTER TABLE users ADD COLUMN verification_expires_at TIMESTAMP;
```

**Verification Link Format:**
```
https://rmn-platform.com/verify-email?token={token}
```

**Request/Response Examples:**

**Verify Email Request:**
```json
{
    "token": "verification_token_here"
}
```

**Resend Verification Request:**
```json
{
    "email": "user@example.com"
}
```

**Login Response (unverified user):**
```json
{
    "access_token": "eyJhbGc...",
    "user": {
        "id": "uuid",
        "email": "user@example.com",
        "email_verified": false,
        "role": "advertiser"
    }
}
```

## Checklist (Subtasks)

- [ ] Update users table với verification fields
- [ ] Hoặc tạo email_verifications table
- [ ] Implement send verification email on register
- [ ] Implement verify-email endpoint
- [ ] Implement resend-verification endpoint
- [ ] Implement login restriction cho unverified users
- [ ] Implement rate limiting cho resend
- [ ] Unit tests cho verification flow
- [ ] Integration test cho full flow

## Dependencies

- Story 1.3 (JWT Authentication Service) phải hoàn thành trước
- Email service configuration

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
