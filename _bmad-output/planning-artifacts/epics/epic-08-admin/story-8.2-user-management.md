---
id: "STORY-8.2"
epic_id: "EPIC-008"
title: "User & Account Management APIs"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "admin", "users", "management"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# User & Account Management APIs

## User Story

**As an** Admin,
**I want** quản lý users và accounts,
**So that** tôi có thể approve, suspend, hoặc support users.

## Acceptance Criteria

- [ ] GET `/api/v1/admin/users` trả về user list với filters
- [ ] POST `/api/v1/admin/users/{id}/verify` verify user
- [ ] POST `/api/v1/admin/users/{id}/suspend` suspend user
- [ ] Suspended user sessions được invalidate

## Technical Notes

**API Endpoints:**
```
GET  /api/v1/admin/users?role=supplier&status=pending&page=1
GET  /api/v1/admin/users/{id}
POST /api/v1/admin/users/{id}/verify
POST /api/v1/admin/users/{id}/suspend
POST /api/v1/admin/users/{id}/unsuspend
```

**Users List Response:**
```json
{
    "data": [
        {
            "id": "uuid",
            "email": "user@example.com",
            "role": "supplier",
            "status": "pending",
            "stores_count": 3,
            "devices_count": 12,
            "total_revenue": 5000.00,
            "created_at": "2026-01-15"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 150
    }
}
```

**Suspend Request:**
```json
{
    "reason": "Violation of terms of service",
    "notify_user": true
}
```

**User Status Flow:**
```
pending → verified → suspended → verified
                   → banned (permanent)
```

**Session Invalidation:**
```go
func (s *AdminService) SuspendUser(userID string, reason string) error {
    user := s.userRepo.Get(userID)
    user.Status = "suspended"
    user.SuspendReason = reason
    s.userRepo.Update(user)

    // Invalidate all sessions
    s.sessionRepo.InvalidateByUserID(userID)

    // Send notification
    s.notificationService.Send(userID, Notification{
        Type: "account_suspended",
        Title: "Account Suspended",
        Body: fmt.Sprintf("Your account has been suspended. Reason: %s", reason),
    })

    return nil
}
```

## Checklist (Subtasks)

- [ ] Implement List Users endpoint với filters
- [ ] Implement Get User Detail endpoint
- [ ] Implement Verify User endpoint
- [ ] Implement Suspend User endpoint
- [ ] Implement Unsuspend User endpoint
- [ ] Session invalidation on suspend
- [ ] Send notifications
- [ ] Audit logging
- [ ] Unit tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
