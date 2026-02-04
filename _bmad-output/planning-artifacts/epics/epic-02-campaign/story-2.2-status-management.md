---
id: "STORY-2.2"
epic_id: "EPIC-002"
title: "Campaign Status Management"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "campaign", "status", "state-machine"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmgb"
---

# Campaign Status Management

## User Story

**As an** Advertiser,
**I want** thay đổi trạng thái campaign (submit, pause, resume, cancel),
**So that** tôi có thể kiểm soát khi nào campaign chạy.

## Acceptance Criteria

- [ ] POST `/api/v1/campaigns/{id}/submit` chuyển draft → pending_approval/scheduled
- [ ] POST `/api/v1/campaigns/{id}/pause` chuyển running → paused
- [ ] POST `/api/v1/campaigns/{id}/resume` chuyển paused → running
- [ ] POST `/api/v1/campaigns/{id}/cancel` chuyển any → cancelled
- [ ] Invalid state transitions bị reject với 400 Bad Request
- [ ] Kafka events được publish cho mỗi transition

## Technical Notes

**API Endpoints:**
```
POST /api/v1/campaigns/{id}/submit
POST /api/v1/campaigns/{id}/pause
POST /api/v1/campaigns/{id}/resume
POST /api/v1/campaigns/{id}/cancel
```

**State Machine:**
```
draft → pending_approval → scheduled → running → completed
  │           │              │          │
  │           │              │          └→ paused → running
  │           │              │                │
  └───────────┴──────────────┴────────────────┴→ cancelled
```

**Valid Transitions:**
| From | To | Action |
|------|-----|--------|
| draft | pending_approval | submit (if requires approval) |
| draft | scheduled | submit (if no approval needed) |
| pending_approval | scheduled | approve (admin) |
| pending_approval | draft | reject (admin) |
| scheduled | running | scheduler (auto on start_date) |
| running | paused | pause |
| running | completed | scheduler (auto on end_date) |
| paused | running | resume |
| * (except completed) | cancelled | cancel |

**Kafka Events:**
- `campaign.submitted` - When campaign submitted
- `campaign.approved` - When campaign approved
- `campaign.started` - When campaign starts running
- `campaign.paused` - When campaign paused
- `campaign.resumed` - When campaign resumed
- `campaign.completed` - When campaign completes
- `campaign.cancelled` - When campaign cancelled

## Checklist (Subtasks)

- [ ] Implement state machine pattern
- [ ] Implement submit endpoint
- [ ] Implement pause endpoint
- [ ] Implement resume endpoint
- [ ] Implement cancel endpoint
- [ ] Setup Kafka producer
- [ ] Publish events on state transitions
- [ ] Unit tests cho state machine
- [ ] Test invalid transitions

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
