---
id: "STORY-3.2"
epic_id: "EPIC-003"
title: "Device Registration & Management"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "supplier", "device", "signage"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmf9"
---

# Device Registration & Management

## User Story

**As a** Supplier,
**I want** to easily register and monitor my advertising screens,
**So that** they can display ads and I can track their performance.

## Business Context

Devices are the digital signage screens that display ads. Proper device management:
- Ensures devices are at verified store locations
- Tracks device health for reliable ad delivery
- Enables suppliers to monitor revenue per device
- Prevents fraud through location verification

## Business Rules

> Reference: [09-business-rules-supplier.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/09-business-rules-supplier.md)

### Device Registration Flow
1. **Store Selection:** Choose verified store
2. **QR Scan:** Device displays QR, supplier scans with app
3. **Pairing:** Device linked to store
4. **Configuration:** Set name, specs, location
5. **GPS Verification:** Confirm within store geofence
6. **Approval:** Device goes live

### Device-Store Association
- Device MUST be associated with verified store
- Device location MUST be within `geofence_radius_meters` (100m default)
- Store MUST have available device slots

### Device Naming Convention
```
Pattern: "{store_name} - {device_location}"
Examples:
- "Whole Foods Downtown - Checkout Lane 1"
- "Nike Store - Window Display"
Length: 5-100 characters, unique within store
```

### Unauthorized Relocation Detection
If device detected > 500m from registered address:
- Device suspended immediately
- All impressions flagged for review
- Revenue held pending investigation

### Device Status
| Status | Description |
|--------|-------------|
| PENDING | Awaiting approval |
| ONLINE | Active and serving ads |
| OFFLINE | No heartbeat > 10 min |
| MAINTENANCE | Supplier-initiated pause (max 4h) |
| ERROR | Hardware/software issue |
| DECOMMISSIONED | Removed from service |

## Acceptance Criteria

### For Device Registration
- [ ] Scan QR code from device (mobile/web)
- [ ] Select store from my verified stores
- [ ] Enter device name and location description
- [ ] GPS check confirms device at store location
- [ ] See device limit remaining for store

### For Device Monitoring
- [ ] Dashboard shows all devices with status
- [ ] See last heartbeat time for each device
- [ ] See today's impressions and revenue per device
- [ ] Alert when device offline > 30 minutes

### For Device Control
- [ ] Set device to Maintenance mode (max 4 hours)
- [ ] Rename or update device settings
- [ ] Decommission device (remove from service)
- [ ] Cannot exceed store's max device limit

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
POST   /api/v1/stores/{store_id}/devices  # Register
GET    /api/v1/stores/{store_id}/devices  # List by store
GET    /api/v1/devices/{id}               # Device details
PUT    /api/v1/devices/{id}               # Update
POST   /api/v1/devices/{id}/maintenance   # Enter maintenance
DELETE /api/v1/devices/{id}               # Decommission
```

**GPS Verification:**
```go
func verifyDeviceLocation(device, store) error {
    distance := haversine(device.lat, device.lng, store.lat, store.lng)
    if distance > store.geofence_radius_meters {
        return ErrDeviceOutsideGeofence
    }
    return nil
}
```

</details>

## Checklist (Subtasks)

- [ ] Create devices table migration
- [ ] Implement QR-based registration flow
- [ ] Implement GPS verification against store geofence
- [ ] Enforce device limits per store
- [ ] Implement device monitoring dashboard
- [ ] Implement maintenance mode (4h limit)
- [ ] Implement offline alerts
- [ ] Detect unauthorized relocation
- [ ] Unit tests for geofence validation
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:10** - Rewrote with QR registration, GPS verification, and unauthorized relocation detection from business rules.
