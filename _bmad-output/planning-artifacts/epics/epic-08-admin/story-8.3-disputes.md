---
id: "STORY-8.3"
epic_id: "EPIC-008"
title: "Dispute Resolution APIs"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "admin", "dispute", "resolution"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Dispute Resolution APIs

## User Story

**As an** Admin,
**I want** xử lý disputes giữa advertisers và suppliers,
**So that** các tranh chấp về billing được giải quyết công bằng.

## Acceptance Criteria

- [ ] POST `/api/v1/disputes` tạo dispute ticket
- [ ] GET `/api/v1/admin/disputes` list all disputes
- [ ] GET `/api/v1/admin/disputes/{id}` với proof-of-play
- [ ] POST `/api/v1/admin/disputes/{id}/resolve` resolve dispute
- [ ] Refund/adjustment được apply nếu có

## Technical Notes

**API Endpoints:**
```
POST /api/v1/disputes
GET  /api/v1/disputes (user's disputes)
GET  /api/v1/admin/disputes?status=open
GET  /api/v1/admin/disputes/{id}
POST /api/v1/admin/disputes/{id}/resolve
```

**Database Table:**
```sql
CREATE TABLE disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES users(id),
    reporter_type VARCHAR(50), -- advertiser, supplier
    campaign_id UUID REFERENCES campaigns(id),
    dispute_type VARCHAR(50), -- billing, playback, content
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    evidence_urls TEXT[], -- S3 links to screenshots, etc.
    status VARCHAR(50) DEFAULT 'open',
    resolution TEXT,
    resolved_by UUID REFERENCES users(id),
    refund_amount DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);

CREATE INDEX idx_disputes_status ON disputes(status);
CREATE INDEX idx_disputes_reporter ON disputes(reporter_id);
```

**Create Dispute Request:**
```json
{
    "campaign_id": "uuid",
    "dispute_type": "billing",
    "subject": "Incorrect impression count",
    "description": "We believe the impression count is inflated...",
    "evidence_urls": ["https://s3.../screenshot1.png"]
}
```

**Dispute Detail Response (Admin):**
```json
{
    "id": "uuid",
    "reporter": {
        "id": "uuid",
        "email": "advertiser@example.com",
        "type": "advertiser"
    },
    "campaign": {
        "id": "uuid",
        "name": "Summer Sale"
    },
    "dispute_type": "billing",
    "subject": "Incorrect impression count",
    "description": "...",
    "evidence_urls": ["..."],
    "status": "investigating",
    "proof_of_play": {
        "total_impressions": 50000,
        "by_device": [...],
        "logs_sample": [...]
    },
    "created_at": "2026-02-01"
}
```

**Resolve Request:**
```json
{
    "resolution": "After reviewing proof-of-play logs, we found 2000 invalid impressions. Refund has been issued.",
    "action": "refund",
    "refund_amount": 10.00
}
```

## Checklist (Subtasks)

- [ ] Tạo disputes table migration
- [ ] Implement Create Dispute endpoint
- [ ] Implement List Disputes (user)
- [ ] Implement List Disputes (admin)
- [ ] Implement Get Dispute Detail với proof-of-play
- [ ] Implement Resolve Dispute endpoint
- [ ] Implement refund processing
- [ ] Send notifications on resolution
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
