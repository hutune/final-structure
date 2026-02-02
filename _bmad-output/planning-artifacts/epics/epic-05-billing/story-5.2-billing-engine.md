---
id: "STORY-5.2"
epic_id: "EPIC-005"
title: "Impression-Based Billing Engine"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "billing", "impression", "kafka"]
story_points: 8
sprint: null
start_date: null
due_date: null
time_estimate: "3d"
clickup_task_id: null
---

# Impression-Based Billing Engine

## User Story

**As a** System,
**I want** tính phí dựa trên impressions từ playback logs,
**So that** advertisers bị charge chính xác theo usage.

## Acceptance Criteria

- [ ] Kafka consumer xử lý playback logs
- [ ] Cost = CPM_price / 1000 cho mỗi impression
- [ ] Campaign budget và wallet balance được trừ
- [ ] Billing record được tạo cho mỗi impression
- [ ] Handle partial charges khi budget gần hết

## Technical Notes

**Kafka Consumer:**
- Topic: `playback-logs`
- Consumer Group: `billing-engine`

**Billing Flow:**
```
Playback Log Event
       ↓
Billing Engine Consumer
       ↓
Calculate Cost (CPM/1000)
       ↓
Check Campaign Budget
       ↓
Deduct from Budget & Wallet
       ↓
Create Billing Record
       ↓
Publish billing.processed event
```

**Database Table:**
```sql
CREATE TABLE billing_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id),
    device_id UUID NOT NULL,
    store_id UUID NOT NULL,
    playback_log_id VARCHAR(100) NOT NULL,
    impressions INT DEFAULT 1,
    cost DECIMAL(12,4) NOT NULL,
    cpm_rate DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_billing_campaign ON billing_records(campaign_id);
CREATE INDEX idx_billing_created ON billing_records(created_at);
```

**Cost Calculation:**
```go
func (e *BillingEngine) CalculateCost(log PlaybackLog) decimal.Decimal {
    campaign := e.campaignRepo.Get(log.CampaignID)
    cpmRate := e.getCPMRate(campaign, log.StoreID)
    cost := cpmRate.Div(decimal.NewFromInt(1000))
    return cost
}
```

**Partial Charge Logic:**
```go
func (e *BillingEngine) ProcessBilling(log PlaybackLog) error {
    cost := e.CalculateCost(log)
    campaign := e.campaignRepo.Get(log.CampaignID)

    remainingBudget := campaign.Budget.Sub(campaign.Spent)
    if cost.GreaterThan(remainingBudget) {
        cost = remainingBudget // Partial charge
    }

    // Deduct from campaign and wallet
    e.deductBudget(campaign, cost)
    e.deductWallet(campaign.AdvertiserID, cost)

    // Create billing record
    e.createBillingRecord(log, cost)

    return nil
}
```

## Checklist (Subtasks)

- [ ] Setup Kafka consumer
- [ ] Implement cost calculation
- [ ] Implement budget deduction
- [ ] Implement wallet deduction
- [ ] Create billing records
- [ ] Handle partial charges
- [ ] Idempotency (prevent double billing)
- [ ] Error handling và retry logic
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
