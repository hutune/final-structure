---
id: "STORY-8.2"
epic_id: "EPIC-008"
title: "User & Account Management"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "admin", "users", "management"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm8f"
---

# User & Account Management

## User Story

**As a** Platform Admin,
**I want** to manage user accounts across the platform,
**So that** I can verify new users, handle support issues, and protect the platform.

## Business Context

User management ensures platform quality:
- Verify legitimate businesses before activation
- Handle account issues and suspensions
- Support users with account problems
- Maintain platform security

## Business Rules

### User Status Lifecycle
```
PENDING → VERIFIED → SUSPENDED → VERIFIED
                   → BANNED (permanent)
```

### Verification Requirements
| User Type | Required |
|-----------|----------|
| Advertiser | Business license, ID |
| Supplier | Business license, store verification |
| Admin | Internal approval only |

### Suspension Effects
- All active sessions invalidated
- Advertiser: Campaigns paused
- Supplier: Devices stop serving ads
- Revenue on hold during suspension

### Suspension Reasons
- Terms of service violation
- Fraudulent activity
- Non-payment (advertisers)
- Device tampering (suppliers)
- Copyright violations
- Pending investigation

## Acceptance Criteria

### For User List
- [ ] View all users with filters (role, status)
- [ ] Search by email, name, company
- [ ] Sort by date, revenue, campaigns
- [ ] Quick actions (verify, suspend)

### For User Details
- [ ] View full profile
- [ ] View account activity history
- [ ] View verification documents
- [ ] View related entities (campaigns/stores)

### For Account Actions
- [ ] Verify user with notes
- [ ] Suspend with reason (required)
- [ ] Unsuspend with notes
- [ ] Ban permanently (with manager approval)

### For Security
- [ ] All sessions invalidated on suspend
- [ ] Audit log for all admin actions
- [ ] Notifications sent on status change

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET  /api/v1/admin/users?role=...&status=...
GET  /api/v1/admin/users/{id}
POST /api/v1/admin/users/{id}/verify
POST /api/v1/admin/users/{id}/suspend
POST /api/v1/admin/users/{id}/unsuspend
POST /api/v1/admin/users/{id}/ban    # Requires manager
```

**Suspend Effects:**
```go
func (s *AdminService) SuspendUser(userID, reason string) error {
    // 1. Update user status
    user.Status = "suspended"
    user.SuspendReason = reason
    
    // 2. Invalidate all sessions
    s.sessionRepo.InvalidateByUserID(userID)
    
    // 3. Pause advertiser campaigns
    if user.Role == "advertiser" {
        s.campaignService.PauseAllByAdvertiser(userID)
    }
    
    // 4. Stop supplier devices
    if user.Role == "supplier" {
        s.deviceService.DeactivateBySupplier(userID)
    }
    
    // 5. Notify user
    s.notify(userID, "account_suspended", reason)
    
    // 6. Audit log
    s.auditLog.Record("suspend_user", userID, reason)
    
    return nil
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement user list with filters
- [ ] Implement user detail view
- [ ] Implement verify endpoint
- [ ] Implement suspend endpoint
- [ ] Implement unsuspend endpoint
- [ ] Session invalidation on suspend
- [ ] Cascade effects (campaigns, devices)
- [ ] Audit logging
- [ ] Email notifications
- [ ] Unit tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:26** - Rewrote with user lifecycle, verification requirements, and suspension effects.
