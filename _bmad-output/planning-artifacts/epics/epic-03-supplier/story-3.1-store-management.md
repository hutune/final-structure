---
id: "STORY-3.1"
epic_id: "EPIC-003"
title: "Store Registration & Management"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "supplier", "store", "crud"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmex"
---

# Store Registration & Management

## User Story

**As a** Supplier,
**I want** to register my retail stores on the platform,
**So that** I can start earning advertising revenue from my locations.

## Business Context

Stores are the physical locations where ads are displayed. Proper store registration:
- Enables accurate targeting for advertisers
- Ensures device limits are enforced
- Provides location-based impressions verification
- Determines operating hours for ad scheduling

## Business Rules

> Reference: [09-business-rules-supplier.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/09-business-rules-supplier.md)

### Store Validation
- `store_name` unique within supplier account
- `address` valid and geocoded
- `operating_hours` required for ad scheduling
- Cannot register same address twice

### Device Limits by Store Size
| Square Footage | Max Devices |
|----------------|-------------|
| < 1,000 | 1 |
| 1,000 - 2,999 | 2 |
| 3,000 - 4,999 | 3 |
| 5,000 - 9,999 | 5 |
| ≥ 10,000 | 10 |
| Enterprise (custom) | Negotiated |

### Store Status Lifecycle
```
PENDING_VERIFICATION → ACTIVE → INACTIVE → SUSPENDED
```

### Operating Hours Rules
- Ads ONLY served during operating hours
- Devices enter standby mode outside hours
- No impressions counted when store closed
- 24/7 stores: Set 00:00-23:59 for all days

### Location Verification
- **Automated:** Geocode address, verify commercial (not residential)
- **Manual (if automated fails):** Storefront photo + business license
- Review within 3 business days

## Acceptance Criteria

### For Suppliers
- [ ] Register new store with name, address, type, and hours
- [ ] View all my stores with device counts and status
- [ ] Edit store details (name, hours) - address requires re-verification
- [ ] Set store to Inactive (temporarily pause ads)
- [ ] See max device limit based on store size

### For Verification
- [ ] New stores start as PENDING_VERIFICATION
- [ ] Automated address geocoding on registration
- [ ] Admin can approve/reject stores
- [ ] Email notification on verification complete

### For Accuracy
- [ ] Geofence radius set (default 100m) for device location check
- [ ] Operating hours validated (open_time < close_time)
- [ ] Store type required from predefined list

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Store Types:**
GROCERY, RETAIL, RESTAURANT, GYM, PHARMACY, CONVENIENCE, DEPARTMENT_STORE, SHOPPING_MALL, OTHER

**Database Schema:**
```sql
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    store_name VARCHAR(100) NOT NULL,
    store_code VARCHAR(50),
    store_type VARCHAR(50) NOT NULL,
    address JSONB NOT NULL, -- {line1, city, state, postal, lat, lng}
    timezone VARCHAR(50) NOT NULL,
    geofence_radius_meters INTEGER DEFAULT 100,
    square_footage INTEGER,
    average_daily_visitors INTEGER,
    operating_hours JSONB NOT NULL,
    max_devices_allowed INTEGER,
    status VARCHAR(50) DEFAULT 'PENDING_VERIFICATION',
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    verified_at TIMESTAMP,
    UNIQUE(supplier_id, store_name)
);
```

</details>

## Checklist (Subtasks)

- [ ] Create stores table migration with all fields
- [ ] Implement store registration with geocoding
- [ ] Calculate max_devices_allowed from square_footage
- [ ] Implement operating hours validation
- [ ] Implement admin verification flow
- [ ] Implement status change endpoints
- [ ] Email notifications on status changes
- [ ] Unit tests for device limit calculation
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:10** - Rewrote with device limits by sqft, operating hours rules, and verification flow from business rules.
