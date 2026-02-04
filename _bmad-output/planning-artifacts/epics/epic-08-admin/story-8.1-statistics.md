---
id: "STORY-8.1"
epic_id: "EPIC-008"
title: "Platform Statistics Dashboard APIs"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "admin", "statistics", "dashboard"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Platform Statistics Dashboard APIs

## User Story

**As an** Admin,
**I want** xem thống kê tổng quan nền tảng,
**So that** tôi có thể monitor hoạt động platform.

## Acceptance Criteria

- [ ] GET `/api/v1/admin/stats/overview` trả về platform overview
- [ ] Overview includes: users, campaigns, impressions, revenue
- [ ] GET `/api/v1/admin/stats/trends` trả về time-series data
- [ ] Stats refresh hourly hoặc real-time

## Technical Notes

**API Endpoints:**
```
GET /api/v1/admin/stats/overview
GET /api/v1/admin/stats/trends?period=30d
GET /api/v1/admin/stats/realtime
```

**Overview Response:**
```json
{
    "generated_at": "2026-02-02T10:00:00Z",
    "users": {
        "total": 1500,
        "advertisers": 800,
        "suppliers": 700,
        "new_today": 15
    },
    "campaigns": {
        "total": 500,
        "active": 120,
        "pending_approval": 25
    },
    "impressions": {
        "today": 150000,
        "this_week": 1050000,
        "this_month": 4500000
    },
    "revenue": {
        "today": 750.00,
        "this_week": 5250.00,
        "this_month": 22500.00,
        "platform_share": 4500.00
    },
    "devices": {
        "total": 2000,
        "online": 1850,
        "offline": 150,
        "online_rate": 0.925
    }
}
```

**Trends Response:**
```json
{
    "period": "30d",
    "data": [
        {
            "date": "2026-02-01",
            "impressions": 145000,
            "revenue": 725.00,
            "active_campaigns": 115
        }
    ]
}
```

**Pre-aggregation Table:**
```sql
CREATE TABLE platform_stats_daily (
    date DATE PRIMARY KEY,
    total_users INT,
    new_users INT,
    total_campaigns INT,
    active_campaigns INT,
    total_impressions BIGINT,
    total_revenue DECIMAL(12,2),
    online_devices INT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Checklist (Subtasks)

- [ ] Tạo platform_stats_daily table
- [ ] Implement hourly aggregation job
- [ ] Implement Overview endpoint
- [ ] Implement Trends endpoint
- [ ] Implement Realtime endpoint
- [ ] Add caching for frequently accessed stats
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
