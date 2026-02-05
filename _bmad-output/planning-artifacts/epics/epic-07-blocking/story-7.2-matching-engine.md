---
id: "STORY-7.2"
epic_id: "EPIC-007"
title: "Blocking Rules Matching Engine"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "blocking", "matching", "engine"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm7z"
---

# Blocking Rules Matching Engine

## User Story

**As an** Advertiser,
**I want** the system to automatically detect which stores block my brand,
**So that** I don't waste budget targeting stores that won't show my ads.

## Business Context

The matching engine protects all parties:
- Advertisers avoid wasting budget on blocked stores
- Suppliers maintain control over their ad inventory
- Platform ensures campaign reach estimates are accurate
- Automatic exclusion prevents manual errors

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Matching Logic
| Rule Type | Match Logic | Example |
|-----------|-------------|---------|
| Brand | Exact match (case-insensitive) | "Apple" = "apple" ✓ |
| Category | Hierarchy match | "Electronics" blocks "Smartphones" |
| Keyword | Contains (case-insensitive) | "apple" in "Apple iPhone Launch" ✓ |

### When Matching Runs
| Trigger | Action |
|---------|--------|
| Campaign submit | Check all target stores |
| Store added to campaign | Check new store |
| Blocking rule created | Re-check active campaigns |
| Blocking rule deleted | Re-check active campaigns |

### Conflict Resolution
1. Store excluded from campaign targeting
2. Exclusion reason recorded for transparency
3. Advertiser notified of exclusions
4. Reach estimate updated

## Acceptance Criteria

### For Matching
- [ ] Brand matching: exact, case-insensitive
- [ ] Category matching: hierarchical (parent blocks children)
- [ ] Keyword matching: contains check
- [ ] Return list of conflicts with reasons

### For Integration
- [ ] Run on campaign submit
- [ ] Run on store assignment change
- [ ] Auto-exclude conflicting stores
- [ ] Update estimated reach

### For Performance
- [ ] < 500ms for 1000 stores
- [ ] Batch processing supported
- [ ] Index-optimized queries

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Matching Engine API (Internal):**
```go
type BlockingEngine interface {
    CheckConflicts(campaign *Campaign, storeIDs []string) []Conflict
    FilterStores(campaign *Campaign, storeIDs []string) []string // Returns allowed stores
}

type Conflict struct {
    StoreID   string `json:"store_id"`
    StoreName string `json:"store_name"`
    RuleID    string `json:"rule_id"`
    RuleType  string `json:"rule_type"` // brand, category, keyword
    RuleValue string `json:"rule_value"`
    Reason    string `json:"reason"`
}
```

**Usage in Campaign Service:**
```go
func (s *CampaignService) Submit(campaign *Campaign) error {
    // Get all target stores
    storeIDs := s.getTargetStoreIDs(campaign)
    
    // Check for conflicts
    conflicts := s.blockingEngine.CheckConflicts(campaign, storeIDs)
    
    // Exclude conflicting stores
    for _, conflict := range conflicts {
        s.excludeStore(campaign.ID, conflict.StoreID, conflict.Reason)
    }
    
    // Update reach estimate
    s.updateReachEstimate(campaign)
    
    return nil
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement BlockingEngine service
- [ ] Implement brand matching (exact)
- [ ] Implement category matching (hierarchical)
- [ ] Implement keyword matching (contains)
- [ ] Integrate with Campaign Submit
- [ ] Integrate with Store Assignment
- [ ] Optimize with database indexes
- [ ] Benchmark (< 500ms / 1000 stores)
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:24** - Rewrote with matching logic types, triggers, and performance requirements from campaign business rules.
