---
id: "STORY-3.3"
epic_id: "EPIC-003"
title: "Competitor Blocking Rules Management"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "supplier", "blocking", "competitor"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmeb"
---

# Competitor Blocking Rules Management

## User Story

**As a** Supplier,
**I want** to block competitor ads from appearing in my stores,
**So that** my stores don't advertise brands that compete with my own products.

## Business Context

Many retail stores sell their own brands or have exclusive agreements with certain brands. Blocking rules:
- Protect supplier business relationships
- Prevent awkward situations (e.g., Pepsi ads in Coca-Cola stores)
- Give suppliers control over what's shown in their space
- Are applied automatically when advertisers target stores

## Business Rules

> Reference: [09-business-rules-supplier.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/09-business-rules-supplier.md)

### Rule Types
| Type | Matching | Example |
|------|----------|---------|
| **Brand** | Exact match on campaign.brand_name | "Apple", "Samsung" |
| **Category** | Match on campaign.category | "Electronics", "Beverages" |
| **Keyword** | Contains check on content | "competitor", "sale" |

### Rule Application
When advertiser selects store for campaign:
```
IF any blocking_rule.value matches campaign.brand_name:
  EXCLUDE store from campaign
  SET exclusion_reason = "Competitor blocking: {brand}"
```

### Rule Limits
- Maximum 50 rules per store
- Maximum 100 rules per supplier account
- Enterprise tier: Higher limits negotiated

### Rule Scope
- Store-level: Applies to specific store
- Supplier-level: Applies to ALL stores

## Acceptance Criteria

### For Suppliers
- [ ] Add blocking rule with type (brand/category/keyword)
- [ ] View all blocking rules per store
- [ ] Delete rules with confirmation
- [ ] Bulk add multiple rules at once
- [ ] See how many campaigns are currently blocked

### For Rule Management
- [ ] Rules unique per store (no duplicates)
- [ ] Validation for rule types
- [ ] Cannot add empty or invalid values
- [ ] Case-insensitive matching

### For Transparency
- [ ] Advertisers see blocked stores with reason
- [ ] Suppliers can see which campaigns were blocked

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
POST   /api/v1/stores/{store_id}/blocking-rules       # Single or batch
GET    /api/v1/stores/{store_id}/blocking-rules       # List rules
DELETE /api/v1/stores/{store_id}/blocking-rules/{id}  # Remove
GET    /api/v1/supplier/blocking-rules                # All rules
POST   /api/v1/supplier/blocking-rules                # Supplier-wide
```

**Matching Logic:**
```go
func (e *BlockingEngine) Check(campaign, store) *BlockReason {
    rules := e.repo.GetRulesByStore(store.ID)
    
    for _, rule := range rules {
        switch rule.Type {
        case "brand":
            if strings.EqualFold(campaign.BrandName, rule.Value) {
                return &BlockReason{Type: "brand", Value: rule.Value}
            }
        case "category":
            if strings.EqualFold(campaign.Category, rule.Value) {
                return &BlockReason{Type: "category", Value: rule.Value}
            }
        case "keyword":
            if strings.Contains(strings.ToLower(campaign.Content), strings.ToLower(rule.Value)) {
                return &BlockReason{Type: "keyword", Value: rule.Value}
            }
        }
    }
    return nil
}
```

</details>

## Checklist (Subtasks)

- [ ] Create blocking_rules table migration
- [ ] Implement create rule (single and batch)
- [ ] Implement list rules by store
- [ ] Implement delete rule
- [ ] Implement supplier-wide rules
- [ ] Validate rule type and value
- [ ] Enforce rule limits
- [ ] Integrate with Campaign Targeting (EPIC-02)
- [ ] Unit tests for matching logic
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:12** - Rewrote with rule types, matching logic, and integration with campaign targeting from business rules.
