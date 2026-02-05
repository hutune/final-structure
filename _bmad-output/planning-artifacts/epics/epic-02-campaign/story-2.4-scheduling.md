---
id: "STORY-2.4"
epic_id: "EPIC-002"
title: "Campaign Scheduling Engine"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "campaign", "scheduler", "cron"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmh3"
---

# Campaign Scheduling Engine

## User Story

**As an** Advertiser,
**I want** my campaigns to automatically start and stop at the scheduled times,
**So that** I don't have to manually manage campaign timing.

## Business Context

Reliable scheduling is crucial for advertiser trust:
- Campaigns must start exactly at the scheduled time
- End dates must be respected to prevent over-delivery
- Advertisers plan marketing around precise timing

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Auto-Start Rules
- Campaign transitions: `SCHEDULED → ACTIVE` at `start_date`
- Checked every **1 minute**
- Content pre-distributed to devices **24 hours before** start

### Auto-Complete Rules
- Campaign transitions: `ACTIVE → COMPLETED` at `end_date`
- Unused budget automatically released to wallet
- Final impression count locked

### Timezone Handling
- All dates stored in **UTC**
- Displayed in advertiser's local timezone
- Scheduler operates in UTC

### Content Pre-Distribution
```
24 hours before start_date:
  1. Compile playlist for each device
  2. Push content to devices
  3. Devices cache content locally
  4. Confirm ready status
```

## Acceptance Criteria

### For Advertisers
- [ ] Campaign starts within **1 minute** of scheduled start_date
- [ ] Campaign ends at exact end_date (no extra impressions after)
- [ ] Email notification when campaign starts
- [ ] Email notification when campaign ends with summary

### For System
- [ ] Scheduler runs every minute with high availability
- [ ] Kafka events published on transitions
- [ ] Device playlists updated 24 hours before start
- [ ] Unused budget released on completion

### For Reliability
- [ ] Scheduler is idempotent (handles duplicates)
- [ ] Handles timezone edge cases (DST changes)
- [ ] Graceful handling of large batch transitions

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Scheduler Service:**
```go
func (s *Scheduler) Run() {
    ticker := time.NewTicker(1 * time.Minute)
    for range ticker.C {
        s.startScheduledCampaigns()
        s.completeExpiredCampaigns()
        s.preDistributeContent() // 24h before
    }
}
```

**Queries:**
```sql
-- Campaigns to start
SELECT * FROM campaigns
WHERE status = 'SCHEDULED'
AND start_date <= NOW();

-- Campaigns to complete
SELECT * FROM campaigns  
WHERE status = 'ACTIVE'
AND end_date <= NOW();

-- Pre-distribution (24h window)
SELECT * FROM campaigns
WHERE status = 'SCHEDULED'
AND start_date BETWEEN NOW() AND NOW() + INTERVAL '24 hours'
AND content_distributed = false;
```

</details>

## Checklist (Subtasks)

- [ ] Implement scheduler service
- [ ] Implement auto-start logic
- [ ] Implement auto-complete with budget release
- [ ] Implement content pre-distribution (24h before)
- [ ] Setup 1-minute cron job
- [ ] Handle timezone correctly (UTC storage)
- [ ] Kafka event publishing
- [ ] Email notifications on transitions
- [ ] Unit tests for scheduler
- [ ] Integration tests with mock clock

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:08** - Rewrote with timing guarantees, pre-distribution, and timezone handling from business rules.
