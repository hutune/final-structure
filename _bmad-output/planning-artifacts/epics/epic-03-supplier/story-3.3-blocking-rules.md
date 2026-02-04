---
id: "STORY-3.3"
epic_id: "EPIC-003"
title: "Competitor Blocking Rules Management"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "supplier", "blocking", "competitor"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Competitor Blocking Rules Management

## User Story

**As a** Supplier,
**I want** thiết lập quy tắc chặn quảng cáo đối thủ,
**So that** cửa hàng của tôi không hiển thị quảng cáo đối thủ cạnh tranh.

## Acceptance Criteria

- [ ] POST `/api/v1/stores/{store_id}/blocking-rules` tạo blocking rule
- [ ] GET `/api/v1/stores/{store_id}/blocking-rules` trả về danh sách rules
- [ ] DELETE `/api/v1/stores/{store_id}/blocking-rules/{rule_id}` xóa rule
- [ ] Rule types: brand, category, keyword
- [ ] Rules được check khi campaign targeting store

## Technical Notes

**API Endpoints:**
```
POST   /api/v1/stores/{store_id}/blocking-rules
GET    /api/v1/stores/{store_id}/blocking-rules
DELETE /api/v1/stores/{store_id}/blocking-rules/{rule_id}
```

**Database Table:**
```sql
CREATE TABLE blocking_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL REFERENCES stores(id),
    rule_type VARCHAR(50) NOT NULL, -- brand, category, keyword
    value VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(store_id, rule_type, value)
);

CREATE INDEX idx_blocking_rules_store ON blocking_rules(store_id);
CREATE INDEX idx_blocking_rules_value ON blocking_rules(value);
```

**Rule Types:**
| Type | Description | Example |
|------|-------------|---------|
| brand | Specific brand name | "Apple", "Samsung" |
| category | Product category | "Electronics", "Beverages" |
| keyword | Keyword in content | "competitor", "sale" |

**Create Rule Request:**
```json
{
    "rule_type": "brand",
    "value": "Apple"
}
```

**Batch Create:**
```json
{
    "rules": [
        {"rule_type": "brand", "value": "Apple"},
        {"rule_type": "brand", "value": "Xiaomi"},
        {"rule_type": "category", "value": "Electronics"}
    ]
}
```

**Integration với Epic 7 (Blocking Engine):**
- Rules được query bởi BlockingEngine khi campaign submit
- Matching logic: exact match cho brand, contains cho keyword

## Checklist (Subtasks)

- [ ] Tạo blocking_rules table migration
- [ ] Implement Create Rule endpoint
- [ ] Implement Batch Create Rules
- [ ] Implement List Rules endpoint
- [ ] Implement Delete Rule endpoint
- [ ] Validate rule_type enum
- [ ] Handle duplicate rules gracefully
- [ ] Index optimization cho matching queries
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
