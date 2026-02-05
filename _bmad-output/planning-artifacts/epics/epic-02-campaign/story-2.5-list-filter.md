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
clickup_task_id: "86ewgdmgq"
---

# Campaign List & Filtering

## User Story

**As an** Advertiser,
**I want** to easily find and manage my campaigns,
**So that** I can quickly check performance and take action.

## Business Context

Advertisers may have dozens of campaigns over time. An effective campaign list:
- Shows key metrics at a glance (budget, spent, impressions)
- Enables quick filtering by status
- Supports searching for specific campaigns
- Provides fast performance even with many campaigns

## Acceptance Criteria

### Campaign Dashboard
- [ ] Default view shows **Active** campaigns first
- [ ] Quick stats: total active, total spend this month, total impressions
- [ ] Status tabs: All | Active | Scheduled | Paused | Completed | Draft

### Campaign Cards/Rows
| Field | Display |
|-------|---------|
| Name | With status badge |
| Budget | $X / $Y spent (progress bar) |
| Impressions | Count |
| Dates | Start → End |
| Actions | View, Pause/Resume, Edit |

### Filtering & Search
- [ ] Filter by status (multiple select)
- [ ] Filter by date range (start_date)
- [ ] Search by campaign name
- [ ] Sort by: date created, start date, budget, spent, impressions

### Performance
- [ ] Page loads in < 500ms
- [ ] Pagination for lists > 20 campaigns
- [ ] Maximum 100 items per page

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoint:**
```
GET /api/v1/campaigns
  ?status=ACTIVE,SCHEDULED
  &search=summer
  &start_from=2026-01-01
  &start_to=2026-12-31
  &sort=created_at
  &order=desc
  &page=1
  &limit=20
```

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Summer Sale",
      "status": "ACTIVE",
      "budget": 1000.00,
      "spent": 450.00,
      "impressions": 90000,
      "start_date": "2026-03-01",
      "end_date": "2026-03-31",
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

**Performance Tips:**
- Index on (advertiser_id, status, created_at)
- Use COUNT(*) OVER() for total with one query
- Consider materialized view for impression counts

</details>

## Checklist (Subtasks)

- [ ] Implement campaign list endpoint
- [ ] Implement multi-status filtering
- [ ] Implement date range filtering
- [ ] Implement search (ILIKE on name)
- [ ] Implement sorting
- [ ] Implement cursor-based or offset pagination
- [ ] Add impression count (from billing_records)
- [ ] Add database indexes for performance
- [ ] Unit tests
- [ ] Performance test with 1000+ campaigns

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:08** - Rewrote with dashboard view, quick stats, and performance requirements.
