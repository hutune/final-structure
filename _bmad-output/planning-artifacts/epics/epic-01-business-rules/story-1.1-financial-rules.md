---
id: "STORY-1.1"
epic_id: "EPIC-001"
title: "Financial & Billing Rules"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["business-rules", "billing", "wallet", "escrow"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Financial & Billing Rules

## Purpose

Define all financial rules that govern money flow in the platform.

## Business Rules Overview

> Reference: [07-business-rules-wallet.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/07-business-rules-wallet.md)

### Wallet System
| Wallet Type | Owner | Purpose |
|-------------|-------|---------|
| Advertiser | Advertiser | Pre-pay for campaigns |
| Supplier | Supplier | Receive revenue share |
| Platform | System | Hold 20% platform fee |
| Escrow | System | Hold during 7-day period |

### Revenue Split
```
Impression Revenue: $1.00
├── Platform: $0.20 (20%)
└── Supplier: $0.80 (80%)
```

### 7-Day Hold Period
- Revenue holds in escrow for 7 days
- Purpose: Fraud detection, dispute resolution
- After 7 days: Auto-release to Supplier wallet
- If disputed: Freeze until resolution

### Billing Events
| Event | Trigger | Action |
|-------|---------|--------|
| Deposit | Advertiser payment | Credit to Advertiser wallet |
| Charge | Verified impression | Debit from Advertiser wallet |
| Hold | Daily settlement | Move to Escrow |
| Release | 7 days passed | Transfer Escrow → Supplier |
| Refund | Dispute resolved | Credit back to Advertiser |

### Auto-Suspend
- **Warning:** Balance < 2 days projected spend
- **Suspend:** Balance reaches $0
- **Grace period:** 1 hour after $0
- **Resume:** Auto-resume when topped up

### Withdrawal Rules
| Tier | Min Amount | Fee | Timing |
|------|------------|-----|--------|
| Standard | $50 | 2% | 3-5 days |
| Fast | $50 | 3% | Same day |

## Acceptance Criteria

- [ ] All financial transactions logged immutably
- [ ] No negative balances allowed
- [ ] Escrow logic enforced in all scenarios
- [ ] Audit trail for every money movement

## Checklist (Subtasks)

- [ ] Document wallet state machine
- [ ] Document all transaction types
- [ ] Define escrow release criteria
- [ ] Define refund procedures
- [ ] Review with finance team

## Updates

**2026-02-05 09:37** - Created as business rules story consolidating wallet and billing rules.
