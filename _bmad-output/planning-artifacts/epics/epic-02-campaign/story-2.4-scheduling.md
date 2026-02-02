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
clickup_task_id: null
---

# Campaign Scheduling Engine

## User Story

**As a** System,
**I want** tự động start/stop campaigns theo schedule,
**So that** campaigns chạy đúng thời gian đã đặt.

## Acceptance Criteria

- [ ] Campaigns với start_date = today và status = scheduled tự động chuyển sang running
- [ ] Campaigns với end_date = today và status = running tự động chuyển sang completed
- [ ] Kafka event `campaign.started` được publish khi campaign starts
- [ ] Kafka event `campaign.completed` được publish khi campaign ends
- [ ] Scheduler job chạy mỗi phút
- [ ] Timezone handling đúng

## Technical Notes

**Scheduler Implementation:**
```go
// Cron job chạy mỗi phút
func (s *Scheduler) Run() {
    ticker := time.NewTicker(1 * time.Minute)
    for range ticker.C {
        s.processScheduledCampaigns()
        s.processExpiredCampaigns()
    }
}

func (s *Scheduler) processScheduledCampaigns() {
    campaigns := s.repo.FindScheduledCampaignsToStart(time.Now())
    for _, c := range campaigns {
        c.Status = "running"
        s.repo.Update(c)
        s.eventPublisher.Publish("campaign.started", c)
    }
}

func (s *Scheduler) processExpiredCampaigns() {
    campaigns := s.repo.FindRunningCampaignsToEnd(time.Now())
    for _, c := range campaigns {
        c.Status = "completed"
        s.repo.Update(c)
        s.eventPublisher.Publish("campaign.completed", c)
    }
}
```

**SQL Queries:**
```sql
-- Find campaigns to start
SELECT * FROM campaigns
WHERE status = 'scheduled'
AND start_date <= NOW();

-- Find campaigns to end
SELECT * FROM campaigns
WHERE status = 'running'
AND end_date <= NOW();
```

**Timezone Handling:**
- Store dates in UTC
- Convert to user timezone for display
- Scheduler operates in UTC

**Kafka Events:**
```json
{
    "event": "campaign.started",
    "campaign_id": "uuid",
    "advertiser_id": "uuid",
    "timestamp": "2026-02-02T10:00:00Z"
}
```

## Checklist (Subtasks)

- [ ] Implement scheduler service
- [ ] Implement processScheduledCampaigns
- [ ] Implement processExpiredCampaigns
- [ ] Setup cron job (1 minute interval)
- [ ] Implement Kafka event publishing
- [ ] Handle timezone correctly
- [ ] Add logging for scheduler actions
- [ ] Handle edge cases (campaigns spanning midnight)
- [ ] Unit tests cho scheduler logic
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
