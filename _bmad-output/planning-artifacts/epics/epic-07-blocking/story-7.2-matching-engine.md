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

**As a** System,
**I want** matching campaign metadata với store blocking rules,
**So that** campaigns không hiển thị tại stores có conflict.

## Acceptance Criteria

- [ ] Matching engine detect conflicts giữa campaign và store rules
- [ ] Exact match cho brand rules
- [ ] Contains match cho keyword rules
- [ ] Stores bị conflict được auto-exclude
- [ ] Matching chạy khi campaign submit và target update

## Technical Notes

**Matching Algorithm:**
```go
type BlockingEngine struct {
    ruleRepo BlockingRuleRepository
}

func (e *BlockingEngine) CheckConflicts(campaign *Campaign, storeIDs []string) []Conflict {
    var conflicts []Conflict

    // Get campaign metadata
    brand := campaign.Metadata["brand"]
    categories := campaign.Metadata["categories"]

    for _, storeID := range storeIDs {
        rules := e.ruleRepo.GetByStoreID(storeID)

        for _, rule := range rules {
            if e.matches(rule, brand, categories) {
                conflicts = append(conflicts, Conflict{
                    StoreID: storeID,
                    RuleID: rule.ID,
                    RuleType: rule.Type,
                    RuleValue: rule.Value,
                    Reason: fmt.Sprintf("Campaign brand '%s' matches blocking rule '%s'", brand, rule.Value),
                })
            }
        }
    }

    return conflicts
}

func (e *BlockingEngine) matches(rule *BlockingRule, brand string, categories []string) bool {
    switch rule.Type {
    case "brand":
        return strings.EqualFold(rule.Value, brand)
    case "category":
        for _, cat := range categories {
            if strings.EqualFold(rule.Value, cat) {
                return true
            }
        }
    case "keyword":
        // Check if keyword appears in brand or categories
        return strings.Contains(strings.ToLower(brand), strings.ToLower(rule.Value))
    }
    return false
}
```

**Integration Points:**
- Called from Campaign Service on submit
- Called from Campaign Service on store assignment
- Returns list of conflicts with reasons

**API (Internal):**
```go
// Called by Campaign Service
conflicts := blockingEngine.CheckConflicts(campaign, targetStoreIDs)
for _, conflict := range conflicts {
    // Mark store as excluded
    campaignStore.Status = "excluded"
    campaignStore.ExclusionReason = conflict.Reason
}
```

## Checklist (Subtasks)

- [ ] Implement BlockingEngine service
- [ ] Implement brand matching (exact)
- [ ] Implement category matching
- [ ] Implement keyword matching (contains)
- [ ] Integrate with Campaign Submit flow
- [ ] Integrate with Store Assignment flow
- [ ] Optimize với database indexes
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
