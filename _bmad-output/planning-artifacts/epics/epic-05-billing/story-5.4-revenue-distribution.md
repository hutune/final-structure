---
id: "STORY-5.4"
epic_id: "EPIC-005"
title: "Revenue Distribution to Suppliers"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "billing", "revenue", "supplier"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm68"
---

# Revenue Distribution to Suppliers

## User Story

**As a** Supplier,
**I want** to automatically receive my share of advertising revenue,
**So that** I can earn passive income from my store's advertising screens.

## Business Context

Suppliers provide the physical locations and devices where ads are displayed. They earn **80% of all impression revenue** as compensation. This incentivizes:
- Quality device maintenance
- High-traffic store locations
- Reliable uptime

## Business Rules

> Reference: [07-business-rules-wallet.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/07-business-rules-wallet.md)

### Revenue Split
```
Impression Revenue = 100%
├── Supplier Share = 80%
└── Platform Share = 20%
```

### Revenue Lifecycle

| Stage | Duration | Balance Type | Description |
|-------|----------|--------------|-------------|
| **Credited** | Immediate | Held | Revenue recorded after verified impression |
| **Held** | 7 days | Held | Anti-fraud hold period |
| **Released** | After 7 days | Available | Ready for withdrawal |

### Hold Period Rules
- 7-day hold for fraud protection
- If impression disputed within 7 days → held until resolved
- If chargeback approved → revenue deducted from held balance
- If no dispute → auto-release to available balance

### Withdrawal Fees
| Amount | Fee |
|--------|-----|
| < $500 | $5 |
| $500 - $5,000 | $10 |
| > $5,000 | $25 |

## Acceptance Criteria

### For Suppliers
- [ ] Dashboard shows **available vs held revenue** breakdown
- [ ] Revenue credited within **5 seconds** of verified impression
- [ ] "Held" revenue shows expected release date
- [ ] Revenue history shows: impression source, store, amount, date

### For Revenue Accuracy
- [ ] 80/20 split calculated correctly (auditable)
- [ ] Held balance equals sum of revenues in 7-day window
- [ ] No rounding errors (use Decimal with 4 decimal places)

### For Settlement
- [ ] Daily job releases held revenue older than 7 days
- [ ] Released revenue moves to available balance
- [ ] Supplier notified when significant revenue released

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Revenue Calculation:**
```go
func (s *RevenueService) Distribute(billingRecord *BillingRecord) error {
    supplierShare := billingRecord.Cost.Mul(decimal.NewFromFloat(0.80))
    platformShare := billingRecord.Cost.Mul(decimal.NewFromFloat(0.20))
    
    // Credit to held balance (7-day hold)
    s.walletService.CreditHeldBalance(
        billingRecord.SupplierID, 
        supplierShare,
        "REVENUE",
        billingRecord.ID,
    )
    
    // Schedule release
    s.scheduler.ScheduleRelease(
        billingRecord.SupplierID,
        supplierShare,
        time.Now().Add(7 * 24 * time.Hour),
    )
    
    return nil
}
```

**Daily Settlement Job:**
```go
// Runs daily at 00:00 UTC
func (j *SettlementJob) Run() {
    pendingReleases := j.repo.GetReleasableRevenues(time.Now())
    
    for _, release := range pendingReleases {
        j.walletService.MoveHeldToAvailable(
            release.SupplierID,
            release.Amount,
        )
        j.repo.MarkAsSettled(release.ID)
    }
}
```

</details>

## Checklist (Subtasks)

- [ ] Create revenue_distributions table migration
- [ ] Implement Revenue Distribution Service with 80/20 split
- [ ] Credit supplier held_balance on verified impression
- [ ] Implement 7-day hold period tracking
- [ ] Implement daily settlement job (release to available)
- [ ] Handle disputes: keep held if disputed
- [ ] Handle chargebacks: deduct from held balance
- [ ] Revenue dashboard for suppliers
- [ ] Unit tests for split calculation
- [ ] Integration test: impression → held → release

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:25** - Rewrote with 7-day hold period, dispute handling, and settlement job from wallet business rules.
