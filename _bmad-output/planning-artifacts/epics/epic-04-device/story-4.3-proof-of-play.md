---
id: "STORY-4.3"
epic_id: "EPIC-004"
title: "Proof-of-Play Generation"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "device", "proof-of-play", "aggregation"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmdf"
---

# Proof-of-Play Generation

## User Story

**As a** System,
**I want** tạo proof-of-play từ playback logs,
**So that** có bằng chứng cho billing và giải quyết tranh chấp.

## Acceptance Criteria

- [ ] Daily aggregation job tạo proof-of-play records
- [ ] Proof-of-play chứa: total impressions, unique devices, hourly breakdown
- [ ] GET `/api/v1/campaigns/{id}/proof-of-play` trả về report
- [ ] Records là immutable cho audit trail
- [ ] Geographic distribution được include

## Technical Notes

**API Endpoint:**
```
GET /api/v1/campaigns/{id}/proof-of-play?date=2026-02-02
GET /api/v1/campaigns/{id}/proof-of-play?from=2026-02-01&to=2026-02-28
```

**Database Table:**
```sql
CREATE TABLE proof_of_play (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id),
    date DATE NOT NULL,
    total_impressions INT DEFAULT 0,
    unique_devices INT DEFAULT 0,
    unique_stores INT DEFAULT 0,
    total_duration_seconds INT DEFAULT 0,
    hourly_breakdown JSONB,
    geographic_breakdown JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(campaign_id, date)
);

CREATE INDEX idx_pop_campaign_date ON proof_of_play(campaign_id, date);
```

**Hourly Breakdown Format:**
```json
{
    "00": 150,
    "01": 120,
    "09": 890,
    "10": 1200,
    "18": 1500,
    "19": 1800
}
```

**Geographic Breakdown:**
```json
{
    "regions": {
        "Ho Chi Minh": 5000,
        "Ha Noi": 3000,
        "Da Nang": 1000
    },
    "stores": [
        {"store_id": "uuid", "name": "Store A", "impressions": 2000}
    ]
}
```

**Daily Aggregation Job:**
```go
func (s *ProofOfPlayService) GenerateDaily(date time.Time) {
    campaigns := s.campaignRepo.FindRunningOnDate(date)
    for _, c := range campaigns {
        logs := s.playbackRepo.GetLogsByCampaignAndDate(c.ID, date)
        pop := s.aggregate(logs)
        s.popRepo.Create(pop)
    }
}
```

## Checklist (Subtasks)

- [ ] Tạo proof_of_play table migration
- [ ] Implement aggregation logic
- [ ] Setup daily cron job (midnight)
- [ ] Implement Get Proof-of-Play endpoint
- [ ] Implement date range queries
- [ ] Add geographic breakdown
- [ ] Ensure immutability (no updates)
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
