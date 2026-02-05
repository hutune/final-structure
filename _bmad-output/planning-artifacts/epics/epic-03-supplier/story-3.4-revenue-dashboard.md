---
id: "STORY-3.4"
epic_id: "EPIC-003"
title: "Supplier Revenue Dashboard"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "supplier", "revenue", "wallet"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmdu"
---

# Supplier Revenue Dashboard

## User Story

**As a** Supplier,
**I want** to see my earnings and withdraw my revenue,
**So that** I can manage my advertising income and plan my business.

## Business Context

Suppliers earn 80% of impression revenue. The dashboard is their primary tool for:
- Tracking daily/monthly earnings
- Understanding which stores/devices perform best
- Managing withdrawals
- Tax reporting and accounting

## Business Rules

> Reference: [09-business-rules-supplier.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/09-business-rules-supplier.md)

### Revenue Split
```
Impression Revenue = 100%
├── Supplier: 80%
└── Platform: 20%
```

### Balance Types
| Type | Description |
|------|-------------|
| **Held** | Revenue in 7-day hold period |
| **Available** | Released, ready for withdrawal |
| **Processing** | Withdrawal in progress |

### Withdrawal Rules
| Criteria | Requirement |
|----------|-------------|
| Minimum | $50 |
| Maximum | Available balance |
| Processing | 3-5 business days |
| Fees | $5 (< $500), $10 ($500-$5k), $25 (> $5k) |

### Payment Schedule Options
- **Weekly:** Every Monday
- **Biweekly:** Every other Monday
- **Monthly:** 1st of each month

## Acceptance Criteria

### Revenue Dashboard
- [ ] Total earnings this month prominently displayed
- [ ] Available vs Held balance breakdown
- [ ] Revenue chart (daily/weekly/monthly)
- [ ] Best performing stores and devices
- [ ] Upcoming settlement schedule

### Revenue Breakdown
- [ ] Revenue by store with impressions count
- [ ] Revenue by device
- [ ] Revenue by campaign category
- [ ] Historical comparison (vs last month)

### Withdrawals
- [ ] Initiate withdrawal with amount
- [ ] See fee before confirming
- [ ] View withdrawal history with status
- [ ] Cancel pending withdrawal
- [ ] Email notification on status change

### Reporting
- [ ] Export to CSV for accounting
- [ ] Monthly statement PDF
- [ ] Tax summary (annual)

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
# Revenue
GET /api/v1/supplier/revenue/summary
GET /api/v1/supplier/revenue/breakdown?by=store|device
GET /api/v1/supplier/revenue/history?from=...&to=...

# Withdrawals
POST /api/v1/supplier/withdrawals
GET  /api/v1/supplier/withdrawals
GET  /api/v1/supplier/withdrawals/{id}
POST /api/v1/supplier/withdrawals/{id}/cancel

# Reports
GET /api/v1/supplier/reports/statement?month=2026-02
GET /api/v1/supplier/reports/export?format=csv
```

**Fee Calculation:**
```go
func calculateWithdrawalFee(amount decimal.Decimal) decimal.Decimal {
    if amount.LessThan(decimal.NewFromInt(500)) {
        return decimal.NewFromInt(5)
    }
    if amount.LessThan(decimal.NewFromInt(5000)) {
        return decimal.NewFromInt(10)
    }
    return decimal.NewFromInt(25)
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement revenue summary endpoint
- [ ] Implement revenue breakdown (by store, device)
- [ ] Implement revenue history with date range
- [ ] Implement withdrawal request with fee calculation
- [ ] Implement withdrawal history
- [ ] Implement withdrawal cancellation
- [ ] Generate monthly statement PDF
- [ ] CSV export functionality
- [ ] Email notifications on withdrawal status
- [ ] Unit tests for fee calculation
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:12** - Rewrote with balance breakdown, withdrawal fees, and reporting features from business rules.
