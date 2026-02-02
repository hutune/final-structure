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
clickup_task_id: null
---

# Auto-Suspend on Budget Depletion

## User Story

**As a** System,
**I want** tự động dừng campaign khi hết ngân sách,
**So that** advertisers không bị charge quá budget.

## Acceptance Criteria

- [ ] Campaign tự động pause khi remaining_budget <= 0
- [ ] Kafka event `campaign.budget_exhausted` được publish
- [ ] Notification được gửi cho advertiser
- [ ] Campaign có thể resume sau khi top up budget

## Technical Notes

**Auto-Suspend Flow:**
```
Billing Engine processes impression
       ↓
Check remaining budget
       ↓
If budget <= 0:
  - Update campaign status to "paused"
  - Set pause_reason = "budget_exhausted"
  - Publish campaign.budget_exhausted event
  - Send notification to advertiser
```

**Implementation:**
```go
func (e *BillingEngine) checkBudgetExhaustion(campaign *Campaign) {
    remaining := campaign.Budget.Sub(campaign.Spent)
    if remaining.LessThanOrEqual(decimal.Zero) {
        campaign.Status = "paused"
        campaign.PauseReason = "budget_exhausted"
        e.campaignRepo.Update(campaign)

        e.eventPublisher.Publish("campaign.budget_exhausted", map[string]interface{}{
            "campaign_id": campaign.ID,
            "advertiser_id": campaign.AdvertiserID,
            "budget": campaign.Budget,
            "spent": campaign.Spent,
        })

        e.notificationService.Send(campaign.AdvertiserID, Notification{
            Type: "budget_exhausted",
            Title: "Campaign Paused - Budget Exhausted",
            Body: fmt.Sprintf("Your campaign '%s' has been paused due to budget exhaustion.", campaign.Name),
        })
    }
}
```

**Resume After Topup:**
```go
func (s *CampaignService) AddBudget(campaignID string, amount decimal.Decimal) error {
    campaign := s.repo.Get(campaignID)
    campaign.Budget = campaign.Budget.Add(amount)

    // Can resume if previously exhausted
    if campaign.Status == "paused" && campaign.PauseReason == "budget_exhausted" {
        // Allow resume via separate endpoint
    }

    return s.repo.Update(campaign)
}
```

## Checklist (Subtasks)

- [ ] Implement budget exhaustion check in billing engine
- [ ] Update campaign status to paused
- [ ] Publish Kafka event
- [ ] Implement notification service integration
- [ ] Add pause_reason field to campaigns
- [ ] Implement Add Budget endpoint
- [ ] Allow resume after budget added
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
