---
id: "STORY-1.7"
epic_id: "EPIC-001"
title: "User Profile Management"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "user", "profile", "crud"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# User Profile Management

## User Story

**As a** User (Advertiser hoặc Supplier),
**I want** xem và cập nhật thông tin profile của tôi,
**So that** thông tin của tôi trên hệ thống luôn chính xác.

## Acceptance Criteria

### AC1: Get Current User Profile
- [ ] **Given** user đã đăng nhập với valid JWT token
- [ ] **When** user gọi GET /api/v1/users/me
- [ ] **Then** trả về full profile của user hiện tại
- [ ] **And** không trả về password_hash hoặc sensitive fields

### AC2: Update Profile (Common Fields)
- [ ] **Given** user đã đăng nhập
- [ ] **When** user gửi PATCH /api/v1/users/me với data update
- [ ] **Then** profile được cập nhật
- [ ] **And** updated_at được set
- [ ] **And** trả về profile mới

### AC3: Advertiser-Specific Profile Fields
- [ ] **Given** user có role "advertiser"
- [ ] **When** user update profile
- [ ] **Then** có thể update: company_name, contact_person, phone, address
- [ ] **And** optional: tax_id, business_license

### AC4: Supplier-Specific Profile Fields
- [ ] **Given** user có role "supplier"
- [ ] **When** user update profile
- [ ] **Then** có thể update: company_name, contact_person, phone
- [ ] **And** bank_account_info cho nhận doanh thu

### AC5: Change Email
- [ ] **Given** user muốn đổi email
- [ ] **When** user gửi request change email
- [ ] **Then** email mới cần được verify
- [ ] **And** email cũ vẫn active cho đến khi email mới verified
- [ ] **And** notification được gửi đến email cũ

### AC6: Change Password
- [ ] **Given** user muốn đổi password
- [ ] **When** user gửi request với current_password và new_password
- [ ] **Then** verify current_password đúng
- [ ] **And** new_password được hash và save
- [ ] **And** tất cả sessions khác bị logout

## Edge Cases

| Edge Case | Expected Behavior |
|-----------|-------------------|
| Update field không thuộc role | Return 400 "Field not allowed for your role" |
| Email đã tồn tại | Return 409 "Email already in use" |
| Current password sai | Return 401 "Invalid current password" |
| New password giống old password | Return 400 "New password must be different" |
| Update khi account suspended | Return 403 "Account suspended" |

## Technical Notes

**API Endpoints:**
```
GET    /api/v1/users/me              # Get current user profile
PATCH  /api/v1/users/me              # Update profile
POST   /api/v1/users/me/change-email # Change email (requires verification)
POST   /api/v1/users/me/change-password # Change password
```

**Database Schema Updates:**
```sql
-- User profiles table (or extend users table)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    company_name VARCHAR(255),
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    -- Advertiser specific
    tax_id VARCHAR(100),
    business_license VARCHAR(255),
    -- Supplier specific
    bank_name VARCHAR(255),
    bank_account_number VARCHAR(100),
    bank_account_name VARCHAR(255),
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Request/Response Examples:**

**Get Profile Response:**
```json
{
    "id": "uuid",
    "email": "user@example.com",
    "email_verified": true,
    "role": "advertiser",
    "status": "verified",
    "profile": {
        "company_name": "Acme Corp",
        "contact_person": "John Doe",
        "phone": "+84901234567",
        "address": "123 Main St, HCMC",
        "tax_id": "0123456789"
    },
    "created_at": "2026-01-15T10:00:00Z",
    "updated_at": "2026-01-20T15:30:00Z"
}
```

**Update Profile Request:**
```json
{
    "company_name": "New Company Name",
    "phone": "+84909876543"
}
```

**Change Password Request:**
```json
{
    "current_password": "OldPassword123!",
    "new_password": "NewPassword456!"
}
```

## Checklist (Subtasks)

- [ ] Tạo user_profiles table migration
- [ ] Implement GET /users/me endpoint
- [ ] Implement PATCH /users/me endpoint
- [ ] Implement change-email endpoint
- [ ] Implement change-password endpoint
- [ ] Role-based field validation
- [ ] Unit tests cho profile CRUD
- [ ] Integration tests

## Dependencies

- Story 1.3 (JWT Authentication Service)
- Story 1.4 (RBAC) để biết user role

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
