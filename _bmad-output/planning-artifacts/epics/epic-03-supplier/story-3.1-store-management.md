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
clickup_task_id: null
---

# Store Registration & Management

## User Story

**As a** Supplier,
**I want** đăng ký và quản lý cửa hàng của tôi,
**So that** tôi có thể cho thuê màn hình quảng cáo.

## Acceptance Criteria

- [ ] POST `/api/v1/stores` tạo store với status "pending_verification"
- [ ] PUT `/api/v1/stores/{id}` cập nhật store info
- [ ] GET `/api/v1/stores` trả về danh sách stores của supplier
- [ ] GET `/api/v1/stores/{id}` trả về store details
- [ ] Store có operating_hours configuration
- [ ] Admin có thể verify store

## Technical Notes

**API Endpoints:**
```
POST   /api/v1/stores
GET    /api/v1/stores
GET    /api/v1/stores/{id}
PUT    /api/v1/stores/{id}
DELETE /api/v1/stores/{id}
POST   /api/v1/admin/stores/{id}/verify
```

**Database Table:**
```sql
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    region VARCHAR(100),
    city VARCHAR(100),
    store_type VARCHAR(50), -- flagship, mall, supermarket, convenience
    operating_hours JSONB,
    status VARCHAR(50) DEFAULT 'pending_verification',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_stores_supplier ON stores(supplier_id);
CREATE INDEX idx_stores_region ON stores(region);
CREATE INDEX idx_stores_type ON stores(store_type);
```

**Operating Hours Format:**
```json
{
    "monday": {"open": "09:00", "close": "21:00"},
    "tuesday": {"open": "09:00", "close": "21:00"},
    "saturday": {"open": "10:00", "close": "22:00"},
    "sunday": {"open": "10:00", "close": "18:00"}
}
```

**Store Status:** pending_verification, active, inactive, suspended

## Checklist (Subtasks)

- [ ] Tạo stores table migration
- [ ] Implement Create Store endpoint
- [ ] Implement List Stores endpoint
- [ ] Implement Get Store endpoint
- [ ] Implement Update Store endpoint
- [ ] Implement Delete Store endpoint
- [ ] Implement Admin Verify Store endpoint
- [ ] Validate operating_hours format
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
