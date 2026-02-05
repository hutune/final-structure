---
id: "STORY-4.1"
epic_id: "EPIC-004"
title: "Device Heartbeat System"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "device", "heartbeat", "monitoring"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmd7"
---

# Device Heartbeat System

## User Story

**As a** Supplier,
**I want** to know when my devices are online and functioning properly,
**So that** I can ensure continuous ad delivery and maximize my revenue.

## Business Context

Device health directly impacts supplier revenue. The heartbeat system:
- Tracks device status in real-time
- Alerts suppliers when devices go offline
- Ensures no billing for offline periods
- Provides health metrics for quality score

## Business Rules

> Reference: [05-business-rules-device.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/05-business-rules-device.md)

### Heartbeat Schedule
- **Interval:** Every 5 minutes (300 seconds)
- **Offline threshold:** No heartbeat for 10 minutes (2 missed)
- **Signature:** RSA-signed with device private key

### Device Status Transitions
| Trigger | From | To |
|---------|------|-----|
| Heartbeat received | REGISTERED | ACTIVE |
| Heartbeat received | OFFLINE | ACTIVE |
| 10 min no heartbeat | ACTIVE | OFFLINE |
| Maintenance set | ACTIVE | MAINTENANCE |
| Manual decommission | Any | DECOMMISSIONED |

### Alert Thresholds
| Offline Duration | Alert Level |
|------------------|-------------|
| 15 minutes | Warning (email) |
| 60 minutes | Urgent (email + SMS) |
| 4 hours | Critical (call/escalate) |

### Heartbeat Payload Validation
- `device_timestamp` must be within 5 min of server time
- `signature` verified with stored public key
- All metric values validated (0-100 for percentages)

## Acceptance Criteria

### For Suppliers
- [ ] Dashboard shows real-time device status (green/yellow/red)
- [ ] See last heartbeat time for each device
- [ ] Receive alert when device offline > 15 minutes
- [ ] View device health metrics (CPU, memory, network)

### For System
- [ ] Heartbeat endpoint responds in < 50ms
- [ ] Status change triggers Kafka event
- [ ] Offline detection job runs every minute
- [ ] Health score updated on each heartbeat

### For Security
- [ ] All heartbeats cryptographically signed
- [ ] Invalid signatures rejected and flagged
- [ ] Clock skew > 5 min triggers warning

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoint:**
```
POST /api/v1/devices/{id}/heartbeat
Headers:
  X-Device-Signature: {SHA256-RSA signature}
```

**Request:**
```json
{
  "device_timestamp": "2026-02-05T10:00:00+07:00",
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
    "current_playlist_id": "uuid"
  }
}
```

**Response:**
```json
{
  "status": "OK",
  "server_time": "2026-02-05T10:00:01Z",
  "config_updated": false,
  "playlist_updated": true,
  "actions": [
    {"type": "sync_content", "playlist_id": "uuid"}
  ]
}
```

</details>

## Checklist (Subtasks)

- [ ] Implement heartbeat endpoint with signature verification
- [ ] Store heartbeats in time-series DB (InfluxDB/TimescaleDB)
- [ ] Implement offline detection cron job (1 min interval)
- [ ] Update health score on each heartbeat
- [ ] Publish Kafka events (online/offline)
- [ ] Implement alert notifications
- [ ] Load test (target: 10k heartbeats/sec)
- [ ] Unit tests for signature verification
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:15** - Rewrote with heartbeat intervals, offline thresholds, signature verification from device business rules.
