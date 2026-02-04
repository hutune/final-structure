---
id: "STORY-5.5"
epic_id: "EPIC-005"
title: "Billing Reports & History"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "billing", "reports", "history"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm6m"
---

# Billing Reports & History

## User Story

**As an** Advertiser/Supplier,
**I want** xem lịch sử billing và reports,
**So that** tôi có thể theo dõi chi tiêu/thu nhập.

## Acceptance Criteria

- [ ] GET `/api/v1/billing/history` trả về billing transactions
- [ ] GET `/api/v1/billing/report` trả về aggregated report
- [ ] Filter theo campaign, date range
- [ ] Pagination support
- [ ] Export CSV/PDF (Phase 2)

## Technical Notes

**API Endpoints:**
```
GET /api/v1/billing/history?from={date}&to={date}&page=1&limit=20
GET /api/v1/billing/report?campaign_id={id}&period=daily
GET /api/v1/billing/summary?period=month
```

**Billing History Response:**
```json
{
    "data": [
        {
            "id": "uuid",
            "campaign_id": "uuid",
            "campaign_name": "Summer Sale",
            "impressions": 1,
            "cost": 0.005,
            "store_name": "Store A",
            "created_at": "2026-02-02T10:30:00Z"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 10000
    }
}
```

**Report Response:**
```json
{
    "campaign_id": "uuid",
    "campaign_name": "Summer Sale",
    "period": "2026-02",
    "summary": {
        "total_impressions": 100000,
        "total_cost": 500.00,
        "avg_cpm": 5.00
    },
    "by_day": [
        {"date": "2026-02-01", "impressions": 5000, "cost": 25.00},
        {"date": "2026-02-02", "impressions": 4500, "cost": 22.50}
    ],
    "by_store": [
        {"store_id": "uuid", "store_name": "Store A", "impressions": 50000, "cost": 250.00}
    ]
}
```

**Summary Response:**
```json
{
    "period": "2026-02",
    "total_spent": 1500.00,
    "total_impressions": 300000,
    "active_campaigns": 5,
    "top_campaigns": [
        {"id": "uuid", "name": "Campaign A", "spent": 500.00}
    ]
}
```

## Checklist (Subtasks)

- [ ] Implement Billing History endpoint
- [ ] Implement Campaign Report endpoint
- [ ] Implement Summary endpoint
- [ ] Add date range filtering
- [ ] Add pagination
- [ ] Optimize queries với indexes
- [ ] Caching for frequently accessed reports
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
