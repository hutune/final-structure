---
id: "STORY-2.1"
epic_id: "EPIC-002"
title: "Campaign CRUD APIs"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "campaign", "crud", "api"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmh9"
---

# Campaign CRUD APIs

## User Story

**As an** Advertiser,
**I want** tạo, xem, sửa, xóa campaigns,
**So that** tôi có thể quản lý các chiến dịch quảng cáo của mình.

## Acceptance Criteria

- [ ] POST `/api/v1/campaigns` tạo campaign với status "draft"
- [ ] GET `/api/v1/campaigns/{id}` trả về campaign details
- [ ] PUT `/api/v1/campaigns/{id}` cập nhật campaign (chỉ khi draft/paused)
- [ ] DELETE `/api/v1/campaigns/{id}` soft delete campaign (chỉ khi draft)
- [ ] Campaign chỉ có thể được access bởi owner hoặc admin
- [ ] Validation: name required, budget > 0, end_date > start_date

## Technical Notes

**Campaign Service:** Port 8083

**API Endpoints:**
```
POST   /api/v1/campaigns
GET    /api/v1/campaigns/{id}
PUT    /api/v1/campaigns/{id}
DELETE /api/v1/campaigns/{id}
```

**Database Table:**
```sql
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    content_id UUID REFERENCES contents(id),
    budget DECIMAL(12,2) NOT NULL,
    spent DECIMAL(12,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'draft',
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_campaigns_advertiser ON campaigns(advertiser_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
```

**Status Enum:** draft, pending_approval, scheduled, running, paused, completed, cancelled

**Create Request:**
```json
{
    "name": "Summer Sale Campaign",
    "description": "Promotion for summer products",
    "content_id": "uuid",
    "budget": 1000.00,
    "start_date": "2026-03-01T00:00:00Z",
    "end_date": "2026-03-31T23:59:59Z"
}
```

## Checklist (Subtasks)

- [ ] Tạo Campaign Service structure
- [ ] Tạo campaigns table migration
- [ ] Implement Create Campaign endpoint
- [ ] Implement Get Campaign endpoint
- [ ] Implement Update Campaign endpoint
- [ ] Implement Delete Campaign endpoint (soft delete)
- [ ] Implement validation logic
- [ ] Implement authorization (owner check)
- [ ] Unit tests cho CRUD operations
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
