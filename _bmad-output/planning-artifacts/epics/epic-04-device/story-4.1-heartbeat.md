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

**As a** Device,
**I want** gửi heartbeat định kỳ để báo trạng thái,
**So that** hệ thống biết tôi đang online và hoạt động.

## Acceptance Criteria

- [ ] POST `/api/v1/devices/{id}/heartbeat` cập nhật last_heartbeat
- [ ] Device status chuyển sang "online" khi nhận heartbeat
- [ ] Device status chuyển sang "offline" nếu không có heartbeat > 10 phút
- [ ] Health check job chạy mỗi phút để detect offline devices
- [ ] Alert event được publish khi device goes offline

## Technical Notes

**API Endpoint:**
```
POST /api/v1/devices/{id}/heartbeat
```

**Heartbeat Payload:**
```json
{
    "device_id": "uuid",
    "timestamp": "2026-02-02T10:30:00Z",
    "current_playlist": "playlist-uuid",
    "storage_status": {
        "total_gb": 64,
        "used_gb": 32
    },
    "network_status": "connected",
    "player_version": "1.2.3"
}
```

**Heartbeat Response:**
```json
{
    "status": "ok",
    "server_time": "2026-02-02T10:30:01Z",
    "playlist_updated": false,
    "commands": []
}
```

**Offline Detection Job:**
```go
func (s *DeviceService) CheckOfflineDevices() {
    threshold := time.Now().Add(-10 * time.Minute)
    devices := s.repo.FindOnlineDevicesWithHeartbeatBefore(threshold)
    for _, d := range devices {
        d.Status = "offline"
        s.repo.Update(d)
        s.eventPublisher.Publish("device.offline", d)
    }
}
```

**Kafka Events:**
- `device.online` - When device comes online
- `device.offline` - When device goes offline

## Checklist (Subtasks)

- [ ] Implement heartbeat endpoint
- [ ] Update last_heartbeat và status
- [ ] Store heartbeat history in NoSQL
- [ ] Implement offline detection cron job
- [ ] Publish Kafka events
- [ ] Alert integration (optional)
- [ ] Unit tests
- [ ] Load test heartbeat endpoint

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
