---
id: "STORY-2.3"
epic_id: "EPIC-002"
title: "Campaign Targeting & Store Selection"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "campaign", "targeting", "stores"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmfv"
---

# Campaign Targeting & Store Selection

## User Story

**As an** Advertiser,
**I want** to choose exactly which stores display my ads,
**So that** I can target customers in locations most relevant to my products.

## Business Context

Effective targeting maximizes advertiser ROI:
- Geographic targeting reaches local customers
- Store type targeting matches product demographics
- Competitor blocking prevents ads appearing next to rival brands
- Clear blocked store visibility helps advertisers make decisions

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Targeting Methods
1. **Manual Selection:** Pick individual stores (1-1000)
2. **Criteria-Based:** Select by region, store type, foot traffic, distance

### Criteria Options
```json
{
  "regions": ["North", "South", "Central"],
  "store_types": ["Supermarket", "Mall", "Convenience"],
  "min_foot_traffic": 5000,
  "max_distance_km": 50,
  "from_location": { "lat": 10.762622, "lng": 106.660172 }
}
```

### Store Eligibility
A store is eligible if:
- Store status = ACTIVE
- Store has ≥ 1 ACTIVE device
- Store NOT blocked by competitor rules

### Competitor Blocking
When advertiser selects stores:
```
FOR EACH store IN selected_stores:
  IF store has blocking_rule matching campaign.brand_name:
    MOVE store from target_stores to blocked_stores
    SET exclusion_reason = "Competitor blocking: {brand}"
```

### Estimation Formulas
```
estimated_impressions = SUM(
  store.daily_foot_traffic
  × store.device_count
  × store.avg_dwell_minutes / 60
  × campaign.duration_days
) × 0.7 (conservative factor)

estimated_cost = estimated_impressions × avg_CPM / 1000
```

## Acceptance Criteria

### For Store Discovery
- [ ] Store list with search, filter by region/type
- [ ] Store cards show: name, location, device count, foot traffic
- [ ] Map view available for geographic selection
- [ ] Store health indicator (devices online/offline)

### For Targeting
- [ ] Can select stores individually (checkboxes)
- [ ] Can apply criteria filters
- [ ] Maximum 1000 stores per campaign
- [ ] Clear indicator of selected count

### For Blocking Visibility
- [ ] Blocked stores shown in separate "Excluded" section
- [ ] Each blocked store shows clear reason
- [ ] Tip: "You may be able to remove blocking by contacting store owner"

### For Estimation
- [ ] Show estimated impressions based on selection
- [ ] Show estimated cost vs budget
- [ ] Warning if estimated cost exceeds budget

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET  /api/v1/stores?region=...&type=...&min_traffic=...
GET  /api/v1/campaigns/{id}/stores
POST /api/v1/campaigns/{id}/stores  (bulk assign)
DELETE /api/v1/campaigns/{id}/stores/{store_id}
POST /api/v1/campaigns/{id}/estimate  (calculate estimates)
```

**Response with Blocking:**
```json
{
  "targeted": [
    { "store_id": "uuid1", "name": "Store A", "devices": 5 }
  ],
  "blocked": [
    { 
      "store_id": "uuid2", 
      "name": "Store B", 
      "reason": "Competitor blocking: Apple" 
    }
  ],
  "estimates": {
    "impressions": 50000,
    "cost": 250.00,
    "cpm": 5.00
  }
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement store listing with filters
- [ ] Implement geographic search (lat/lng + radius)
- [ ] Implement bulk store assignment
- [ ] Integrate with Blocking Engine (EPIC-07)
- [ ] Implement estimation calculation
- [ ] Create campaign_stores junction table
- [ ] Unit tests for targeting logic
- [ ] Integration tests with blocking

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:35** - Rewrote with targeting methods, competitor blocking, and estimation formulas from business rules.
