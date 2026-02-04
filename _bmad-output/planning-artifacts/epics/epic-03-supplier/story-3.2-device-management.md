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
clickup_task_id: null
---

# Device Registration & Management

## User Story

**As a** Supplier,
**I want** đăng ký và quản lý thiết bị hiển thị,
**So that** thiết bị có thể nhận và phát quảng cáo.

## Acceptance Criteria

- [ ] POST `/api/v1/stores/{store_id}/devices` đăng ký device
- [ ] Device có thể đăng ký bằng device_id hoặc QR code
- [ ] PUT `/api/v1/devices/{id}` cập nhật device settings
- [ ] GET `/api/v1/devices/{id}` trả về device details với last_heartbeat
- [ ] GET `/api/v1/stores/{store_id}/devices` trả về danh sách devices
- [ ] Device status: pending, online, offline, maintenance, error

## Technical Notes

**API Endpoints:**
```
POST   /api/v1/stores/{store_id}/devices
GET    /api/v1/stores/{store_id}/devices
GET    /api/v1/devices/{id}
PUT    /api/v1/devices/{id}
DELETE /api/v1/devices/{id}
```

**Database Table:**
```sql
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL REFERENCES stores(id),
    device_code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255),
    description TEXT,
    operating_hours JSONB, -- override store hours if needed
    resolution VARCHAR(50), -- 1920x1080, 4K, etc.
    orientation VARCHAR(20), -- landscape, portrait
    status VARCHAR(50) DEFAULT 'pending',
    last_heartbeat TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_devices_store ON devices(store_id);
CREATE INDEX idx_devices_code ON devices(device_code);
CREATE INDEX idx_devices_status ON devices(status);
```

**Register Device Request:**
```json
{
    "device_code": "DVC-2026-001",
    "name": "Entrance Screen",
    "resolution": "1920x1080",
    "orientation": "landscape"
}
```

**Device Response:**
```json
{
    "id": "uuid",
    "device_code": "DVC-2026-001",
    "name": "Entrance Screen",
    "store": {
        "id": "uuid",
        "name": "Store Name"
    },
    "status": "online",
    "last_heartbeat": "2026-02-02T10:30:00Z",
    "resolution": "1920x1080"
}
```

## Checklist (Subtasks)

- [ ] Tạo devices table migration
- [ ] Implement Register Device endpoint
- [ ] Implement List Devices by Store
- [ ] Implement Get Device endpoint
- [ ] Implement Update Device endpoint
- [ ] Implement Delete Device endpoint
- [ ] QR code generation for device registration
- [ ] Validate device_code uniqueness
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
