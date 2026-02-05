---
id: "STORY-7.3"
epic_id: "EPIC-007"
title: "Conflict Resolution & Alternatives"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "blocking", "conflict", "alternatives"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm7c"
---

# Conflict Resolution & Alternatives

## User Story

**As an** Advertiser,
**I want** to understand why certain stores are blocked,
**So that** I can find alternative stores to maximize my campaign reach.

## Business Context

Transparency builds trust and helps optimization:
- Advertisers understand exclusion reasons
- Clear explanation of supplier blocking rules
- Alternative store suggestions maintain reach
- No surprises when campaign launches

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Conflict Visibility
| Information | Shown to Advertiser |
|-------------|---------------------|
| Store name | Yes |
| Blocking reason | Yes (general) |
| Rule type | Yes |
| Exact rule value | Partial (e.g., "competitor brand") |

### Alternative Suggestion Criteria
| Factor | Weight |
|--------|--------|
| Same region | 40% |
| Same store type | 30% |
| Similar device count | 20% |
| Similar traffic | 10% |

### Alternative Limits
- Max 10 alternatives per excluded store
- Only show stores without conflicts
- Only show stores in same region by default

## Acceptance Criteria

### For Conflict View
- [ ] View list of excluded stores
- [ ] See exclusion reason for each
- [ ] Know which rule type caused exclusion
- [ ] Total impact on reach shown

### For Alternatives
- [ ] Suggest similar stores without conflicts
- [ ] Show store attributes (region, type, devices)
- [ ] One-click to add alternative to campaign
- [ ] Show similarity score

### For Campaign Optimization
- [ ] Compare reach: original vs after exclusions
- [ ] Compare reach: with alternatives added
- [ ] Help advertisers maximize coverage

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET /api/v1/campaigns/{id}/conflicts
GET /api/v1/campaigns/{id}/alternatives
POST /api/v1/campaigns/{id}/stores/{store_id}  # Add alternative
```

**Conflicts Response:**
```json
{
  "campaign_id": "uuid",
  "total_stores_targeted": 50,
  "total_stores_excluded": 5,
  "reach_impact": "-10%",
  "excluded_stores": [
    {
      "store_id": "uuid",
      "store_name": "Samsung Store Le Loi",
      "region": "Ho Chi Minh",
      "conflict_type": "brand",
      "conflict_reason": "Store blocks competitor brand"
    }
  ]
}
```

**Alternatives Response:**
```json
{
  "alternatives": [
    {
      "store_id": "uuid",
      "store_name": "Electronics Mall Nguyen Hue",
      "region": "Ho Chi Minh",
      "store_type": "mall",
      "device_count": 5,
      "similarity_score": 0.85
    }
  ]
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement Get Conflicts endpoint
- [ ] Include conflict reasons
- [ ] Calculate reach impact
- [ ] Implement alternative suggestion algorithm
- [ ] Calculate similarity scores
- [ ] Implement add alternative endpoint
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:24** - Rewrote with conflict visibility rules and alternative suggestion criteria from campaign business rules.
