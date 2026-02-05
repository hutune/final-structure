---
id: "STORY-1.2"
epic_id: "EPIC-001"
title: "Campaign Lifecycle Rules"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["business-rules", "campaign", "lifecycle", "state-machine"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Campaign Lifecycle Rules

## Purpose

Define all rules governing campaign creation, approval, execution, and completion.

## Business Rules Overview

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Campaign State Machine
```
DRAFT → PENDING_APPROVAL → SCHEDULED → ACTIVE → COMPLETED
           ↓                    ↓          ↓
        REJECTED             PAUSED     CANCELLED
```

### Campaign Validation
| Rule | Requirement |
|------|-------------|
| Minimum Budget | $100 |
| Lead Time | 24 hours before start |
| Content Required | At least 1 approved content |
| Stores Required | At least 1 store targeted |
| Duration | Max 365 days |

### Approval Rules
- All campaigns require platform approval
- SLA: 24 hours for standard, 4 hours for enterprise
- Auto-reject if content not approved

### Scheduling Rules
| Timing | Rule |
|--------|------|
| Start | No earlier than 24h from submission |
| End | Must be after start |
| Timezone | Based on store location |
| Operating hours | Ads only during store hours |

### Budget Rules
- Daily budget = Total / Days
- Minimum daily: $10
- Overspend protection: Pause at 110% daily
- Underspend: Roll to next day (optional)

### Targeting Rules
| Method | Description |
|--------|-------------|
| All Stores | Target all available |
| Region | By city/state |
| Store Type | By category (grocery, retail) |
| Include List | Specific store IDs |
| Exclude List | Specific store IDs |

### Competitor Blocking Integration
- Campaign metadata (brand, category) matched against store rules
- Conflicting stores auto-excluded
- Reach estimate adjusted

## Acceptance Criteria

- [ ] State machine enforced in all transitions
- [ ] Validation fails prevent submission
- [ ] Approval workflow logged
- [ ] Scheduling respects all timing rules

## Checklist (Subtasks)

- [ ] Document state machine diagram
- [ ] Define validation rules clearly
- [ ] Define approval SLAs
- [ ] Define targeting combinations
- [ ] Review with product team

## Updates

**2026-02-05 09:37** - Created as business rules story for campaign lifecycle.
