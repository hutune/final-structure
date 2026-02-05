# Device & Asset Management Module - Business Rules Document

**Version**: 1.1  
**Date**: 2026-02-05  
**Status**: Updated (Whiteboard findings integrated)  
**Owner**: Product Team  
**Domain**: 04-Device & Asset Management

---

## Table of Contents

1. [Overview](#overview)
2. [Domain Entities](#domain-entities)
3. [Device Lifecycle](#device-lifecycle)
4. [Asset Management](#asset-management)
5. [Business Rules](#business-rules)
6. [Device Registration](#device-registration)
7. [Heartbeat & Health Monitoring](#heartbeat--health-monitoring)
8. [Content Synchronization](#content-synchronization)
9. [Playback Management](#playback-management)
10. [Device Configuration](#device-configuration)
11. [Fraud Detection & Security](#fraud-detection--security)
12. [Firmware & Software Updates](#firmware--software-updates)
13. [Device Replacement & Transfer](#device-replacement--transfer)
14. [Edge Cases & Error Handling](#edge-cases--error-handling)
15. [Validation Rules](#validation-rules)
16. [Calculations & Formulas](#calculations--formulas)

---

## Overview

### Purpose
This document defines ALL business rules for the Device & Asset Management module in RMN-Arms platform. Devices are the physical digital signage displays that show advertising content in retail stores. This domain also covers broader asset management concepts including physical item assignment and storage.

### Scope
- Device registration and provisioning
- Device lifecycle management
- Health monitoring and heartbeat
- Content synchronization
- Playback scheduling and management
- Device configuration
- Fraud detection and security
- Maintenance and troubleshooting
- **Asset registration and tracking** (ARMS)
- **Item assignment to entities** (ARMS)
- **Storage management** (ARMS)

### Out of Scope
- Campaign management (see Campaign module)
- Content creation/upload (see CMS module)
- Billing calculations (see Campaign/Billing module)
- Store management (see Supplier module)

---

## Domain Entities

### 1. Device

**Definition**: A physical digital signage display device installed at a retail store location that plays advertising content.

**Attributes**:

| Field | Type | Required | Default | Business Rule |
|-------|------|----------|---------|---------------|
| `id` | UUID | Yes | Auto-generated | Immutable after creation |
| `device_code` | String(20) | Yes | Auto-generated | Unique globally, alphanumeric |
| `device_name` | String(100) | No | "Device {code}" | Human-readable name |
| `store_id` | UUID | Yes | - | Must be registered store |
| `supplier_id` | UUID | Yes | Derived from store | Read-only, inherited |
| `device_type` | Enum | Yes | DISPLAY | See [Device Type Enum](#device-type-enum) |
| `status` | Enum | Yes | REGISTERED | See [Status Lifecycle](#status-lifecycle) |
| `screen_size_inches` | Integer | Yes | - | Range: 32-100 inches |
| `screen_resolution` | String(20) | Yes | - | Format: "WIDTHxHEIGHT" (e.g., "1920x1080") |
| `screen_orientation` | Enum | Yes | LANDSCAPE | LANDSCAPE / PORTRAIT |
| `hardware_model` | String(50) | No | null | Device hardware model |
| `os_type` | Enum | Yes | - | ANDROID / WINDOWS / LINUX / WEBOS / TIZEN |
| `os_version` | String(20) | No | null | OS version string |
| `player_version` | String(20) | No | null | Player app version |
| `mac_address` | String(17) | No | null | Format: XX:XX:XX:XX:XX:XX |
| `ip_address` | String(45) | No | null | IPv4 or IPv6 |
| `public_key` | Text | Yes | Generated | RSA 2048-bit public key for signatures |
| `location` | GeoJSON | No | null | GPS coordinates if available |
| `advertising_slots_per_hour` | Integer | Yes | 12 | Range: 6-60 slots |
| `max_content_duration` | Integer | Yes | 60 | Max seconds per content (10-300) |
| `operating_hours` | JSON | Yes | 24/7 | Store operating schedule |
| `timezone` | String(50) | Yes | - | IANA timezone (e.g., "Asia/Ho_Chi_Minh") |
| `last_heartbeat_at` | DateTime | No | null | Last successful heartbeat |
| `last_sync_at` | DateTime | No | null | Last content sync |
| `last_impression_at` | DateTime | No | null | Last ad played |
| `total_uptime_minutes` | Integer | Yes | 0 | Cumulative uptime since activation |
| `total_downtime_minutes` | Integer | Yes | 0 | Cumulative downtime |
| `uptime_percentage` | Decimal(5,2) | Yes | 0.00 | Computed: uptime / (uptime + downtime) × 100 |
| `total_impressions` | Integer | Yes | 0 | Lifetime impression count |
| `total_revenue_generated` | Decimal(10,2) | Yes | 0.00 | Lifetime supplier revenue |
| `health_score` | Integer | Yes | 100 | Range: 0-100, computed metric |
| `flags` | JSON | Yes | {} | System flags: suspicious, needs_maintenance |
| `metadata` | JSON | No | {} | Custom key-value data |
| `registered_at` | DateTime | Yes | NOW() | Immutable |
| `activated_at` | DateTime | No | null | When status became ACTIVE |
| `decommissioned_at` | DateTime | No | null | When status became DECOMMISSIONED |
| `created_at` | DateTime | Yes | NOW() | Immutable |
| `updated_at` | DateTime | Yes | NOW() | Auto-updated |

#### Device Type Enum
```
- DISPLAY: Standard digital signage display
- VIDEO_WALL: Multi-screen video wall (counts as 1 device)
- KIOSK: Interactive kiosk with touchscreen
- TABLET: Tablet device
- SMART_TV: Smart TV with built-in player
- LED_BOARD: LED billboard
```

#### Status Lifecycle
```
REGISTERED → ACTIVE → OFFLINE → MAINTENANCE → ACTIVE
                                         ↓
                                  DECOMMISSIONED
```

**State Descriptions**:
- `REGISTERED`: Device registered but not yet activated (initial state)
- `ACTIVE`: Device online and serving ads
- `OFFLINE`: Device not responding to heartbeat (temporary)
- `MAINTENANCE`: Device in maintenance mode (scheduled downtime)
- `DECOMMISSIONED`: Device permanently removed from service

---

## Asset Management (ARMS)

> **Note**: This section covers broader asset management capabilities beyond digital signage devices. Based on ARMS (Asset Resource Management System) whiteboard analysis.

### 6. Asset (General)

**Definition**: Any trackable physical or digital resource in the system.

**Attributes**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `asset_code` | String(20) | Yes | Unique asset code |
| `asset_type` | Enum | Yes | DEVICE, MEETING_ROOM, STORAGE, NAME_TAG, OTHER |
| `name` | String(100) | Yes | Human-readable name |
| `status` | Enum | Yes | PENDING, ACTIVE, INACTIVE, DECOMMISSIONED |
| `owner_type` | Enum | Yes | COMPANY, DEPARTMENT, USER |
| `owner_id` | UUID | Yes | Reference to owner entity |
| `metadata` | JSON | No | Custom attributes |
| `created_at` | DateTime | Yes | Creation timestamp |

#### Asset Status Lifecycle
```
PENDING → ACTIVE → INACTIVE → DECOMMISSIONED
              ↓
         MAINTENANCE
```

---

### 7. ItemAssignment

**Definition**: Tracks assignment of physical items to entities (users, departments, stores).

**Attributes**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `asset_id` | UUID | Yes | Asset being assigned |
| `assignee_type` | Enum | Yes | USER, DEPARTMENT, STORE, COMPANY |
| `assignee_id` | UUID | Yes | Reference to assignee |
| `assigned_by` | UUID | Yes | Who made the assignment |
| `assigned_at` | DateTime | Yes | Assignment timestamp |
| `returned_at` | DateTime | No | When item was returned |
| `status` | Enum | Yes | ASSIGNED, RETURNED, LOST, DAMAGED |
| `notes` | Text | No | Assignment notes |

**Business Rules**:
- One asset can only have one active assignment at a time
- Return must be recorded before re-assignment
- Lost/Damaged status requires admin approval

---

### 8. Storage

**Definition**: Physical storage locations for assets.

**Attributes**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `storage_code` | String(20) | Yes | Unique storage code |
| `name` | String(100) | Yes | Storage location name |
| `type` | Enum | Yes | WAREHOUSE, CABINET, SHELF, ROOM |
| `location` | String(200) | Yes | Physical address |
| `capacity` | Integer | No | Maximum items |
| `current_count` | Integer | Yes | Current items stored |
| `manager_id` | UUID | No | Assigned manager |
| `status` | Enum | Yes | ACTIVE, FULL, MAINTENANCE |


---

### 2. DeviceHeartbeat

**Definition**: Periodic health check record sent by device to server.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `device_id` | UUID | Yes | Must be registered device |
| `timestamp` | DateTime | Yes | Server-side timestamp (UTC) |
| `device_timestamp` | DateTime | Yes | Device local time |
| `status` | Enum | Yes | ONLINE / DEGRADED / ERROR |
| `cpu_usage` | Integer | No | 0-100 percentage |
| `memory_usage` | Integer | No | 0-100 percentage |
| `disk_usage` | Integer | No | 0-100 percentage |
| `network_latency_ms` | Integer | No | Ping latency in milliseconds |
| `screen_on` | Boolean | Yes | Is screen powered on |
| `content_playing` | Boolean | Yes | Is content actively playing |
| `current_playlist_id` | UUID | No | Currently loaded playlist |
| `error_count` | Integer | Yes | Errors since last heartbeat |
| `error_messages` | JSON | No | Array of error messages |
| `location` | GeoJSON | No | GPS coordinates at heartbeat |
| `ip_address` | String(45) | Yes | Current IP address |

---

### 3. DeviceContentSync

**Definition**: Record of content synchronization between server and device.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `device_id` | UUID | Yes | Target device |
| `sync_type` | Enum | Yes | FULL / INCREMENTAL / FORCED |
| `status` | Enum | Yes | PENDING / IN_PROGRESS / COMPLETED / FAILED |
| `total_files` | Integer | Yes | Number of files to sync |
| `synced_files` | Integer | Yes | Number of files completed |
| `total_bytes` | BigInt | Yes | Total bytes to transfer |
| `synced_bytes` | BigInt | Yes | Bytes transferred |
| `bandwidth_kbps` | Integer | No | Transfer speed |
| `started_at` | DateTime | Yes | Sync start time |
| `completed_at` | DateTime | No | Sync completion time |
| `error_message` | Text | No | Error details if failed |
| `retry_count` | Integer | Yes | Number of retry attempts (default: 0) |

---

### 4. DevicePlaylist

**Definition**: Scheduled content queue for a device.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `device_id` | UUID | Yes | Target device |
| `campaign_id` | UUID | Yes | Source campaign |
| `content_asset_id` | UUID | Yes | Content to play |
| `priority` | Integer | Yes | 1-10 (10 = highest) |
| `weight` | Integer | Yes | Relative frequency (1-100) |
| `start_date` | DateTime | Yes | Begin showing content |
| `end_date` | DateTime | Yes | Stop showing content |
| `time_restrictions` | JSON | No | Day/hour targeting |
| `play_count` | Integer | Yes | Times played (default: 0) |
| `last_played_at` | DateTime | No | Last impression time |
| `status` | Enum | Yes | PENDING / ACTIVE / COMPLETED / EXPIRED |
| `created_at` | DateTime | Yes | Immutable |

---

### 5. DeviceMaintenanceLog

**Definition**: Record of device maintenance activities.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `device_id` | UUID | Yes | Device being maintained |
| `maintenance_type` | Enum | Yes | SCHEDULED / EMERGENCY / FIRMWARE_UPDATE |
| `performed_by` | UUID | Yes | User or admin ID |
| `started_at` | DateTime | Yes | Maintenance start |
| `completed_at` | DateTime | No | Maintenance end |
| `duration_minutes` | Integer | No | Computed from start/end |
| `description` | Text | Yes | What was done |
| `notes` | Text | No | Additional observations |
| `parts_replaced` | JSON | No | Hardware parts replaced |
| `cost` | Decimal(10,2) | No | Maintenance cost |
| `status` | Enum | Yes | SCHEDULED / IN_PROGRESS / COMPLETED / CANCELLED |

---

## Device Lifecycle

### 1. Registration Flow

#### Step 1: Device ID Generation
```
Actor: Supplier or System
Trigger: New device needs to be registered

Process:
1. Generate unique device_code:
   code = generate_alphanumeric(16)
   Format: "DVC-XXXX-XXXX-XXXX"

2. Validate uniqueness:
   WHILE EXISTS(device_code):
     code = generate_alphanumeric(16)

3. Generate RSA key pair (2048-bit):
   (private_key, public_key) = generate_rsa_keypair()
   Store public_key in database
   Return private_key to device (one-time only)

4. Create device record:
   Device {
     id: UUID,
     device_code: code,
     status: REGISTERED,
     store_id: null,
     public_key: public_key,
     created_at: NOW()
   }

Business Rules:
- Device code must be globally unique
- Private key shown only once (cannot be recovered)
- Device starts in REGISTERED status
- Cannot be used until assigned to store

Output:
- device_id
- device_code (for QR code generation)
- private_key (IMPORTANT: save securely)
```

#### Step 2: QR Code Generation
```
Actor: System
Input: device_code

Process:
1. Generate QR code data:
   qr_data = {
     "device_code": device_code,
     "registration_url": "https://rmn-arms.com/device/register",
     "activation_key": generate_activation_key()
   }

2. Encode as QR code:
   qr_image = generate_qr_code(json.stringify(qr_data))

3. Store activation key:
   ActivationKey {
     device_code: device_code,
     activation_key: activation_key,
     expires_at: NOW() + 30 days,
     status: UNUSED
   }

Business Rules:
- Activation key expires after 30 days
- QR code can be printed and shipped with device
- One-time use activation key
- QR code contains registration instructions

Output:
- QR code image (PNG/SVG)
- Activation key (for manual entry)
```

#### Step 3: Store Assignment
```
Actor: Supplier
Trigger: Supplier scans QR code or enters device_code manually

Input:
  - device_code: String
  - activation_key: String
  - store_id: UUID

Validation:
✓ Device exists and status = REGISTERED
✓ Activation key valid and not expired
✓ Store belongs to current supplier
✓ Store is ACTIVE

Process:
1. Validate device:
   device = Device.find_by(device_code: device_code)
   IF device.status != REGISTERED:
     ERROR: "Device already assigned or not available"

2. Validate activation key:
   key = ActivationKey.find_by(
     device_code: device_code,
     activation_key: activation_key
   )
   IF key.expired OR key.status = USED:
     ERROR: "Activation key invalid or expired"

3. Validate store ownership:
   store = Store.find(store_id)
   IF store.supplier_id != current_supplier.id:
     ERROR: "Store does not belong to you"

4. Assign device to store:
   device.update(
     store_id: store_id,
     supplier_id: store.supplier_id,
     status: REGISTERED
   )

5. Mark activation key as used:
   key.update(status: USED, used_at: NOW())

6. Initialize device configuration:
   - Copy store operating hours
   - Set timezone from store
   - Set default advertising slots (12/hour)

7. Notify supplier:
   "Device {device_code} assigned to {store.name}"

Business Rules:
- Device must be in REGISTERED status
- Activation key single-use only
- Store must be active and belong to supplier
- Device inherits store configuration

Output:
- Device assigned to store
- Ready for activation
```

#### Step 4: Device Activation
```
Actor: Device (first heartbeat) or Supplier (manual activation)
Trigger: Device powers on and connects to internet

Process:
1. Device sends first heartbeat:
   POST /devices/:id/heartbeat
   {
     "device_timestamp": "2026-01-23T10:00:00Z",
     "status": "ONLINE",
     "hardware_info": {
       "screen_size": 55,
       "resolution": "1920x1080",
       "os": "Android 12",
       "player_version": "1.0.0"
     }
   }

2. Server validates device:
   ✓ Device exists
   ✓ Device assigned to store
   ✓ Request signed with device private key

3. Update device record:
   device.update(
     status: ACTIVE,
     activated_at: NOW(),
     last_heartbeat_at: NOW(),
     screen_size_inches: 55,
     screen_resolution: "1920x1080",
     os_type: "ANDROID",
     os_version: "12",
     player_version: "1.0.0"
   )

4. Send initial configuration:
   Response: {
     "status": "ACTIVE",
     "config": {
       "heartbeat_interval": 300, // 5 minutes
       "sync_interval": 3600,     // 1 hour
       "advertising_slots": 12,
       "operating_hours": {...},
       "timezone": "Asia/Ho_Chi_Minh"
     },
     "playlist": [] // Empty initially
   }

5. Trigger content sync:
   - Schedule initial content download
   - Load active campaigns for this store

6. Notify supplier:
   "Device {device_code} at {store.name} is now active"

Business Rules:
- First heartbeat triggers activation
- Device must provide hardware info
- Status changes from REGISTERED → ACTIVE
- Initial playlist is empty until campaigns assigned
- Device receives configuration immediately

Output:
- Device status = ACTIVE
- Device can now serve ads
- Supplier notified
```

---

### 2. Heartbeat Flow

```
Schedule: Every 5 minutes (configurable)
Purpose: Health monitoring, status updates, keep-alive

Device Side:
1. Collect system metrics:
   - CPU usage
   - Memory usage
   - Disk usage
   - Network latency
   - Current status
   - Error logs

2. Sign heartbeat data:
   signature = sign_with_private_key(heartbeat_data)

3. Send to server:
   POST /devices/:id/heartbeat
   Headers:
     X-Device-Signature: {signature}
   Body: {
     "device_timestamp": "2026-01-23T10:05:00+07:00",
     "status": "ONLINE",
     "metrics": {
       "cpu_usage": 45,
       "memory_usage": 60,
       "disk_usage": 30,
       "network_latency_ms": 25
     },
     "playback": {
       "screen_on": true,
       "content_playing": true,
       "current_playlist_id": "uuid",
       "last_impression_id": "uuid"
     },
     "errors": []
   }

Server Side:
1. Verify signature:
   verify_signature(heartbeat_data, signature, device.public_key)

2. Validate timestamp:
   time_diff = abs(server_time - device_timestamp)
   IF time_diff > 5 minutes:
     WARN: "Device clock skew: {time_diff}"

3. Update device:
   device.update(
     last_heartbeat_at: NOW(),
     status: ACTIVE,
     cpu_usage: 45,
     memory_usage: 60,
     ip_address: request.ip
   )

4. Check for issues:
   IF cpu_usage > 90 OR memory_usage > 90:
     FLAG device as "high_resource_usage"

   IF errors.length > 0:
     LOG errors
     IF errors.length > 10:
       FLAG device as "frequent_errors"

5. Respond with updates:
   Response: {
     "status": "OK",
     "server_time": "2026-01-23T10:05:15Z",
     "config_updated": false,
     "playlist_updated": true,
     "actions": [
       {"type": "sync_content", "playlist_id": "uuid"}
     ]
   }

Business Rules:
- Heartbeat every 5 minutes (default)
- Device offline if no heartbeat for 10 minutes (2 missed)
- Signature required for authentication
- Clock skew > 5 min triggers warning
- High resource usage (>90%) triggers alert
- Server can push actions via heartbeat response

Output:
- Device status updated
- Server aware of device health
- Actions queued for device
```

---

### 3. Offline Detection

```
Trigger: Device misses heartbeat

Process:
1. Background job checks heartbeats:
   Schedule: Every 2 minutes

   offline_devices = Devices.where(
     status: ACTIVE,
     last_heartbeat_at < NOW() - 10 minutes
   )

2. For each offline device:
   device.update(status: OFFLINE, went_offline_at: NOW())

3. Calculate downtime:
   downtime_minutes = (NOW() - went_offline_at) / 60
   device.increment(total_downtime_minutes, downtime_minutes)

4. Notify supplier:
   IF downtime_minutes >= 15:
     Send alert: "Device {device_code} offline for 15+ minutes"

   IF downtime_minutes >= 60:
     Send urgent alert: "Device {device_code} offline for 1+ hour"

5. Stop serving campaigns:
   - Remove device from campaign rotation
   - Pause impression counting
   - No billing during offline period

6. When device comes back online:
   - Status: OFFLINE → ACTIVE
   - Calculate uptime/downtime ratio
   - Update health score
   - Resume ad serving

Business Rules:
- Offline after 10 minutes (2 missed heartbeats)
- Alerts at 15 min and 60 min offline
- No impressions counted while offline
- Supplier not paid for offline period
- Device auto-recovers when heartbeat resumes
- Downtime tracked for performance metrics

Thresholds:
- Grace period: 10 minutes (2 missed heartbeats)
- First alert: 15 minutes
- Urgent alert: 60 minutes
- Critical alert: 4 hours (may need on-site check)
```

---

## Business Rules

### Rule 1: Device Ownership & Transfer

#### 1.1 Device Ownership
```
Rule: Device belongs to supplier who registered it
      Device tied to specific store
      One device cannot be shared between multiple stores

Ownership Hierarchy:
Device → Store → Supplier

Business Rules:
- Device.supplier_id = Store.supplier_id (always in sync)
- Device cannot exist without store assignment
- Device cannot be assigned to store from different supplier
```

#### 1.2 Device Transfer Between Stores
```
Actor: Supplier
Use Case: Moving device from Store A to Store B (same supplier)

Input:
  - device_id
  - target_store_id

Validation:
✓ Both stores belong to same supplier
✓ Device status = ACTIVE or OFFLINE
✓ Target store is ACTIVE
✓ No active campaigns exclusive to old store

Process:
1. Validate ownership:
   device = Device.find(device_id)
   old_store = Store.find(device.store_id)
   new_store = Store.find(target_store_id)

   IF old_store.supplier_id != new_store.supplier_id:
     ERROR: "Cannot transfer device to store from different supplier"

2. Check active campaigns:
   active_campaigns = device.active_campaigns.where(
     store_exclusive: true
   )

   IF active_campaigns.count > 0:
     WARN: "Device has {count} active exclusive campaigns"
     Require confirmation: "Campaigns will be paused"

3. Execute transfer:
   device.update(
     store_id: new_store.id,
     location: new_store.location,
     timezone: new_store.timezone,
     operating_hours: new_store.operating_hours
   )

4. Update campaigns:
   - Pause campaigns exclusive to old store
   - Recalculate eligible campaigns for new store
   - Trigger content sync

5. Create audit log:
   DeviceTransferLog {
     device_id: device_id,
     from_store_id: old_store.id,
     to_store_id: new_store.id,
     transferred_by: current_user.id,
     transferred_at: NOW(),
     reason: "Store relocation"
   }

6. Notify:
   "Device {device_code} transferred from {old_store.name} to {new_store.name}"

Business Rules:
- Same supplier only (no cross-supplier transfers)
- Exclusive campaigns paused during transfer
- Device inherits new store configuration
- Audit trail maintained
- Content re-sync required
```

#### 1.3 Device Decommissioning
```
Actor: Supplier or Admin
Trigger: Device permanently removed from service

Input:
  - device_id
  - reason: String

Validation:
✓ Device exists
✓ User has permission (supplier owner or admin)

Process:
1. Pause active campaigns:
   campaigns = device.active_campaigns
   FOR EACH campaign IN campaigns:
     Remove device from campaign.target_devices
     IF campaign.target_devices.empty:
       campaign.status = PAUSED
       Notify advertiser

2. Complete pending impressions:
   - Wait 5 minutes grace period
   - Process any in-flight impressions
   - Finalize billing

3. Update device:
   device.update(
     status: DECOMMISSIONED,
     decommissioned_at: NOW(),
     decommission_reason: reason
   )

4. Archive data:
   - Move heartbeat logs to cold storage (>90 days old)
   - Keep impression records (permanent)
   - Archive device configuration

5. Notify:
   - Supplier: "Device {device_code} decommissioned"
   - Affected advertisers: "Device removed from campaigns"

Business Rules:
- Status change is permanent (cannot reactivate)
- All campaigns automatically removed
- Impressions finalized before decommissioning
- Historical data preserved for reporting
- Device code can be reused after 1 year
```

---

### Rule 2: Device Health & Uptime

#### 2.1 Health Score Calculation
```
Health Score: 0-100 (higher is better)

Formula:
health_score = (
  uptime_score × 0.40 +
  performance_score × 0.30 +
  reliability_score × 0.20 +
  compliance_score × 0.10
)

Components:

1. Uptime Score (40%):
   uptime_ratio = total_uptime_minutes / (total_uptime + total_downtime)
   uptime_score = uptime_ratio × 100

   Target: ≥ 95% uptime
   Excellent: ≥ 99%
   Good: 95-99%
   Fair: 90-95%
   Poor: < 90%

2. Performance Score (30%):
   Factors:
   - CPU usage (lower is better): max 80%
   - Memory usage (lower is better): max 80%
   - Network latency (lower is better): max 100ms
   - Content load time (faster is better): max 5s

   performance_score = 100 - (
     cpu_penalty +
     memory_penalty +
     latency_penalty +
     load_time_penalty
   )

   Penalties:
   - CPU > 80%: -5 points per 10% over
   - Memory > 80%: -5 points per 10% over
   - Latency > 100ms: -10 points per 50ms over
   - Load time > 5s: -10 points per 2s over

3. Reliability Score (20%):
   Factors:
   - Impression success rate (target: >99%)
   - Sync success rate (target: >95%)
   - Error frequency (target: <5 per day)

   impression_success = (impressions_recorded / impressions_attempted) × 100
   sync_success = (syncs_completed / syncs_attempted) × 100
   error_penalty = min(errors_per_day × 2, 50) // Max 50 points penalty

   reliability_score = (
     impression_success × 0.5 +
     sync_success × 0.3
   ) - error_penalty

4. Compliance Score (10%):
   Factors:
   - Content approval compliance (no unapproved content)
   - Playback schedule compliance (follows operating hours)
   - Security compliance (valid signatures, no tamper flags)

   compliance_score = 100 IF all_checks_pass ELSE 0

   Violations:
   - Playing unapproved content: -100 (instant 0)
   - Missing signatures: -50
   - Playing outside hours: -30

Example Calculation:
  Device A:
    - Uptime: 98% → uptime_score = 98 × 0.40 = 39.2
    - CPU: 60%, Memory: 70%, Latency: 50ms → performance_score = 100 × 0.30 = 30.0
    - Impressions: 99.5% success → reliability_score = 99.5 × 0.20 = 19.9
    - Compliance: All pass → compliance_score = 100 × 0.10 = 10.0

    Total: 39.2 + 30.0 + 19.9 + 10.0 = 99.1 (Excellent)

Business Rules:
- Health score recalculated hourly
- Scores < 70 trigger supplier notification
- Scores < 50 trigger admin review
- Persistent low scores may result in removal from premium campaigns
- High scores (>95) eligible for bonus revenue share
```

#### 2.2 Uptime Requirements
```
Minimum Uptime SLA:

Standard Device:
- Target: 95% uptime
- Measured: Last 30 days rolling window
- Penalties: Revenue reduction if < 95%

Premium Device (high-traffic stores):
- Target: 98% uptime
- Measured: Last 30 days rolling window
- Penalties: Stricter revenue reduction

Penalty Structure:
IF uptime < 95%:
  revenue_multiplier = uptime_percentage / 95

  Example:
    90% uptime → 90/95 = 0.947 multiplier (5.3% revenue reduction)
    85% uptime → 85/95 = 0.895 multiplier (10.5% revenue reduction)

IF uptime < 80%:
  Device flagged for review
  May be removed from high-value campaigns

Excused Downtime:
- Scheduled maintenance (pre-announced, max 4 hours/month)
- Store closures (holidays, renovations)
- Force majeure (power outage, natural disasters)

Calculation:
total_minutes_in_month = 30 × 24 × 60 = 43,200
uptime_percentage = (total_uptime_minutes / total_minutes_in_month) × 100

Excused time subtracted from denominator:
uptime_percentage = total_uptime_minutes / (total_minutes - excused_minutes) × 100

Business Rules:
- Uptime measured continuously (24/7)
- Scheduled maintenance must be pre-announced (24h notice)
- Excused downtime requires documentation
- Penalties apply at month-end payout
- Devices with chronic issues may be decommissioned
```

---

### Rule 3: Device Configuration

#### 3.1 Operating Hours
```
Definition: Time periods when device should be active and serving ads

Configuration:
operating_hours = {
  "monday": {"open": "08:00", "close": "22:00"},
  "tuesday": {"open": "08:00", "close": "22:00"},
  "wednesday": {"open": "08:00", "close": "22:00"},
  "thursday": {"open": "08:00", "close": "22:00"},
  "friday": {"open": "08:00", "close": "22:00"},
  "saturday": {"open": "09:00", "close": "23:00"},
  "sunday": {"open": "10:00", "close": "21:00"},
  "holidays": {"open": "10:00", "close": "20:00"}
}

Business Rules:
- Times in device local timezone
- Device should auto-sleep outside operating hours
- No impressions counted outside operating hours
- Device can wake early for content sync (30 min before open)
- Campaign scheduling respects operating hours

Behavior:
1. Before opening:
   - Device wakes 30 minutes before open time
   - Syncs latest content
   - Verifies playlist
   - Ready to serve at exact open time

2. During hours:
   - Normal operation
   - Serving ads according to playlist
   - Recording impressions
   - Regular heartbeats

3. After closing:
   - Complete current content playback
   - Record final impressions
   - Enter sleep mode
   - Low-power heartbeat every 30 min

4. Outside hours:
   - Screen off (power saving)
   - No ad serving
   - Reduced heartbeat frequency
   - Immediate wake-up capability (for urgent updates)

Special Days:
- Holidays: Use "holidays" schedule
- Store closures: Set operating_hours = null for that day
- 24/7 operation: Set open=00:00, close=23:59 every day
```

#### 3.2 Advertising Slots
```
Definition: Number of ad opportunities per hour

Configuration:
advertising_slots_per_hour: Integer (6-60)

Default: 12 slots/hour (1 ad per 5 minutes)

Common Configurations:
- Low traffic: 6 slots/hour (1 ad per 10 min)
- Medium traffic: 12 slots/hour (1 ad per 5 min)
- High traffic: 24 slots/hour (1 ad per 2.5 min)
- Very high traffic: 60 slots/hour (1 ad per minute)

Calculation:
minutes_per_slot = 60 / advertising_slots_per_hour

Example:
  12 slots/hour → 60/12 = 5 minutes per slot
  Device plays 1 ad every 5 minutes

Business Rules:
- Minimum: 6 slots/hour (avoid ad fatigue)
- Maximum: 60 slots/hour (1 per minute limit)
- Each slot can play 1 ad (duration varies)
- If no ads in queue, show fallback content
- Slots evenly distributed throughout hour
- Configuration can be updated anytime (takes effect next hour)

Slot Allocation Example (12 slots/hour):
Hour 10:00-11:00:
  Slot 1: 10:00-10:05 → Ad A (30 seconds)
  Slot 2: 10:05-10:10 → Ad B (15 seconds)
  Slot 3: 10:10-10:15 → Ad C (45 seconds)
  ...
  Slot 12: 10:55-11:00 → Ad L (20 seconds)

Impact on Revenue:
More slots = more ad opportunities = higher potential revenue
But too many ads = customer annoyance = lower quality score
Optimal: 12-24 slots/hour for most retail environments
```

#### 3.3 Content Duration Limits
```
Definition: Maximum duration for a single ad or content piece

Configuration:
max_content_duration: Integer (10-300 seconds)

Default: 60 seconds

Business Rules:
- Minimum: 10 seconds (too short is ineffective)
- Maximum: 300 seconds (5 minutes, avoid attention fatigue)
- Applies to all content types (video, image slideshow)
- Content longer than max_duration rejected at upload
- Device will not play content exceeding limit

Recommended by Store Type:
- Supermarket checkout: 15-30 seconds (quick transactions)
- Mall corridor: 30-60 seconds (moderate foot traffic)
- Waiting area: 60-120 seconds (captive audience)
- Restaurant: 30-45 seconds (dining environment)

Duration vs Engagement:
- 10-15s: High attention, simple message
- 15-30s: Standard ad length, most common
- 30-60s: Detailed message, product showcase
- 60-120s: Story-telling, brand awareness
- 120-300s: Long-form content, entertainment

Enforcement:
1. At content upload:
   IF content.duration > store.max_content_duration:
     ERROR: "Content too long for this store"

2. At device playback:
   IF content.duration > device.max_content_duration:
     Skip content
     Log warning

3. At campaign creation:
   Show estimated impressions based on content duration:
   impressions_per_day = (
     advertising_slots_per_day /
     (content.duration / average_slot_duration)
   )
```

---

## Heartbeat & Health Monitoring

### Rule 4: Heartbeat Protocol

#### 4.1 Heartbeat Frequency
```
Standard Frequency: Every 5 minutes (300 seconds)

Adaptive Frequency:
- Device ACTIVE & healthy: 5 minutes
- Device DEGRADED (high errors): 2 minutes
- Device OFFLINE recovery: 1 minute (first 30 min after recovery)
- Device MAINTENANCE: 30 minutes

Configurable per device:
device.heartbeat_interval = 300 // seconds

Missed Heartbeat Tolerance:
- 1 missed (5 min late): No action, may be temporary network issue
- 2 missed (10 min late): Mark as OFFLINE
- 6 missed (30 min late): Urgent alert to supplier
- 24 missed (2 hours late): Critical alert, may need on-site visit

Business Rules:
- Server expects heartbeat every N seconds (configured)
- Server timestamps each heartbeat (not trusting device clock)
- Heartbeat must be signed with device private key
- Missing heartbeats trigger progressive alerts
- Device can request frequency change (e.g., power-saving mode)
```

#### 4.2 Heartbeat Data Points

**Device Status Information**:

| Data Point | Description |
|------------|-------------|
| Device ID | Unique device identifier |
| Timestamp | Device local time |
| Sequence Number | Monotonically increasing (prevents replay attacks) |
| Status | ONLINE, DEGRADED, ERROR |

**Device Health Metrics**:

| Metric | Range | Description |
|--------|-------|-------------|
| CPU Usage | 0-100% | Current processor utilization |
| Memory Usage | 0-100% | RAM utilization |
| Disk Usage | 0-100% | Storage utilization |
| Network Latency | ms | Connection quality |
| Temperature | °C | Hardware temperature (optional) |

**Playback Status**:

| Status | Description |
|--------|-------------|
| Screen On/Off | Display power state |
| Content Playing | Currently playing content ID |
| Playlist Position | Current position in rotation |
| Last Impression | Timestamp of last ad play |

**Validation Rules**:
- Device must exist in database
- Signature must be valid (signed with device private key)
- Sequence number must be greater than last (prevents replay attacks)
- Timestamp must be within ±10 minutes of server time
- All percentage metrics must be 0-100
- All referenced content/campaign IDs must exist

**Server Response**:

| Response Field | Description |
|----------------|-------------|
| Status | OK, CONFIG_UPDATE, ACTION_REQUIRED |
| Next Heartbeat Interval | Seconds until next expected heartbeat |
| Config Version | Current configuration version |
| Actions | List of required device actions |
| Messages | System messages for device |

#### 4.3 Heartbeat Failure Handling
```
Scenario: Device fails to send heartbeat

Server Side Detection:
1. Background job runs every 2 minutes:

   check_missing_heartbeats():
     now = NOW()

     // Find devices that should have sent heartbeat
     late_devices = Devices.where(
       status: ACTIVE,
       last_heartbeat_at < (now - heartbeat_interval - grace_period)
     )

     grace_period = 120 seconds // 2 minutes tolerance

     FOR EACH device IN late_devices:
       missed_count = (
         (now - device.last_heartbeat_at) / device.heartbeat_interval
       )

       IF missed_count >= 2:
         mark_device_offline(device, missed_count)

2. Mark device offline:

   mark_device_offline(device, missed_count):
     device.update(
       status: OFFLINE,
       went_offline_at: NOW(),
       missed_heartbeats: missed_count
     )

     // Stop serving ads
     remove_from_campaign_rotation(device)

     // Alert supplier
     IF missed_count >= 2:
       send_notification(
         device.supplier,
         "Device {device_code} offline (missed {missed_count} heartbeats)"
       )

     IF missed_count >= 6: // 30 minutes
       send_urgent_alert(
         device.supplier,
         "Device {device_code} offline for 30+ minutes"
       )

     IF missed_count >= 24: // 2 hours
       send_critical_alert(
         device.supplier + admin,
         "Device {device_code} offline for 2+ hours - needs investigation"
       )

3. Device recovery:

   When offline device sends heartbeat:

   IF device.status == OFFLINE:
     downtime_minutes = (NOW() - went_offline_at) / 60

     device.update(
       status: ACTIVE,
       last_heartbeat_at: NOW(),
       came_online_at: NOW(),
       total_downtime_minutes += downtime_minutes
     )

     // Recalculate health score
     recalculate_health_score(device)

     // Resume ad serving
     add_to_campaign_rotation(device)

     // Trigger content sync (may be outdated)
     trigger_content_sync(device, force: true)

     // Notify supplier
     send_notification(
       device.supplier,
       "Device {device_code} back online after {downtime_minutes} minutes"
     )

     // Adjust heartbeat frequency temporarily
     device.update(heartbeat_interval: 60) // 1 min for next 30 min

     schedule_job(after: 30.minutes):
       device.update(heartbeat_interval: 300) // Back to normal

Business Rules:
- 2 missed heartbeats = offline (10 minutes with 5-min interval)
- Offline devices automatically removed from ad rotation
- No impressions/billing during offline period
- Device auto-recovers on next successful heartbeat
- Increased heartbeat frequency after recovery (monitoring)
- Supplier notified at: 10 min, 30 min, 2 hours offline
```

---

## Content Synchronization

### Rule 5: Content Sync Strategy

#### 5.1 Sync Types
```
Three types of content synchronization:

1. FULL SYNC (Initial sync):
   When: Device first activation or complete playlist change
   Process:
     - Download entire playlist
     - All content assets
     - Verify checksums
     - Clear old cache
   Duration: 5-60 minutes (depends on content size)

2. INCREMENTAL SYNC (Regular updates):
   When: Periodic checks (every 1 hour) or playlist updates
   Process:
     - Compare local manifest with server manifest
     - Download only new/changed content
     - Keep existing cached content
     - Verify new content checksums
   Duration: 1-10 minutes

3. FORCED SYNC (Troubleshooting):
   When: Admin-triggered or device reports errors
   Process:
     - Delete all local content
     - Re-download everything (like FULL SYNC)
     - Rebuild cache
     - Verify entire playlist
   Duration: 5-60 minutes
```

#### 5.2 Sync Frequency
```
Default Schedule:
- Regular check: Every 1 hour
- Quick check: After heartbeat if playlist_updated flag set
- Immediate: When urgent campaign changes

Adaptive Frequency:
- High-value device (premium stores): Every 30 minutes
- Standard device: Every 1 hour
- Low-traffic device: Every 2 hours
- Night hours (outside operating hours): Every 6 hours

Trigger Conditions:
1. Scheduled (time-based):
   CRON job every hour → check for updates

2. Event-driven (immediate):
   - New campaign activated for this device
   - Campaign paused/cancelled
   - Content updated (new version)
   - Admin forces sync

3. Device-initiated:
   - Device detects missing content
   - Content playback error
   - After offline recovery

Business Rules:
- Minimum interval: 10 minutes (prevent spam)
- Maximum interval: 6 hours (ensure freshness)
- Sync only during operating hours (preferred)
- Emergency sync allowed 24/7
- Bandwidth-aware: throttle during peak hours
```

#### 5.3 Sync Process
```
Step-by-Step Sync Flow:

1. Device requests sync:

   GET /devices/:id/playlist/manifest
   Headers:
     X-Device-Signature: {signature}
     X-Current-Manifest-Version: "v1.2.3"
     X-Local-Content-Hashes: ["hash1", "hash2", ...]

2. Server generates manifest:

   manifest = {
     "version": "v1.2.5",
     "updated_at": "2026-01-23T10:00:00Z",
     "playlist_id": "uuid",
     "ttl_seconds": 3600, // Cache for 1 hour
     "content_items": [
       {
         "content_id": "uuid1",
         "campaign_id": "uuid-campaign1",
         "url": "https://cdn.rmn-arms.com/content/uuid1.mp4",
         "checksum": "sha256:abc123...",
         "size_bytes": 15728640,
         "duration_seconds": 30,
         "priority": 10,
         "weight": 50,
         "valid_from": "2026-01-23T00:00:00Z",
         "valid_until": "2026-02-23T23:59:59Z"
       },
       // ... more items
     ],
     "fallback_content": {
       "content_id": "default-uuid",
       "url": "https://cdn.rmn-arms.com/content/fallback.mp4",
       "checksum": "sha256:def456...",
       "duration_seconds": 15
     },
     "sync_required": true, // or false if no changes
     "changes": {
       "added": ["uuid1", "uuid3"],
       "removed": ["uuid5"],
       "updated": ["uuid2"]
     }
   }

3. Server compares versions:

   IF manifest.version == request.X-Current-Manifest-Version:
     RETURN {sync_required: false} // Up to date
   ELSE:
     RETURN full manifest with changes

4. Device downloads new content:

   FOR EACH content_id IN manifest.changes.added + manifest.changes.updated:
     download_content(content_id)
     verify_checksum(content_id)
     IF checksum_valid:
       save_to_cache(content_id)
     ELSE:
       retry_download(content_id, max_retries: 3)

5. Device deletes old content:

   FOR EACH content_id IN manifest.changes.removed:
     delete_from_cache(content_id)

6. Device confirms sync:

   POST /devices/:id/playlist/sync-complete
   {
     "manifest_version": "v1.2.5",
     "synced_content_ids": ["uuid1", "uuid2", "uuid3"],
     "failed_content_ids": [],
     "total_bytes_downloaded": 52428800,
     "sync_duration_seconds": 125,
     "status": "COMPLETED"
   }

7. Server updates device record:

   device.update(
     last_sync_at: NOW(),
     current_manifest_version: "v1.2.5",
     sync_status: "COMPLETED"
   )

Business Rules:
- Checksum verification mandatory (prevent corruption)
- Failed downloads retried 3 times with exponential backoff
- Partial sync acceptable (device continues with available content)
- Manifest cached for TTL period (reduce server load)
- Old content deleted after successful sync (save disk space)
- Sync failures logged and alerted if persistent
```

#### 5.4 Bandwidth Management
```
Problem: Large video files can consume significant bandwidth

Strategy:
1. Adaptive bitrate:
   IF network_bandwidth < 1 Mbps:
     Use low-quality version (720p)
   ELSE IF network_bandwidth < 5 Mbps:
     Use medium-quality version (1080p)
   ELSE:
     Use high-quality version (4K)

2. Time-based throttling:
   IF current_hour BETWEEN 09:00 AND 18:00: // Business hours
     max_bandwidth = 2 Mbps // Throttled
   ELSE: // Off-hours
     max_bandwidth = 10 Mbps // Full speed

3. Progressive download:
   - Download high-priority content first
   - Low-priority content during idle time
   - Pause download if device busy (playing content)

4. Delta sync:
   - Only transfer changed portions of files (if supported)
   - Reduces bandwidth for updated content

5. CDN optimization:
   - Geographically distributed CDN
   - Edge caching reduces latency
   - Automatic failover to alternate CDN

Priority Levels:
- URGENT: Campaign starting within 1 hour → max bandwidth
- HIGH: Campaign starting within 24 hours → normal bandwidth
- NORMAL: Campaign starting >24 hours → throttled bandwidth
- LOW: Fallback content updates → off-hours only

Business Rules:
- Max bandwidth configurable per device
- Sync paused if network unavailable
- Partial content playback not allowed (must be complete)
- Content cached indefinitely until replaced
- CDN costs included in platform fees
```

---

## Playback Management

### Rule 6: Playlist Scheduling

#### 6.1 Playlist Generation
```
Purpose: Create optimized ad playlist for each device

Trigger:
- New campaign activated
- Campaign budget updated
- Device comes online
- Scheduled refresh (every hour)

Process:
1. Get eligible campaigns:

   eligible_campaigns = Campaigns.where(
     status: ACTIVE,
     remaining_budget > 0,
     start_date <= NOW(),
     end_date >= NOW(),
     target_stores CONTAINS device.store_id
   ).where_not(
     blocked_stores CONTAINS device.store_id
   )

2. Calculate weights:

   FOR EACH campaign IN eligible_campaigns:
     weight = (
       campaign.priority ×
       campaign.remaining_budget_ratio ×
       campaign.performance_multiplier
     )

     remaining_budget_ratio = remaining_budget / total_budget
     performance_multiplier = campaign.ctr / average_ctr (if available)

3. Allocate slots:

   total_weight = SUM(all weights)
   slots_per_hour = device.advertising_slots_per_hour

   FOR EACH campaign:
     allocated_slots = (campaign.weight / total_weight) × slots_per_hour

     Example:
       Campaign A: weight = 10, gets (10/20) × 12 = 6 slots/hour
       Campaign B: weight = 7, gets (7/20) × 12 = 4 slots/hour
       Campaign C: weight = 3, gets (3/20) × 12 = 2 slots/hour

4. Create playlist items:

   FOR EACH campaign:
     FOR i IN 1..allocated_slots:
       DevicePlaylist.create(
         device_id: device.id,
         campaign_id: campaign.id,
         content_asset_id: select_content(campaign),
         priority: campaign.priority,
         weight: campaign.weight,
         start_date: NOW(),
         end_date: campaign.end_date,
         status: ACTIVE
       )

5. Shuffle playlist:

   // Prevent same ad playing consecutively
   playlist = device.playlist_items.shuffle_with_constraints(
     min_gap_same_campaign: 2, // At least 2 other ads between same campaign
     max_consecutive_high_priority: 3 // Max 3 high-priority ads in a row
   )

6. Add fallback content:

   // If playlist empty or all campaigns exhausted
   fallback_item = DevicePlaylist.create(
     device_id: device.id,
     campaign_id: nil,
     content_asset_id: default_fallback_content_id,
     priority: 0,
     weight: 1,
     status: ACTIVE
   )

Business Rules:
- Playlist refreshed every hour (or when campaigns change)
- Higher priority campaigns get more slots
- Campaigns with more budget get more slots
- No same campaign consecutively (min gap: 2 ads)
- Fallback content when no campaigns available
- Device caches playlist locally (works offline temporarily)
```

#### 6.2 Playback Sequence
```
Device-side playback logic:

1. Load playlist:

   playlist = load_from_cache("playlist.json")
   IF playlist.expired OR playlist.empty:
     trigger_sync()
     WAIT for sync complete
     playlist = load_from_cache("playlist.json")

2. Select next content:

   select_next_content():
     current_time = device_local_time()

     // Filter valid items
     valid_items = playlist.filter(item =>
       item.valid_from <= current_time <= item.valid_until
       AND item.status == ACTIVE
       AND content_exists_locally(item.content_id)
     )

     IF valid_items.empty:
       RETURN fallback_content

     // Weighted random selection
     total_weight = SUM(valid_items.weight)
     random_value = random(0, total_weight)

     cumulative = 0
     FOR EACH item IN valid_items:
       cumulative += item.weight
       IF random_value <= cumulative:
         RETURN item

     // Fallback (should not reach here)
     RETURN valid_items[0]

3. Play content:

   play_content(item):
     // Pre-flight checks
     IF NOT is_operating_hours():
       SKIP // Don't play outside hours

     IF NOT content_file_exists(item.content_id):
       LOG error: "Content missing"
       trigger_sync()
       RETURN fallback_content

     // Load content
     content = load_content_file(item.content_id)

     // Start playback
     player.load(content)
     player.play()

     start_time = NOW()

     // Monitor playback
     player.on_progress(callback):
       progress_percent = (current_time / duration) × 100

       // Record impression at 80% complete
       IF progress_percent >= 80 AND NOT impression_recorded:
         record_impression(item, start_time, progress_percent)
         impression_recorded = true

     player.on_complete(callback):
       // Content finished playing
       item.play_count += 1
       item.last_played_at = NOW()
       update_playlist_item(item)

       // Select next content
       next_item = select_next_content()
       play_content(next_item)

     player.on_error(callback):
       LOG error: "Playback failed"
       // Try fallback
       play_content(fallback_content)

4. Slot timing:

   wait_for_next_slot():
     minutes_per_slot = 60 / device.advertising_slots_per_hour
     next_slot_time = calculate_next_slot_boundary(minutes_per_slot)
     sleep_duration = next_slot_time - NOW()

     IF sleep_duration > 0:
       sleep(sleep_duration)

     Example (12 slots/hour = 5 min per slot):
       Current time: 10:03:30
       Next slot: 10:05:00
       Sleep: 90 seconds

5. Main loop:

   main_playback_loop():
     WHILE true:
       IF is_operating_hours():
         item = select_next_content()
         play_content(item)
         wait_for_next_slot()
       ELSE:
         // Outside hours: sleep mode
         turn_screen_off()
         sleep_until_next_operating_hour()

Business Rules:
- Content selected randomly weighted by priority
- Same campaign min 2-slot gap (prevent fatigue)
- Impression recorded at 80% completion
- Missing content triggers sync
- Fallback content used if playlist empty
- Playback only during operating hours
- Slots evenly distributed throughout hour
```

---

## Device Configuration

### Rule 7: Device Settings

#### 7.1 Screen Configuration
```
Screen Size:
- Range: 32-100 inches
- Common sizes: 42", 55", 65", 75"
- Affects CPM rate (larger screens = higher rates)
- Immutable after registration (hardware spec)

Screen Resolution:
- Minimum: 1920x1080 (Full HD)
- Recommended: 3840x2160 (4K)
- Supported formats:
  * 1920x1080 (1080p FHD)
  * 2560x1440 (1440p QHD)
  * 3840x2160 (4K UHD)
  * 7680x4320 (8K, future)
- Affects content quality requirements
- Higher resolution = quality premium (+20% CPM)

Screen Orientation:
- LANDSCAPE (default): 16:9 ratio
- PORTRAIT: 9:16 ratio
- Affects content format requirements
- Cannot be changed (requires different content)

Business Rules:
- Content must match device resolution (or higher)
- Content must match orientation
- Screen size verified during activation
- Larger screens eligible for premium campaigns
- 4K devices get +20% revenue share bonus
```

#### 7.2 Hardware Specifications
```
Required Device Specs:

Minimum Hardware:
- CPU: Quad-core 1.5 GHz
- RAM: 2 GB
- Storage: 16 GB (minimum 8 GB free)
- Network: 10 Mbps download, 2 Mbps upload
- GPS: Optional but recommended
- TPM/Secure Element: Required for key storage

Recommended Hardware:
- CPU: Octa-core 2.0 GHz
- RAM: 4 GB
- Storage: 32 GB SSD
- Network: 50 Mbps download, 10 Mbps upload
- GPS: Built-in
- 4G/5G: Backup connectivity

Supported OS:
- Android: 8.0+ (API level 26+)
- Windows: Windows 10/11 IoT Enterprise
- Linux: Ubuntu 20.04+ or custom signage OS
- webOS: 4.0+ (LG Smart TV)
- Tizen: 5.0+ (Samsung Smart TV)

Device Models (Certified):
- Commercial signage displays (Samsung, LG, Philips)
- Android TV boxes (certified models)
- Raspberry Pi 4+ (with official player)
- Intel NUC + display
- Custom builds (requires certification)

Business Rules:
- Hardware specs verified during activation
- Below-minimum specs rejected
- Certified devices get priority support
- Non-certified devices allowed but unsupported
- Hardware upgrades require re-activation
```

---

## Fraud Detection & Security

### Rule 8: Fraud Prevention

#### 8.1 Suspicious Activity Detection
```
Fraud Patterns:

1. Impression Frequency Anomaly:

   Detection:
   impressions_per_hour = COUNT(impressions in last hour)
   expected_max = device.advertising_slots_per_hour

   IF impressions_per_hour > expected_max × 1.2:
     FLAG as "excessive_impressions"
     REASON: "Device reported {actual} impressions/hour, expected max {expected}"

2. Location Anomaly:

   Detection:
   IF device.location AND store.location:
     distance = haversine(device.location, store.location)

     IF distance > 1 km:
       FLAG as "location_mismatch"
       REASON: "Device {distance}km away from registered store"

3. Clock Skew Manipulation:

   Detection:
   time_diff = abs(device_timestamp - server_timestamp)

   IF time_diff > 10 minutes:
     FLAG as "clock_skew"
     REASON: "Device clock off by {time_diff} minutes"

   // Detect time travel attacks
   IF device_timestamp < last_device_timestamp:
     FLAG as "time_reversal"
     REASON: "Device timestamp moved backwards"

4. Duplicate Impression Attempts:

   Detection:
   recent_impressions = Impressions.where(
     device_id: X,
     campaign_id: Y,
     played_at: LAST 5 MINUTES
   )

   IF recent_impressions.count >= 2:
     FLAG as "duplicate_impression"
     REASON: "Multiple impressions for same campaign within 5 min"

5. Signature Verification Failures:

   Detection:
   IF NOT verify_signature(data, signature, device.public_key):
     FLAG as "invalid_signature"
     REASON: "Request signature verification failed"

     consecutive_failures += 1
     IF consecutive_failures >= 3:
       FLAG as "compromised_device"
       SUSPEND device

6. Offline Device Playing Ads:

   Detection:
   IF device.status == OFFLINE:
     AND impression.played_at > device.last_heartbeat_at + 10 minutes:
       FLAG as "offline_impression"
       REASON: "Impression reported while device offline"

7. Content Hash Mismatch:

   Detection:
   IF impression.proof_screenshot_hash NOT IN valid_content_hashes:
     FLAG as "invalid_content"
     REASON: "Screenshot doesn't match any approved content"

8. Rapid Device Registration:

   Detection:
   IF supplier.devices_registered_last_hour > 10:
     FLAG as "mass_registration"
     REASON: "Supplier registered {count} devices in 1 hour"
     Trigger manual review

Actions on Fraud Detection:

Level 1 (Warning):
- Log suspicious activity
- Continue operation
- Notify supplier to investigate
- Examples: Minor clock skew, location slightly off

Level 2 (Hold):
- Hold impressions for review
- Continue operation but no billing
- Manual admin review within 24h
- Examples: Excessive impressions, location anomaly

Level 3 (Suspend):
- Suspend device immediately
- Stop all ad serving
- Freeze supplier payout
- Admin investigation required
- Examples: Invalid signatures, compromised device, proven fraud

Business Rules:
- Suspicious activity logged permanently
- Multiple flags increase severity
- Supplier notified at each flag (transparency)
- False positives can be appealed
- Persistent fraud = permanent ban
```

#### 8.2 Security Measures
```
1. Device Authentication:

   Every API request must include:
   - Device ID (public identifier)
   - Timestamp (prevent replay attacks)
   - Signature (signed with device private key)

   Signature algorithm: RSA-SHA256

   signature = sign_with_private_key(
     SHA256(device_id + timestamp + request_body)
   )

   Server verifies:
   verified = verify_with_public_key(
     signature,
     SHA256(device_id + timestamp + request_body),
     device.public_key
   )

2. Replay Attack Prevention:

   - Request timestamp must be within ±5 minutes of server time
   - Sequence number must be monotonically increasing
   - Server caches recent request hashes (5 min TTL)
   - Duplicate requests rejected

3. Man-in-the-Middle Prevention:

   - All communication over TLS 1.3
   - Certificate pinning in player app
   - Public key infrastructure (PKI)
   - Device certificate rotation every 90 days

4. Content Integrity:

   - All content signed by server
   - Device verifies signature before playing
   - Checksum verification (SHA256)
   - Tampered content rejected

5. Proof-of-Play Security:

   - Screenshot hash required
   - Timestamp embedded in proof
   - Device signature required
   - Location included (if available)
   - Server validates all fields

6. Key Management:

   - Private key stored in secure element (TPM/TEE)
   - Key never leaves device
   - Public key registered during activation
   - Key rotation supported (manual process)
   - Compromised keys revoked immediately

7. Firmware Security:

   - Signed firmware updates only
   - Verification before installation
   - Rollback protection
   - Secure boot enabled
   - OTA updates over TLS

Business Rules:
- Security checks on every API call
- Failed security checks = immediate rejection
- 3 consecutive failures = device suspension
- Security incidents logged and alerted
- Compromised devices permanently banned
```

---

## Firmware & Software Updates

### BR-DEVICE-FW-001: Update Types
```
UPDATE CATEGORIES:

1. PLAYER_UPDATE:
   - RMN player application updates
   - Managed by platform
   - Automatic or manual deployment

2. FIRMWARE_UPDATE:
   - Device OS/firmware updates
   - May require coordination with device manufacturer
   - Often requires reboot

3. SECURITY_PATCH:
   - Critical security updates
   - Mandatory deployment
   - May force update

4. CONFIGURATION_UPDATE:
   - Settings changes (no binary update)
   - Applied via heartbeat response
   - No reboot required
```

### BR-DEVICE-FW-002: Update Deployment Strategies
```
DEPLOYMENT STRATEGIES:

1. IMMEDIATE:
   - Security patches (critical)
   - Device downloads and installs ASAP
   - May interrupt playback
   - Used for: security vulnerabilities

2. SCHEDULED:
   - Standard updates
   - Install during configured maintenance window
   - Default: 2 AM - 5 AM local time
   - No playback interruption during business hours

3. ROLLING:
   - Gradual rollout (5% → 25% → 50% → 100%)
   - Monitor for issues at each stage
   - Automatic rollback if error rate high
   - Used for: major player updates

4. CANARY:
   - Deploy to small test group first (2-3 devices per supplier)
   - 24-48 hour observation period
   - Manual approval to proceed
   - Used for: experimental features

DEPLOYMENT MATRIX:
| Update Type | Default Strategy | Override Allowed |
|-------------|------------------|------------------|
| Security patch (critical) | IMMEDIATE | No |
| Security patch (moderate) | SCHEDULED | Yes |
| Player update (major) | ROLLING | Yes |
| Player update (minor) | SCHEDULED | Yes |
| Firmware update | SCHEDULED | Yes (supplier) |
| Config update | IMMEDIATE | N/A |
```

### BR-DEVICE-FW-003: Update Process Flow
```
1. UPDATE AVAILABLE:
   - Platform releases new version
   - Compatibility check per device type
   - Create update manifest

2. NOTIFICATION:
   - Heartbeat response includes update info:
     {
       "update_available": true,
       "update_type": "PLAYER_UPDATE",
       "version": "2.1.0",
       "current_version": "2.0.5",
       "strategy": "SCHEDULED",
       "scheduled_time": "2026-02-01T02:00:00+07:00",
       "download_url": "https://updates.rmn-arms.com/player/2.1.0",
       "checksum": "sha256:...",
       "size_bytes": 52428800,
       "release_notes_url": "https://docs.rmn-arms.com/releases/2.1.0",
       "mandatory": false
     }

3. DOWNLOAD:
   - Device downloads in background
   - Does not interrupt playback
   - Verify checksum after download
   - Retry up to 3 times if failed

4. INSTALLATION:
   - At scheduled time OR when device idle
   - Save current state (playlist position)
   - Install update
   - Restart player (or device if firmware)
   - Resume playback

5. VERIFICATION:
   - Post-update heartbeat sent
   - Include new version info
   - Server verifies update successful
   - Mark update as completed

6. ROLLBACK (if failed):
   - Automatic rollback to previous version
   - Alert sent to platform
   - Device continues with old version
   - Investigation triggered
```

### BR-DEVICE-FW-004: Update Failure Handling
```
FAILURE SCENARIOS:

1. DOWNLOAD FAILED:
   - Retry 3 times with exponential backoff
   - Try alternate CDN if available
   - If all fail: Log error, continue current version
   - Alert supplier if persistent

2. CHECKSUM MISMATCH:
   - Delete downloaded file
   - Re-download from scratch
   - If persists: Alert admin (potential CDN issue)

3. INSTALLATION FAILED:
   - Automatic rollback triggered
   - Device boots into previous version
   - Alert sent: "Update failed on device {code}"
   - Device marked: "update_failed"

4. DEVICE BRICKED:
   - Device fails to boot after update
   - Recovery mode (if supported):
     * Boot into safe mode
     * Download factory recovery image
     * Restore to last known good state
   - If unrecoverable: Manual intervention required

5. PARTIAL UPDATE:
   - Power loss during installation
   - Device attempts recovery on next boot
   - If recoverable: Continue update
   - If not: Rollback or safe mode

MONITORING:
- Track update success rate per version
- Alert if success rate < 95%
- Pause rollout if rate < 90%
- Post-mortem required for major failures
```

### BR-DEVICE-FW-005: Mandatory Updates
```
MANDATORY UPDATE CRITERIA:
- Security vulnerability (CVSS score >= 7.0)
- Compliance requirement
- End-of-life for current version
- Critical bug affecting billing/impressions

MANDATORY UPDATE PROCESS:
1. Announcement: 7 days notice minimum
2. Grace period: Allow scheduled update time
3. Force update: If not updated within grace period
4. Escalation: Device may be blocked from serving ads

FORCE UPDATE RULES:
IF device.version < minimum_required_version:
  IF grace_period_expired:
    // Force update on next heartbeat
    heartbeat_response.update_required = true
    heartbeat_response.block_impressions = true

    // Device cannot record impressions until updated
    // Prevents billing with vulnerable/buggy software
```

---

## Device Replacement & Transfer

### BR-DEVICE-REPLACE-001: Device Replacement (Same Location)
```
SCENARIO: Device failed, replacing with new device at same store

PROCESS:
1. DECOMMISSION OLD DEVICE:
   Actor: Supplier
   - Select old device in dashboard
   - Click "Replace Device"
   - Choose reason: HARDWARE_FAILURE / UPGRADE / DAMAGE / OTHER
   - Old device → DECOMMISSIONED

2. REGISTER NEW DEVICE:
   - Scan new device QR code
   - System prompts: "Replace existing device?"
   - Confirm replacement

3. TRANSFER CONFIGURATION:
   New device inherits from old device:
   - Store assignment
   - Operating hours
   - Advertising slots config
   - Timezone settings

   NOT transferred:
   - Device-specific stats (impressions, revenue)
   - Health score (starts at 100)
   - Maintenance history

4. ACTIVATION:
   - New device sends first heartbeat
   - Status → ACTIVE
   - Playlist immediately available
   - No gap in service (if done during low-traffic)

5. AUDIT:
   ReplacementLog {
     old_device_id: UUID,
     new_device_id: UUID,
     store_id: UUID,
     reason: Enum,
     replaced_at: DateTime,
     replaced_by: UUID (supplier user)
   }

BUSINESS RULES:
- Old device stats preserved for reporting
- New device starts fresh metrics
- Campaign targeting continues seamlessly
- No advertiser notification needed (same store)
```

### BR-DEVICE-REPLACE-002: Device Transfer (Between Stores)
```
SCENARIO: Moving device from one store to another (same supplier)

PROCESS:
1. INITIATE TRANSFER:
   Actor: Supplier
   - Select device
   - Click "Transfer to Different Store"
   - Select target store (must belong to supplier)
   - Set transfer date/time

2. PRE-TRANSFER CHECKS:
   ✓ Target store is ACTIVE
   ✓ Target store belongs to same supplier
   ✓ Device is ACTIVE or OFFLINE (not MAINTENANCE)
   ✓ No pending unresolved issues

3. IMPACT ANALYSIS:
   System shows:
   - Active campaigns affected
   - Impressions lost estimate
   - Revenue impact estimate
   - Campaigns that will gain this device

4. SCHEDULE TRANSFER:
   IF immediate:
     Execute now
   ELSE:
     Schedule for specified time
     Device continues at old store until then

5. EXECUTE TRANSFER:
   // Put device in maintenance briefly
   device.status = MAINTENANCE

   // Update store assignment
   device.store_id = new_store_id

   // Update campaigns
   FOR EACH campaign targeting old_store:
     Remove device from campaign playlist

   FOR EACH campaign targeting new_store:
     Add device to campaign playlist

   // Physical move happens
   // Wait for device to come online at new location

6. VERIFY TRANSFER:
   - Device heartbeat from new location
   - GPS confirms new store location (if available)
   - Device status → ACTIVE
   - Transfer marked COMPLETED

BUSINESS RULES:
- Transfer takes up to 24 hours to complete
- Device in MAINTENANCE during physical move
- No impressions during transfer
- Stats continue accumulating (no reset)
- Campaigns auto-adjust targeting
```

### BR-DEVICE-REPLACE-003: Device Transfer (Between Suppliers)
```
SCENARIO: Supplier sells device to another supplier (rare)

REQUIREMENTS:
- Both suppliers must agree
- No outstanding debts/disputes
- Admin approval required

PROCESS:
1. SOURCE SUPPLIER:
   - Initiates transfer request
   - Specifies target supplier
   - Provides reason

2. TARGET SUPPLIER:
   - Receives transfer request
   - Reviews device details
   - Accepts or rejects

3. ADMIN REVIEW:
   - Verify both parties consent
   - Check for pending issues
   - Approve transfer

4. EXECUTE TRANSFER:
   // Update ownership
   device.supplier_id = new_supplier_id
   device.store_id = null // Must be reassigned
   device.status = REGISTERED // Back to initial state

   // Clear sensitive data
   device.private_key = regenerate() // New key pair
   device.health_score = 100 // Reset

   // Stats archived, not transferred
   archive_device_stats(device)
   reset_device_stats(device)

5. NEW SUPPLIER:
   - Assigns device to their store
   - Activates device
   - Starts fresh

BUSINESS RULES:
- Rare operation, requires admin approval
- Device essentially "factory reset" for new owner
- Historical stats archived (not visible to new owner)
- New key pair generated (security)
- 30-day waiting period option (prevents fraud)
```

### BR-DEVICE-REPLACE-004: Bulk Device Management
```
SCENARIO: Supplier has 100+ devices, needs batch operations

BATCH OPERATIONS SUPPORTED:

1. BULK CONFIGURATION UPDATE:
   - Select multiple devices
   - Update: operating_hours, ad_slots, timezone
   - Apply to all selected
   - Max: 500 devices per batch

2. BULK MAINTENANCE SCHEDULE:
   - Select devices by store, region, or criteria
   - Schedule maintenance window
   - All devices enter MAINTENANCE at same time
   - Useful for network upgrades

3. BULK FIRMWARE UPDATE:
   - Select devices by type/model
   - Push update to all
   - Staggered deployment to prevent network overload
   - Rate limit: 10 devices per minute

4. BULK DECOMMISSION:
   - Retiring fleet of devices
   - Select all to decommission
   - Requires confirmation for each store affected
   - Creates audit trail

5. BULK TRANSFER (Store Closure):
   - Store closing, redistribute devices
   - Select target stores
   - Auto-distribute based on capacity
   - Or manual assignment

PERMISSIONS:
- BULK operations require ADMIN role on supplier account
- Logged with detailed audit trail
- Email notification for any bulk action > 10 devices
```

---

## Edge Cases & Error Handling

### Edge Case 1: Device Loses Network During Content Playback

```
Scenario: Device playing content, network disconnects mid-playback

Behavior:
1. Content continues playing (cached locally)
2. Impression recorded locally with timestamp
3. Device queues impression for submission
4. Device continues to next content in playlist
5. When network restored:
   - Submit queued impressions (with backfill timestamps)
   - Heartbeat sent immediately
   - Sync triggered to check for updates

Validation:
Server accepts backfill impressions IF:
- Timestamp within last 4 hours
- Device went offline during that period
- Signature valid
- No duplicate impressions

Business Rule:
- Device can operate offline for up to 4 hours
- Impressions recorded offline counted if verified
- Offline >4 hours = impressions rejected (too stale)
```

---

### Edge Case 2: Device Clock Reset to Factory Default

```
Scenario: Device powered off completely, clock resets to 1970-01-01

Detection:
IF device_timestamp < "2020-01-01":
  REJECT request
  RESPONSE: {
    error: "INVALID_TIMESTAMP",
    message: "Device clock appears to be reset. Please sync with NTP.",
    server_time: "2026-01-23T10:00:00Z"
  }

Device Action:
1. Sync with NTP server immediately
2. Update local clock
3. Retry request

Business Rule:
- Device must sync time on boot
- Requests with obviously wrong timestamps rejected
- Device provides server time in rejection (helps debug)
```

---

### Edge Case 3: All Campaigns Exhausted Budget Mid-Day

```
Scenario: Device has empty playlist, all campaigns ran out of budget

Behavior:
1. Device requests playlist update
2. Server returns empty playlist
3. Device plays fallback content
4. Device checks for new campaigns every 10 minutes
5. When new campaigns available:
   - Playlist updated
   - Resume normal ad serving

Fallback Content:
- Store branding
- Generic promotional content
- "Advertising space available" message
- No billing (not an impression)

Business Rule:
- Fallback content always available
- No impressions recorded for fallback
- Device continues checking for campaigns
- Supplier notified of empty playlist (opportunity lost)
```

---

### Edge Case 4: Device Moved to Different Store (Same Supplier)

```
Scenario: Supplier physically moves device without updating system

Detection:
IF device.location AND store.location:
  distance = haversine(device.location, store.location)

  IF distance > 5 km:
    // Likely moved
    FLAG device for review

    // Check if nearby another store owned by same supplier
    nearby_stores = Stores.where(
      supplier_id: device.supplier_id,
      distance < 1 km from device.location
    )

    IF nearby_stores.count == 1:
      // Suggest transfer
      send_notification(
        supplier,
        "Device {device_code} appears to be at {nearby_store.name}. Transfer?"
      )

Manual Process:
1. Supplier confirms device moved
2. Supplier initiates transfer (see Rule 1.2)
3. Device reassigned to correct store
4. Campaigns recalculated

Business Rule:
- GPS location monitored continuously
- Large location change triggers alert
- Auto-transfer not allowed (requires confirmation)
- Prevents accidental billing to wrong store
```

---

### Edge Case 5: Content File Corrupted on Device

```
Scenario: Cached content file corrupted (disk error, incomplete download)

Detection (Device Side):
1. Device loads content for playback
2. Checksum verification fails
3. Or: File not found / unreadable

Action:
// Delete corrupted file
delete_from_cache(content_id)

// Request re-download
trigger_sync(
  type: INCREMENTAL,
  force_download: [content_id]
)

// Play fallback content while waiting
play_content(fallback_content)

// Retry after sync
IF sync_completed AND content_available(content_id):
  play_content(content_id)

Server Response:
// Return fresh CDN URL (bypass cache)
{
  "content_id": "uuid",
  "url": "https://cdn.rmn-arms.com/content/uuid.mp4?nocache={timestamp}",
  "checksum": "sha256:...",
  "size_bytes": 15728640
}

Business Rule:
- Corrupted content triggers automatic re-download
- Checksum verified after every download
- Failed downloads retried 3 times
- Persistent failures flagged for admin review
- Device continues operation with remaining content
```

---

### Edge Case 6: Device Registered But Never Activated

```
Scenario: Device registered but supplier never activated it (shipped, lost, forgotten)

Detection:
stale_devices = Devices.where(
  status: REGISTERED,
  created_at < NOW() - 30 days,
  activated_at: null
)

Action:
FOR EACH device IN stale_devices:
  // Notify supplier
  send_notification(
    device.supplier,
    "Device {device_code} registered 30 days ago but not activated. Need help?"
  )

  // After 90 days, decommission
  IF device.created_at < NOW() - 90 days:
    device.update(
      status: DECOMMISSIONED,
      decommission_reason: "Never activated within 90 days"
    )

    // Free up device code for reuse
    release_device_code(device.device_code)

Business Rule:
- Devices must activate within 90 days
- Reminders at 30, 60 days
- Auto-decommission at 90 days if inactive
- Device codes can be reused after decommission
```

---

### Edge Case 7: Device Hardware Upgraded (New Screen)

```
Scenario: Supplier replaces screen with larger/better one

Process:
1. Supplier updates device config:
   - New screen size
   - New resolution
   - New hardware specs

2. Device sends heartbeat with new hardware info

3. Server detects changes:
   IF hardware_changed(device):
     // Require re-verification
     device.update(status: MAINTENANCE)

     send_notification(
       device.supplier,
       "Hardware change detected. Please re-verify device."
     )

4. Admin or automated verification:
   - Check hardware specs reasonable
   - Verify screen size claim (may require photo upload)
   - Approve or reject

5. If approved:
   device.update(
     status: ACTIVE,
     screen_size_inches: new_size,
     screen_resolution: new_resolution,
     health_score: 100 // Reset score
   )

   // Recalculate CPM rates (larger screen = higher rate)
   recalculate_device_pricing(device)

Business Rule:
- Hardware changes require verification
- Screen size affects CPM rates (larger = more expensive)
- Fraudulent upgrades (claiming larger screen) = ban
- Legitimate upgrades encouraged (better hardware = better experience)
```

---

### Edge Case 8: Device Firmware Update Fails Mid-Install

```
Scenario: Power outage or crash during firmware update

Detection:
- Device fails to send heartbeat after expected update window
- Or device sends heartbeat with boot_state = RECOVERY

Device Behavior:
1. Boot into recovery mode (if supported)
2. Attempt auto-recovery:
   - Boot from backup partition
   - Or download minimal recovery image
3. Report recovery status to server

Server Response:
{
  "recovery_mode": true,
  "recovery_action": "DOWNLOAD_RECOVERY_IMAGE",
  "recovery_url": "https://recovery.rmn-arms.com/device-type/v1.0",
  "checksum": "sha256:...",
  "fallback_version": "2.0.0"
}

Manual Intervention Required If:
- Recovery mode fails
- Device completely unresponsive
- Hardware damage suspected

Business Rules:
- Always maintain backup/recovery partition
- Recovery image stored separately from main
- Physical access may be required for bricked devices
- Supplier notified immediately of bricked device
- Platform covers recovery costs if platform-pushed update caused issue
```

---

### Edge Case 9: Device Reports Impossible Metrics

```
Scenario: Device sends heartbeat with suspicious data

Examples:
- CPU usage: 150% (impossible)
- Memory usage: -20% (negative)
- Disk usage: 0% when content cached (suspicious)
- 1000 impressions per minute (impossible for 12 slots/hour)
- Location: Ocean (device in shopping mall)

Detection:
heartbeat_validation:
  IF cpu_usage < 0 OR cpu_usage > 100:
    flag: INVALID_METRIC
  IF memory_usage < 0 OR memory_usage > 100:
    flag: INVALID_METRIC
  IF impressions_this_hour > advertising_slots_per_hour * 5:
    flag: SUSPICIOUS_IMPRESSIONS
  IF location_valid AND distance_from_store > 100km:
    flag: LOCATION_ANOMALY

Response:
CASE INVALID_METRIC:
  - Log warning
  - Accept heartbeat (device online)
  - Discard invalid values
  - Request diagnostic report

CASE SUSPICIOUS_IMPRESSIONS:
  - Hold impressions for review
  - Flag device for fraud check
  - May suspend impression recording

CASE LOCATION_ANOMALY:
  - Alert supplier
  - Check if device moved
  - Verify GPS hardware functioning

Business Rules:
- Invalid metrics don't crash the system
- Graceful degradation (use last known good values)
- Repeated invalid metrics trigger investigation
- May indicate device compromise or malfunction
```

---

### Edge Case 10: Simultaneous Content Playback Request

```
Scenario: Multiple campaigns want to play at exact same moment

Example:
- Campaign A: Priority 10, 30-second video
- Campaign B: Priority 8, 15-second image
- Both eligible for 10:00 AM slot

Resolution Algorithm:
1. Sort by priority (descending)
2. If same priority: Sort by remaining_budget_ratio (descending)
3. If still tied: Random selection

Device Behavior:
- Receives prioritized playlist
- Plays in order received
- Never plays two contents simultaneously
- Gap between contents: 0-2 seconds (configurable)

Playlist Structure:
{
  "slot_start": "10:00:00",
  "slot_end": "10:05:00",
  "contents": [
    {"campaign_id": "A", "priority": 10, "order": 1},
    {"campaign_id": "B", "priority": 8, "order": 2}
  ],
  "fill_remaining": "fallback"
}

Business Rules:
- No parallel playback (one screen = one content)
- Priority determines order within slot
- Lower priority may not play if slot full
- Fair rotation over time (not always same winner)
```

---

### Edge Case 11: Store Closes Permanently

```
Scenario: Retail store closes, devices need to be handled

Detection:
- Store marked INACTIVE by supplier
- Or: Store lease terminated notification

Process:
1. SUPPLIER NOTIFICATION:
   "Store {name} marked for closure. What to do with {N} devices?"
   Options:
   - Transfer to another store
   - Decommission devices
   - Hold for future assignment

2. CAMPAIGN IMPACT:
   - Remove store from active campaign targeting
   - Notify affected advertisers
   - Recalculate campaign estimates
   - No refunds (targeting was valid at time)

3. DEVICE HANDLING:
   IF transfer:
     - Schedule transfer to new store
     - Content continues until physical move
   IF decommission:
     - Stop content playback
     - Final sync (upload pending impressions)
     - Mark devices DECOMMISSIONED
   IF hold:
     - Devices → MAINTENANCE
     - Content stopped
     - Can be reassigned within 90 days

4. FINANCIAL SETTLEMENT:
   - Process pending supplier revenue
   - Apply 7-day hold period as normal
   - Close store revenue account after settlement

Business Rules:
- Store closure doesn't immediately affect active campaigns
- Gradual wind-down (campaigns adjust targeting)
- Devices salvageable (not tied to store permanently)
- Revenue owed to supplier still paid
```

---

### Edge Case 12: Device Timezone Change (Relocation)

```
Scenario: Device moved to different timezone (e.g., store chain)

Detection:
- Device reports new timezone in heartbeat
- Or: GPS indicates different timezone region

Impact:
- Operating hours interpretation changes
- Peak/off-peak hours shift
- Dayparting rules affected
- Reports need timezone awareness

Process:
1. DETECT CHANGE:
   IF device.reported_timezone != device.configured_timezone:
     flag: TIMEZONE_MISMATCH

2. VALIDATE:
   - Is new timezone consistent with GPS?
   - Is device at a different store?
   - Is this a legitimate move?

3. UPDATE:
   IF legitimate:
     device.timezone = new_timezone
     // Recalculate all time-based settings
     recalculate_operating_hours(device)
     recalculate_dayparting(device)

4. NOTIFY:
   - Supplier: "Device timezone updated to {new_tz}"
   - Affected campaigns: Time targeting may need review

Business Rules:
- Timezone changes require verification
- All timestamps stored in UTC
- Display in device local time
- Historical data retains original timezone context
```

---

### Edge Case 13: Rapid On/Off Cycling (Power Issues)

```
Scenario: Device repeatedly coming online and going offline

Detection:
online_offline_count = DeviceStatusChange.count_last_hour(device_id)
IF online_offline_count > 10:
  flag: POWER_CYCLING

Possible Causes:
- Unstable power supply
- Network flapping
- Device hardware issue
- Someone repeatedly unplugging

Response:
1. ALERT SUPPLIER:
   "Device {code} has power/connectivity issues (cycled {N} times in 1 hour)"

2. IMPACT MITIGATION:
   - Don't count short offline periods as downtime (grace period)
   - Queue impressions during brief outages
   - Resume playback from where stopped

3. HEALTH SCORE IMPACT:
   - Excessive cycling reduces health score
   - Score impact: -5 points per cycle over threshold

4. ESCALATION:
   IF cycles > 20 per hour for > 24 hours:
     - Device → MAINTENANCE (auto)
     - Require physical inspection
     - May indicate need for UPS or electrical work

Business Rules:
- Brief outages (< 2 minutes) tolerated
- Excessive cycling indicates problem
- Automatic maintenance mode if persistent
- Supplier responsible for power stability
```

---

### Edge Case 14: Content Larger Than Device Storage

```
Scenario: Campaign content total size exceeds device storage capacity

Detection (Server Side):
playlist_size = SUM(content.size_bytes for content in playlist)
device_storage = device.available_storage_bytes

IF playlist_size > device_storage * 0.9: // 90% threshold
  flag: STORAGE_OVERFLOW

Resolution Options:
1. PRIORITIZE CONTENT:
   - Keep highest priority campaign content
   - Remove lowest priority until fits
   - Notify affected campaigns

2. STREAMING MODE:
   - Don't cache all content
   - Stream some content on-demand
   - Requires stable network
   - Higher bandwidth usage

3. REDUCE QUALITY:
   - Request lower bitrate version
   - Trade quality for storage
   - Last resort option

4. ROTATE CONTENT:
   - Cache subset of playlist
   - Rotate cached content daily
   - Ensures variety over time

Device Response:
{
  "storage_warning": true,
  "available_bytes": 1073741824,
  "required_bytes": 2147483648,
  "action": "PRIORITIZE",
  "excluded_campaigns": ["uuid1", "uuid2"]
}

Business Rules:
- Device must reserve 10% storage for system
- Prioritization based on campaign priority + CPM
- Advertisers not charged for content that couldn't be cached
- Storage capacity is device specification requirement
```

---

### Edge Case 15: Device Identity Theft Attempt

```
Scenario: Attacker tries to impersonate legitimate device

Attack Vectors:
1. Stolen device_code + guessed private key
2. Man-in-the-middle replay attacks
3. Cloned device attempting registration
4. Compromised device sending fake impressions

Detection:
1. SIGNATURE VERIFICATION:
   - All requests must be signed with device private key
   - Invalid signature → immediate rejection
   - Log attempt for investigation

2. DUPLICATE DETECTION:
   IF two devices claim same device_code:
     - Compare signatures
     - Compare hardware fingerprints
     - One is fraudulent

3. BEHAVIORAL ANALYSIS:
   - Sudden location change
   - Unusual impression patterns
   - Hardware fingerprint change
   - IP address anomalies

Response:
1. IMMEDIATE:
   - Reject fraudulent requests
   - Block suspicious IP
   - Alert security team

2. INVESTIGATION:
   - Review device history
   - Contact supplier
   - Determine if device compromised

3. REMEDIATION:
   IF device compromised:
     - Revoke current keys
     - Issue new key pair (requires physical access)
     - Clear cached content
     - Review all recent impressions

Business Rules:
- Zero tolerance for identity theft
- All fraudulent impressions reversed
- Compromised devices require re-provisioning
- May involve law enforcement for serious cases
```

---

### Edge Case 16: Mass Device Offline (Network/Power Event)

```
Scenario: Multiple devices at same location go offline simultaneously

Detection:
offline_devices = Devices.where(
  store_id: store_id,
  status_changed_to: OFFLINE,
  changed_at > NOW() - 5 minutes
)

IF offline_devices.count / total_devices > 0.5:
  flag: MASS_OFFLINE_EVENT

Possible Causes:
- Store power outage
- Network failure at store
- ISP outage
- Natural disaster
- Scheduled store closure (not updated in system)

Response:
1. ALERT:
   - Notify supplier immediately
   - "Multiple devices offline at {store_name}"

2. DO NOT PENALIZE:
   - Mass event = likely infrastructure issue
   - Don't reduce health scores aggressively
   - Apply "force majeure" consideration

3. TRACK RECOVERY:
   - Monitor for devices coming back online
   - Report recovery time

4. POST-EVENT:
   - Generate incident report
   - Calculate lost impressions/revenue
   - Determine if SLA credit applicable

Business Rules:
- Mass events treated differently than individual failures
- Supplier not penalized for force majeure
- Quick recovery expected (< 24 hours for typical outage)
- Extended outages require investigation
```

---

## Validation Rules

### Device Validation Matrix

| Field | Rule | Error Message |
|-------|------|---------------|
| device_code | Length 16, alphanumeric | "Invalid device code format" |
| device_code | Globally unique | "Device code already exists" |
| store_id | Must be active store | "Store not found or inactive" |
| screen_size_inches | Range 32-100 | "Screen size must be 32-100 inches" |
| screen_resolution | Format: "WIDTHxHEIGHT" | "Invalid resolution format" |
| screen_resolution | Minimum 1920x1080 | "Resolution must be at least 1920x1080" |
| os_type | Valid enum value | "Unsupported OS type" |
| mac_address | Format: XX:XX:XX:XX:XX:XX | "Invalid MAC address format" |
| advertising_slots_per_hour | Range 6-60 | "Slots per hour must be 6-60" |
| max_content_duration | Range 10-300 | "Max duration must be 10-300 seconds" |
| timezone | Valid IANA timezone | "Invalid timezone" |
| operating_hours | Valid time ranges | "Invalid operating hours format" |

---

## Calculations & Formulas

### Formula Summary

#### 1. Uptime Percentage
```
uptime_percentage = (
  total_uptime_minutes /
  (total_uptime_minutes + total_downtime_minutes)
) × 100

Example:
  Uptime: 28,500 minutes
  Downtime: 500 minutes
  Total: 29,000 minutes
  Uptime %: (28,500 / 29,000) × 100 = 98.28%
```

#### 2. Health Score
```
health_score = (
  uptime_score × 0.40 +
  performance_score × 0.30 +
  reliability_score × 0.20 +
  compliance_score × 0.10
)

Range: 0-100 (higher is better)
Target: ≥ 80
Excellent: ≥ 90
```

#### 3. Advertising Capacity per Day
```
capacity_per_day = (
  advertising_slots_per_hour ×
  operating_hours_per_day
)

Example:
  12 slots/hour × 14 hours/day = 168 impressions/day capacity
```

#### 4. Expected Impressions per Month
```
expected_impressions_per_month = (
  advertising_slots_per_hour ×
  average_operating_hours_per_day ×
  30 days ×
  expected_fill_rate
)

expected_fill_rate = 0.70 (70% of slots filled, conservative)

Example:
  12 slots/hour × 14 hours × 30 days × 0.70 = 3,528 impressions/month
```

#### 5. Downtime Impact on Revenue
```
lost_revenue = (
  downtime_minutes / 60 ×
  average_slots_per_hour ×
  average_cpm / 1000 ×
  supplier_share_percentage
)

Example:
  Downtime: 120 minutes (2 hours)
  Slots: 12/hour
  Average CPM: $30
  Supplier share: 80%

  Lost revenue: (120/60) × 12 × (30/1000) × 0.80 = $5.76
```

#### 6. Device ROI for Supplier
```
device_roi = (
  (total_revenue_generated - device_cost - maintenance_cost) /
  device_cost
) × 100

Example:
  Revenue: $10,000 (lifetime)
  Device cost: $2,000
  Maintenance: $500

  ROI: ((10,000 - 2,000 - 500) / 2,000) × 100 = 375%
```

---

## Appendix: Device Status State Machine

```
State Transitions:

REGISTERED
  ├→ [first heartbeat] → ACTIVE
  └→ [90 days no activation] → DECOMMISSIONED

ACTIVE
  ├→ [missed heartbeats] → OFFLINE
  ├→ [manual pause] → MAINTENANCE
  └→ [decommission] → DECOMMISSIONED

OFFLINE
  ├→ [heartbeat received] → ACTIVE
  ├→ [manual maintenance] → MAINTENANCE
  └→ [decommission] → DECOMMISSIONED

MAINTENANCE
  ├→ [maintenance complete] → ACTIVE
  └→ [decommission] → DECOMMISSIONED

DECOMMISSIONED
  └→ [terminal state - no transitions]
```

---

## Appendix: Glossary

**Device**: Physical digital signage display that shows advertising content
**Heartbeat**: Periodic health check signal sent by device to server
**Sync**: Process of updating content on device from server
**Playlist**: Queue of content scheduled to play on device
**Slot**: Time window allocated for one ad (e.g., 5 minutes)
**Uptime**: Time period when device is online and operational
**Downtime**: Time period when device is offline or non-operational
**Health Score**: Computed metric (0-100) indicating device performance
**Fallback Content**: Default content shown when no campaigns available
**Proof-of-Play**: Evidence that content was actually displayed (screenshot, signature)

---

**Document Status**: Ready for review
**Next Steps**:
1. Review with stakeholders
2. Technical review (device team, backend team)
3. QA test case creation
4. Implementation planning

---

**Related Documents**:
- `business-rules-campaign.md` - Campaign lifecycle and impression recording
- `business-rules-supplier.md` - Supplier management and store registration
- `business-rules-content.md` - Content upload and approval workflow
