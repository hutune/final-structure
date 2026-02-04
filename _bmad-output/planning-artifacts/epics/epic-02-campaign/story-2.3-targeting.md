---
id: "STORY-2.3"
epic_id: "EPIC-002"
title: "Campaign Targeting & Store Selection"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "campaign", "targeting", "stores"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmfv"
---

# Campaign Targeting & Store Selection

## User Story

**As an** Advertiser,
**I want** chọn cửa hàng/khu vực để hiển thị quảng cáo,
**So that** campaign của tôi chỉ chạy ở những nơi tôi muốn.

## Acceptance Criteria

- [ ] GET `/api/v1/stores` trả về danh sách stores với filters
- [ ] Filter stores theo region, store_type
- [ ] POST `/api/v1/campaigns/{id}/stores` assign stores to campaign
- [ ] GET `/api/v1/campaigns/{id}/stores` trả về targeted và excluded stores
- [ ] Blocking rules được check khi assign stores
- [ ] Conflicting stores tự động được exclude

## Technical Notes

**API Endpoints:**
```
GET  /api/v1/stores?region={region}&type={store_type}&status=active
POST /api/v1/campaigns/{id}/stores
GET  /api/v1/campaigns/{id}/stores
DELETE /api/v1/campaigns/{id}/stores/{store_id}
```

**Database Table:**
```sql
CREATE TABLE campaign_stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    status VARCHAR(50) DEFAULT 'targeted', -- targeted, excluded
    exclusion_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(campaign_id, store_id)
);

CREATE INDEX idx_campaign_stores_campaign ON campaign_stores(campaign_id);
```

**Assign Stores Request:**
```json
{
    "store_ids": ["uuid1", "uuid2", "uuid3"],
    "target_by": "specific" // or "region", "store_type"
}
```

**Stores Response with Conflict Info:**
```json
{
    "targeted": [
        {"store_id": "uuid1", "name": "Store A"}
    ],
    "excluded": [
        {
            "store_id": "uuid2",
            "name": "Store B",
            "reason": "Blocking rule: competitor brand Apple"
        }
    ]
}
```

**Integration với Blocking Engine (Epic 7):**
- Call BlockingEngine.checkConflicts(campaign, stores)
- Auto-exclude conflicting stores
- Return exclusion reasons

## Checklist (Subtasks)

- [ ] Implement stores listing với filters
- [ ] Tạo campaign_stores table migration
- [ ] Implement assign stores endpoint
- [ ] Implement get campaign stores endpoint
- [ ] Implement remove store from campaign
- [ ] Integrate với Blocking Engine (can be mocked initially)
- [ ] Handle bulk store assignment
- [ ] Unit tests
- [ ] Integration tests với blocking

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
