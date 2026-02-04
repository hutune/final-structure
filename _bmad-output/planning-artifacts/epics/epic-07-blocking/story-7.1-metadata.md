---
id: "STORY-7.1"
epic_id: "EPIC-007"
title: "Campaign Metadata Tagging"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "blocking", "metadata", "tags"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# Campaign Metadata Tagging

## User Story

**As an** Advertiser,
**I want** gắn tags (brand, category) cho campaign,
**So that** hệ thống có thể matching với blocking rules.

## Acceptance Criteria

- [ ] Campaign có thể set brand và categories
- [ ] PUT `/api/v1/campaigns/{id}` accepts metadata
- [ ] Standardized brand/category taxonomy
- [ ] Auto-suggest tags dựa trên content (Phase 2)

## Technical Notes

**Database Table:**
```sql
CREATE TABLE campaign_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id),
    key VARCHAR(50) NOT NULL, -- brand, category
    value VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(campaign_id, key, value)
);

CREATE INDEX idx_campaign_metadata_campaign ON campaign_metadata(campaign_id);
CREATE INDEX idx_campaign_metadata_value ON campaign_metadata(value);
```

**Campaign Create/Update Request:**
```json
{
    "name": "iPhone 15 Launch",
    "brand": "Apple",
    "categories": ["Electronics", "Smartphones"],
    "budget": 5000.00
}
```

**Standardized Categories:**
```
Electronics
├── Smartphones
├── Laptops
├── Tablets
├── Accessories
Food & Beverages
├── Soft Drinks
├── Snacks
├── Dairy
Fashion
├── Clothing
├── Footwear
├── Accessories
```

## Checklist (Subtasks)

- [ ] Tạo campaign_metadata table migration
- [ ] Update Campaign Create to accept metadata
- [ ] Update Campaign Update to accept metadata
- [ ] Store metadata in campaign_metadata table
- [ ] Define standard category taxonomy
- [ ] GET campaign includes metadata
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
