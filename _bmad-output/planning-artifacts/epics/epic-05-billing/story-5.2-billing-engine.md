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
clickup_task_id: "86ewgdm6y"
---

# Impression-Based Billing Engine

## User Story

**As an** Advertiser,
**I want** my campaigns to be charged accurately based on actual ad plays,
**So that** I only pay for verified impressions and can trust the billing.

## Business Context

The platform uses a **Cost-Per-Mille (CPM) billing model** where advertisers pay per 1,000 verified impressions. Each impression must pass a verification pipeline to ensure authenticity before billing.

> Reference: [06-business-rules-impression.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/06-business-rules-impression.md)

## Business Rules

### Impression Recording Criteria
| Requirement | Rule | Rejection Reason |
|-------------|------|------------------|
| **Minimum playback** | Content played ≥ 80% of duration | `INSUFFICIENT_DURATION` |
| **Timestamp validity** | Within 10 minutes of server time | `TIMESTAMP_OUT_OF_BOUNDS` |
| **Device status** | Device ACTIVE with heartbeat < 10 min | `DEVICE_OFFLINE` |
| **Campaign status** | Campaign ACTIVE with remaining budget | `CAMPAIGN_NOT_ACTIVE` |

### Verification Pipeline (Sequential)
1. **Signature verification** (~10ms) - Device RSA signature check
2. **Timestamp validation** (~5ms) - Clock skew detection
3. **Campaign status** (~20ms) - Active and funded check
4. **Device status** (~15ms) - Online and at correct store
5. **Duplicate check** (~30ms) - 5-minute window deduplication
6. **Proof-of-play** (~50ms) - Screenshot hash and location

### Cost Calculation
```
impression_cost = CPM_rate / 1000

Example: CPM = $5.00
Per impression = $5.00 / 1000 = $0.005
```

### Duplicate Detection
- **5-minute window:** Same campaign + device + time bucket = duplicate
- **1-hour frequency:** Flag if impressions > 1.5× expected rate
- **24-hour patterns:** Flag robotic/machine-like timing

### Quality Scoring (0-100)
- **PREMIUM (80-100):** Full rate
- **STANDARD (60-79):** Full rate
- **BASIC (40-59):** 80% rate
- **POOR (0-39):** Not billable

## Acceptance Criteria

### For Advertisers
- [ ] Dashboard shows **verified vs rejected impressions** breakdown
- [ ] Rejection reasons visible with counts (e.g., "15 rejected: Device Offline")
- [ ] Real-time impression counter updates within 5 seconds
- [ ] Billing history shows cost per impression with proof availability

### For Billing Accuracy
- [ ] Impressions are **only charged after verification passes**
- [ ] Duplicate impressions rejected (5-minute window)
- [ ] Budget deduction happens atomically with impression recording
- [ ] No billing if campaign paused/ended during playback

### For Fraud Prevention
- [ ] Device signature verified using RSA public key
- [ ] Timestamp drift > 10 minutes flagged for review
- [ ] GPS location validation (if available) within 5km of store
- [ ] Abnormal frequency patterns held for manual review

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Kafka Consumer:**
- Topic: `playback-logs`
- Consumer Group: `billing-engine`
- Partition by: `device_id` (ordering guarantee)

**Verification Pipeline:**
```go
func (e *BillingEngine) ProcessImpression(log PlaybackLog) error {
    // 1. Verify signature
    if !e.verifySignature(log) {
        return reject("INVALID_SIGNATURE")
    }
    
    // 2. Validate timestamp
    if drift := e.calculateTimeDrift(log); drift > 10*time.Minute {
        return reject("TIMESTAMP_OUT_OF_BOUNDS")
    }
    
    // 3. Check campaign status
    campaign := e.getCampaign(log.CampaignID)
    if campaign.Status != "ACTIVE" {
        return reject("CAMPAIGN_NOT_ACTIVE")
    }
    
    // 4. Check duplicate
    if e.isDuplicate(log) {
        return reject("DUPLICATE_IMPRESSION")
    }
    
    // 5. Calculate and charge
    cost := campaign.CPMRate.Div(1000)
    e.chargeBudget(campaign, cost)
    
    return nil
}
```

**Idempotency:** Use `playback_log_id` as unique key to prevent double billing.

</details>

## Checklist (Subtasks)

- [ ] Setup Kafka consumer for playback-logs topic
- [ ] Implement signature verification (RSA-SHA256)
- [ ] Implement timestamp validation with drift tracking
- [ ] Implement 5-minute duplicate detection (Redis)
- [ ] Implement cost calculation with quality multiplier
- [ ] Implement atomic budget deduction
- [ ] Implement rejection reason logging
- [ ] Add fraud detection flags
- [ ] Unit tests for verification pipeline
- [ ] Load test for 10,000 impressions/second

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:20** - Rewrote with business rules from 06-business-rules-impression.md. Added verification pipeline, quality scoring, and fraud detection.
