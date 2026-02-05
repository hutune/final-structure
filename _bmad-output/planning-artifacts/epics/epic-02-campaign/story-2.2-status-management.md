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
**I want** to control when my campaigns run through clear status actions,
**So that** I can pause campaigns that aren't performing and resume them when ready.

## Business Context

Advertisers need granular control over their campaigns without losing budget. The status system:
- Allows pausing/resuming without losing targeting setup
- Provides clear visibility into what state the campaign is in
- Ensures budget is protected (held when paused, refunded when cancelled)

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### State Machine
```
DRAFT ──submit──→ PENDING_APPROVAL ──approve──→ SCHEDULED
              ↓                             ↓
           REJECTED              (auto at start_date)
                                          ↓
                                       ACTIVE
                                     ↙    ↘
                               (pause)   (auto at end_date)
                                  ↓          ↓
                               PAUSED    COMPLETED
                                  ↓
                              (resume)
                                  ↓
                               ACTIVE
                                  
─────── ANY (except COMPLETED) ──cancel──→ CANCELLED
```

### Valid Transitions & Effects
| Action | From | To | Wallet Effect |
|--------|------|-----|---------------|
| **Submit** | DRAFT | PENDING/SCHEDULED | Hold budget |
| **Approve** | PENDING_APPROVAL | SCHEDULED | None |
| **Reject** | PENDING_APPROVAL | REJECTED | Release budget |
| **Start** (auto) | SCHEDULED | ACTIVE | None |
| **Pause** | ACTIVE | PAUSED | Keep held |
| **Resume** | PAUSED | ACTIVE | None |
| **Complete** (auto) | ACTIVE | COMPLETED | Release unused |
| **Cancel** | Any | CANCELLED | Refund remaining |

### Approval Requirements
Requires admin approval if:
- Content flagged: ALCOHOL, TOBACCO, GAMBLING, ADULT
- Budget > $10,000

## Acceptance Criteria

### For Advertisers
- [ ] "Submit" button visible only for DRAFT campaigns
- [ ] "Pause" button visible only for ACTIVE campaigns
- [ ] "Resume" button visible only for PAUSED campaigns
- [ ] "Cancel" button visible for all except COMPLETED
- [ ] Status badge shows current state with color coding
- [ ] Email notification on every status change

### For State Machine
- [ ] Invalid transitions return 400 with clear message
- [ ] Status timestamp recorded (activated_at, paused_at, etc.)
- [ ] Kafka event published for every transition

### For Budget
- [ ] Budget held on submit
- [ ] Budget released on reject/cancel
- [ ] Remaining budget released on completion

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
POST /api/v1/campaigns/{id}/submit    # DRAFT → PENDING/SCHEDULED
POST /api/v1/campaigns/{id}/pause     # ACTIVE → PAUSED
POST /api/v1/campaigns/{id}/resume    # PAUSED → ACTIVE
POST /api/v1/campaigns/{id}/cancel    # Any → CANCELLED

# Admin only
POST /api/v1/campaigns/{id}/approve   # PENDING → SCHEDULED
POST /api/v1/campaigns/{id}/reject    # PENDING → REJECTED
```

**Kafka Events:**
- `campaign.submitted`
- `campaign.approved`
- `campaign.rejected`
- `campaign.started`
- `campaign.paused`
- `campaign.resumed`
- `campaign.completed`
- `campaign.cancelled`

</details>

## Checklist (Subtasks)

- [ ] Implement FSM (Finite State Machine) pattern
- [ ] Implement submit with approval check
- [ ] Implement pause/resume endpoints
- [ ] Implement cancel with budget refund
- [ ] Admin endpoints for approve/reject
- [ ] Kafka event publishing
- [ ] Email notifications on transitions
- [ ] Unit tests for all transitions
- [ ] Test invalid transition handling

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:35** - Rewrote with state machine diagram and wallet effects from business rules.
