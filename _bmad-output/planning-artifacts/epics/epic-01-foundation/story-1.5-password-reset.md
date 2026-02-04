---
id: "STORY-1.5"
epic_id: "EPIC-001"
title: "Password Reset Flow"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "auth", "security", "email"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Password Reset Flow

## User Story

**As a** User,
**I want** đặt lại mật khẩu khi quên,
**So that** tôi có thể khôi phục quyền truy cập tài khoản của mình.

## Acceptance Criteria

### AC1: Request Password Reset
- [x] **Given** user có tài khoản với email đã verify
- [x] **When** user gửi request forgot password với email
- [x] **Then** hệ thống gửi email chứa reset token (valid 1 giờ)
- [x] **And** response trả về 200 OK (không leak thông tin email có tồn tại hay không)

### AC2: Validate Reset Token
- [ ] **Given** user có reset token từ email
- [ ] **When** user gửi request validate token
- [ ] **Then** hệ thống trả về 200 nếu token hợp lệ và chưa hết hạn
- [ ] **And** trả về 400 nếu token không hợp lệ hoặc đã hết hạn

### AC3: Reset Password
- [ ] **Given** user có reset token hợp lệ
- [ ] **When** user gửi request đổi password với token và password mới
- [ ] **Then** password được update và hash bằng bcrypt
- [ ] **And** reset token bị invalidate (chỉ dùng 1 lần)
- [ ] **And** tất cả sessions hiện tại bị logout

### AC4: Rate Limiting
- [ ] **Given** user gửi nhiều request forgot password
- [ ] **When** vượt quá 3 requests trong 15 phút cho cùng email
- [ ] **Then** hệ thống trả về 429 Too Many Requests
- [ ] **And** log suspicious activity

### AC5: Password Validation
- [ ] **Given** user đang reset password
- [ ] **When** password mới không đáp ứng yêu cầu
- [ ] **Then** trả về 400 với message chi tiết
- [ ] **And** yêu cầu: min 8 chars, 1 uppercase, 1 lowercase, 1 number

## Edge Cases

| Edge Case | Expected Behavior |
|-----------|-------------------|
| Email không tồn tại | Return 200 OK (security: không leak info) |
| Token đã được sử dụng | Return 400 "Token already used" |
| Token hết hạn | Return 400 "Token expired" |
| Concurrent reset requests | Chỉ token mới nhất valid |
| User account bị suspended | Vẫn cho reset, nhưng account vẫn suspended |

## Technical Notes

**API Endpoints:**
```
POST /api/v1/auth/forgot-password
POST /api/v1/auth/validate-reset-token
POST /api/v1/auth/reset-password
```

**Database Table (hoặc thêm vào users table):**
```sql
CREATE TABLE password_resets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Request/Response Examples:**

**Forgot Password Request:**
```json
{
    "email": "user@example.com"
}
```

**Reset Password Request:**
```json
{
    "token": "abc123...",
    "new_password": "NewSecurePassword123!"
}
```

## Checklist (Subtasks)

- [ ] Tạo password_resets table migration
- [ ] Implement forgot-password endpoint
- [ ] Implement email sending (có thể mock cho MVP)
- [ ] Implement validate-reset-token endpoint
- [ ] Implement reset-password endpoint
- [ ] Implement rate limiting cho forgot-password
- [ ] Unit tests cho tất cả endpoints
- [ ] Integration test cho full flow

## Dependencies

- Story 1.3 (JWT Authentication Service) phải hoàn thành trước
- Email service (có thể mock cho MVP)

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
