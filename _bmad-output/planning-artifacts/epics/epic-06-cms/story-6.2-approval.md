---
id: "STORY-6.2"
epic_id: "EPIC-006"
title: "Content Approval Workflow"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "cms", "approval", "admin"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# Content Approval Workflow

## User Story

**As an** Admin,
**I want** xét duyệt nội dung quảng cáo,
**So that** chỉ content phù hợp mới được phát.

## Acceptance Criteria

- [ ] GET `/api/v1/admin/content/pending` trả về content chờ duyệt
- [ ] POST `/api/v1/admin/content/{id}/approve` approve content
- [ ] POST `/api/v1/admin/content/{id}/reject` reject với reason
- [ ] Notification được gửi khi approve/reject
- [ ] Audit log cho approval actions

## Technical Notes

**API Endpoints:**
```
GET  /api/v1/admin/content/pending?page=1&limit=20
GET  /api/v1/admin/content/{id}
POST /api/v1/admin/content/{id}/approve
POST /api/v1/admin/content/{id}/reject
```

**Content Status Flow:**
```
pending_approval → approved → (can be archived)
                → rejected → (can resubmit)
```

**Reject Request:**
```json
{
    "reason": "Content violates advertising guidelines: inappropriate imagery"
}
```

**Audit Log Table:**
```sql
CREATE TABLE content_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID NOT NULL REFERENCES contents(id),
    action VARCHAR(50) NOT NULL, -- approved, rejected
    admin_id UUID NOT NULL REFERENCES users(id),
    reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Notification on Approval:**
```json
{
    "type": "content_approved",
    "title": "Content Approved",
    "body": "Your content 'summer-sale.mp4' has been approved and is ready for use."
}
```

**Notification on Rejection:**
```json
{
    "type": "content_rejected",
    "title": "Content Rejected",
    "body": "Your content 'summer-sale.mp4' was rejected. Reason: [reason]"
}
```

## Checklist (Subtasks)

- [ ] Implement List Pending Content endpoint
- [ ] Implement Get Content Detail endpoint
- [ ] Implement Approve endpoint
- [ ] Implement Reject endpoint
- [ ] Create audit log table
- [ ] Log approval actions
- [ ] Send notifications
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
