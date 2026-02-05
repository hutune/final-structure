---
id: "STORY-7.1"
epic_id: "EPIC-007"
title: "Campaign Metadata Tagging"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "blocking", "metadata", "tags"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm7n"
---

# Campaign Metadata Tagging

## User Story

**As an** Advertiser,
**I want** to specify my brand and product category when creating a campaign,
**So that** the system can automatically match with supplier blocking rules.

## Business Context

Accurate metadata enables automatic conflict detection:
- Advertisers declare their brand (e.g., "Apple", "Coca-Cola")
- Advertisers select product categories
- Suppliers block competitors (e.g., Samsung dealer blocks Apple)
- System auto-excludes conflicting stores

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Required Metadata
| Field | Required | Description |
|-------|----------|-------------|
| Brand | Yes | Primary brand name |
| Categories | Yes (at least 1) | Product categories |
| Keywords | No | Additional descriptors |

### Category Taxonomy
```
Level 1          Level 2            Level 3
Electronics  →   Smartphones    →   Apple, Samsung, Xiaomi
             →   Laptops        →   Gaming, Business
Food & Bev   →   Soft Drinks    →   Cola, Juice
             →   Snacks         →   Chips, Candy
Fashion      →   Footwear       →   Sports, Formal
             →   Apparel        →   Casual, Formal
```

### Metadata Matching
- **Brand:** Exact match (case-insensitive)
- **Category:** Hierarchical match (parent matches child)
- **Keyword:** Contains match

## Acceptance Criteria

### For Advertisers
- [ ] Enter brand name on campaign creation
- [ ] Select categories from dropdown (autocomplete)
- [ ] Add optional keywords
- [ ] See how many stores are blocked based on metadata

### For Matching
- [ ] Metadata used by Blocking Engine
- [ ] Categories follow standard taxonomy
- [ ] Auto-suggest based on past campaigns

### For Management
- [ ] Admin can manage category taxonomy
- [ ] Add/edit/archive categories
- [ ] View most used categories

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Campaign Request:**
```json
{
  "name": "iPhone 15 Launch",
  "brand": "Apple",
  "categories": ["Electronics", "Smartphones"],
  "keywords": ["iphone", "mobile", "tech"],
  "budget": 5000.00
}
```

**Category Taxonomy API:**
```
GET  /api/v1/categories                     # List all
GET  /api/v1/categories/{id}/children       # Get subcategories
POST /api/v1/admin/categories               # Create (admin)
PUT  /api/v1/admin/categories/{id}          # Update (admin)
```

</details>

## Checklist (Subtasks)

- [ ] Add brand/categories to campaign model
- [ ] Create category taxonomy table
- [ ] Seed initial categories
- [ ] Implement category autocomplete
- [ ] Update Campaign Create to save metadata
- [ ] Implement admin category management
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:24** - Rewrote with metadata requirements and category taxonomy from campaign business rules.
