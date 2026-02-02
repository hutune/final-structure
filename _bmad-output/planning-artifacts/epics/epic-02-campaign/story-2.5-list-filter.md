---
id: "STORY-2.5"
epic_id: "EPIC-002"
title: "Campaign List & Filtering"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "campaign", "list", "filter", "pagination"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# Campaign List & Filtering

## User Story

**As an** Advertiser,
**I want** xem danh sách campaigns với filter và pagination,
**So that** tôi có thể tìm và quản lý campaigns dễ dàng.

## Acceptance Criteria

- [ ] GET `/api/v1/campaigns` trả về paginated list
- [ ] Filter theo status hoạt động
- [ ] Filter theo date range
- [ ] Search theo name
- [ ] Sort by: created_at, start_date, budget, spent
- [ ] Response có pagination metadata
- [ ] Default sort: created_at DESC

## Technical Notes

**API Endpoint:**
```
GET /api/v1/campaigns?status=running&page=1&limit=20&search=sale&sort=created_at&order=desc
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | int | 1 | Page number |
| limit | int | 20 | Items per page (max 100) |
| status | string | - | Filter by status |
| search | string | - | Search in name |
| start_from | date | - | Filter start_date >= |
| start_to | date | - | Filter start_date <= |
| sort | string | created_at | Sort field |
| order | string | desc | Sort order (asc/desc) |

**Response:**
```json
{
    "data": [
        {
            "id": "uuid",
            "name": "Summer Sale",
            "status": "running",
            "budget": 1000.00,
            "spent": 450.00,
            "start_date": "2026-03-01",
            "end_date": "2026-03-31",
            "impressions": 90000,
            "created_at": "2026-02-15"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 45,
        "total_pages": 3
    }
}
```

**SQL Query Example:**
```sql
SELECT c.*,
       COALESCE(SUM(b.impressions), 0) as impressions
FROM campaigns c
LEFT JOIN billing_records b ON c.id = b.campaign_id
WHERE c.advertiser_id = $1
  AND c.deleted_at IS NULL
  AND ($2 = '' OR c.status = $2)
  AND ($3 = '' OR c.name ILIKE '%' || $3 || '%')
GROUP BY c.id
ORDER BY c.created_at DESC
LIMIT $4 OFFSET $5;
```

## Checklist (Subtasks)

- [ ] Implement list campaigns endpoint
- [ ] Implement pagination logic
- [ ] Implement status filter
- [ ] Implement date range filter
- [ ] Implement search
- [ ] Implement sorting
- [ ] Add impressions count (join with billing)
- [ ] Unit tests
- [ ] Performance test với large dataset

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
