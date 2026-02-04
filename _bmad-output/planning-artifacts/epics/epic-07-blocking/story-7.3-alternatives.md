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
clickup_task_id: null
---

# Conflict Resolution & Alternatives

## User Story

**As an** Advertiser,
**I want** xem stores bị block và được đề xuất alternatives,
**So that** tôi có thể tối ưu reach của campaign.

## Acceptance Criteria

- [ ] GET `/api/v1/campaigns/{id}/conflicts` trả về excluded stores
- [ ] Mỗi conflict có reason rõ ràng
- [ ] Suggest alternative stores không có conflict
- [ ] Alternatives có similar attributes (region, type)

## Technical Notes

**API Endpoint:**
```
GET /api/v1/campaigns/{id}/conflicts
```

**Response:**
```json
{
    "campaign_id": "uuid",
    "excluded_stores": [
        {
            "store_id": "uuid",
            "store_name": "Samsung Dealer Le Loi",
            "region": "Ho Chi Minh",
            "store_type": "electronics",
            "conflicts": [
                {
                    "rule_type": "brand",
                    "rule_value": "Apple",
                    "reason": "Store blocks competitor brand 'Apple'"
                }
            ]
        }
    ],
    "alternatives": [
        {
            "store_id": "uuid",
            "store_name": "Electronics Mall Nguyen Hue",
            "region": "Ho Chi Minh",
            "store_type": "mall",
            "similarity_score": 0.85,
            "device_count": 5
        }
    ]
}
```

**Alternative Suggestion Algorithm:**
```go
func (e *BlockingEngine) SuggestAlternatives(campaign *Campaign, excludedStores []Store) []Store {
    var alternatives []Store

    for _, excluded := range excludedStores {
        // Find stores in same region, similar type, no conflicts
        candidates := e.storeRepo.FindByRegionAndType(excluded.Region, excluded.StoreType)

        for _, candidate := range candidates {
            // Skip if already targeted or excluded
            if campaign.HasStore(candidate.ID) {
                continue
            }

            // Check for conflicts
            conflicts := e.CheckConflicts(campaign, []string{candidate.ID})
            if len(conflicts) == 0 {
                alternatives = append(alternatives, candidate)
            }
        }
    }

    // Sort by similarity/relevance
    sort.Sort(BySimilarity(alternatives))

    return alternatives[:min(10, len(alternatives))]
}
```

## Checklist (Subtasks)

- [ ] Implement Get Conflicts endpoint
- [ ] Include conflict reasons
- [ ] Implement alternative suggestion algorithm
- [ ] Find stores by region and type
- [ ] Calculate similarity score
- [ ] Return top 10 alternatives
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
