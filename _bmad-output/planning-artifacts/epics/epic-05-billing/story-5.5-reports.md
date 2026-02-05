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

**As an** Advertiser,
**I want** to view detailed reports on my advertising spend,
**So that** I can analyze campaign ROI and optimize future budgets.

**As a** Supplier,
**I want** to view my revenue history and earnings breakdown,
**So that** I can track income and plan for withdrawals.

## Business Context

Transparent billing builds trust:
- **Advertisers** need spend visibility for budget planning and accounting
- **Suppliers** need revenue tracking for business decisions
- Both need export capabilities for tax/accounting purposes

## Acceptance Criteria

### For Advertisers
- [ ] View **billing history** with date range filter
- [ ] See breakdown by: campaign, store, day
- [ ] View rejected impressions with reasons
- [ ] Download monthly **invoice PDF**
- [ ] Export transaction history to **CSV**

### For Suppliers
- [ ] View **revenue history** with date range filter
- [ ] See breakdown by: store, campaign category, day
- [ ] View held vs settled revenue
- [ ] See upcoming settlement schedule
- [ ] Export earnings report for tax purposes

### Report Data
| Report Type | Advertiser | Supplier |
|-------------|------------|----------|
| Daily summary | ✓ | ✓ |
| Campaign breakdown | ✓ | - |
| Store breakdown | ✓ | ✓ |
| Rejection reasons | ✓ | - |
| Settlement schedule | - | ✓ |

### Data Accuracy
- [ ] Reports match wallet transactions exactly
- [ ] Real-time data (< 1 minute delay)
- [ ] Historical data available for 12 months

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
# Advertiser
GET /api/v1/billing/history?from=2026-01-01&to=2026-01-31
GET /api/v1/billing/report/campaign/{id}
GET /api/v1/billing/summary?period=monthly
GET /api/v1/billing/export?format=csv

# Supplier
GET /api/v1/revenue/history?from=2026-01-01&to=2026-01-31
GET /api/v1/revenue/report/store/{id}
GET /api/v1/revenue/summary?period=monthly
GET /api/v1/revenue/settlement-schedule
GET /api/v1/revenue/export?format=csv
```

**Performance Considerations:**
- Pre-aggregate daily summaries in materialized views
- Cache reports for 5 minutes
- Paginate transaction lists (max 100 per page)

</details>

## Checklist (Subtasks)

- [ ] Implement billing history endpoint with filtering
- [ ] Implement campaign report with store breakdown
- [ ] Implement monthly summary aggregation
- [ ] Implement revenue history endpoint (suppliers)
- [ ] Implement settlement schedule view
- [ ] Add CSV export functionality
- [ ] Add PDF invoice generation (Phase 2)
- [ ] Create materialized views for aggregations
- [ ] Add caching layer
- [ ] Unit/integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:25** - Rewrote to cover both Advertiser and Supplier perspectives with specific report types.
