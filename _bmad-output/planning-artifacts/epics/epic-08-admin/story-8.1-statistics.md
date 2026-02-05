---
id: "STORY-8.1"
epic_id: "EPIC-008"
title: "Platform Statistics Dashboard"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "admin", "statistics", "dashboard"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm85"
---

# Platform Statistics Dashboard

## User Story

**As a** Platform Admin,
**I want** to see real-time platform health and business metrics,
**So that** I can monitor operations and make data-driven decisions.

## Business Context

Platform statistics help business operations:
- Monitor overall platform health
- Track business growth (users, revenue)
- Identify issues early (offline devices, pending approvals)
- Report to stakeholders

## Business Rules

### Key Metrics
| Category | Metrics |
|----------|---------|
| Users | Total, by role, new today |
| Campaigns | Total, active, pending approval |
| Impressions | Today, this week, this month |
| Revenue | Today, week, month, platform share |
| Devices | Total, online, offline, online rate |

### Revenue Breakdown
- **Platform share:** 20% of all impression revenue
- **Advertiser spend:** Total charged to advertisers
- **Supplier earned:** Total paid to suppliers (80%)

### Refresh Rates
| Dashboard Section | Refresh |
|-------------------|---------|
| Overview | Every 5 min |
| Real-time metrics | Every 30 sec |
| Trends | Hourly |

## Acceptance Criteria

### For Overview Dashboard
- [ ] Total users (advertisers vs suppliers)
- [ ] New users today
- [ ] Active campaigns
- [ ] Pending approvals (campaigns + content)
- [ ] Device online rate

### For Financial Metrics
- [ ] Revenue today/week/month
- [ ] Platform revenue share
- [ ] Top advertisers by spend
- [ ] Top suppliers by earnings

### For Trends
- [ ] 30-day chart: impressions, revenue
- [ ] Compare to previous period
- [ ] Export to CSV

### For Alerts
- [ ] Alert when device online rate < 90%
- [ ] Alert when pending queue > 100 items
- [ ] Alert when revenue drops > 20% vs yesterday

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET /api/v1/admin/stats/overview
GET /api/v1/admin/stats/trends?period=30d
GET /api/v1/admin/stats/realtime
GET /api/v1/admin/stats/alerts
```

**Pre-aggregation:**
- Daily stats aggregated by cron job at midnight
- Current day stats calculated real-time
- Cache overview for 5 min

</details>

## Checklist (Subtasks)

- [ ] Create daily stats aggregation table
- [ ] Implement aggregation cron job
- [ ] Implement Overview endpoint
- [ ] Implement Trends endpoint
- [ ] Implement Real-time endpoint
- [ ] Implement Alerts endpoint
- [ ] Add caching (Redis)
- [ ] Unit tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:26** - Rewrote with key metrics, revenue breakdown, and refresh rates for admin dashboard.
