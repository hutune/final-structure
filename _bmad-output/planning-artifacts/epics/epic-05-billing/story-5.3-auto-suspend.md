---
id: "STORY-5.3"
epic_id: "EPIC-005"
title: "Auto-Suspend on Budget Depletion"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "billing", "auto-suspend", "budget"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm76"
---

# Auto-Suspend on Budget Depletion

## User Story

**As an** Advertiser,
**I want** my campaigns to automatically pause when the budget runs out,
**So that** I never overspend beyond my planned budget.

## Business Context

Budget protection is critical for advertiser trust. When a campaign's budget is exhausted:
- Campaign immediately stops receiving impressions
- Advertiser is notified with clear next steps
- No additional charges occur
- Campaign can resume after budget is added

This prevents "bill shock" and gives advertisers full control over spending.

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Suspension Trigger
- Campaign pauses when `remaining_budget <= 0`
- Status changes: `ACTIVE → PAUSED`
- Pause reason set to `budget_exhausted`

### Timing Guarantee
- **Within 1 minute** of budget exhaustion
- Impressions reported after suspension are rejected
- No billing for rejected impressions

### Low Budget Warning
| Balance Level | Action |
|---------------|--------|
| 20% remaining | Email warning sent |
| 10% remaining | Push notification sent |
| 5% remaining | Urgent alert (email + push) |
| 0% remaining | **Immediate suspension** |

### Resume Conditions
- Advertiser adds budget via top-up
- Campaign can be manually resumed
- Impressions resume within 5 minutes

## Acceptance Criteria

### For Advertisers
- [ ] Receive **low balance warnings** at 20%, 10%, 5% thresholds
- [ ] Campaign **pauses within 1 minute** of budget exhaustion
- [ ] Dashboard shows clear "Budget Exhausted" status with top-up CTA
- [ ] Email notification includes: amount spent, impressions delivered, top-up link
- [ ] After top-up, can resume campaign with one click

### For Budget Protection
- [ ] No impressions charged after suspension
- [ ] Campaign removed from device playlists within 5 minutes
- [ ] No "overdraft" possible (budget cannot go negative)

### For System
- [ ] `campaign.budget_exhausted` event published to Kafka
- [ ] Event includes: campaign_id, advertiser_id, total_budget, total_spent

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Budget Check (in Billing Engine):**
```go
func (e *BillingEngine) processBilling(impression Impression) error {
    // ... billing logic ...
    
    remaining := campaign.Budget.Sub(campaign.Spent)
    
    // Check low balance warnings
    percentRemaining := remaining.Div(campaign.Budget).Mul(100)
    e.checkLowBalanceAlerts(campaign, percentRemaining)
    
    // Check exhaustion
    if remaining.LessThanOrEqual(decimal.Zero) {
        e.suspendCampaign(campaign, "budget_exhausted")
    }
    
    return nil
}
```

**Event Schema:**
```json
{
  "event": "campaign.budget_exhausted",
  "campaign_id": "uuid",
  "advertiser_id": "uuid",
  "budget": 1000.00,
  "spent": 1000.00,
  "impressions_delivered": 200000,
  "exhausted_at": "2026-02-04T12:00:00Z"
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement budget exhaustion check in billing engine
- [ ] Implement low balance warning thresholds (20%, 10%, 5%)
- [ ] Update campaign status to paused with reason
- [ ] Publish Kafka event for playlist sync
- [ ] Implement advertiser notifications (email + push)
- [ ] Add "Resume Campaign" endpoint
- [ ] Unit tests for all thresholds
- [ ] Integration test: budget exhaustion → pause → resume

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:25** - Rewrote with business rules. Added low balance warnings, timing guarantees, and resume flow.
