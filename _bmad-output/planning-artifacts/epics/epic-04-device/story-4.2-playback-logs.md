---
id: "STORY-4.2"
epic_id: "EPIC-004"
title: "Playback Log Ingestion"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "device", "playback", "logs", "kafka"]
story_points: 8
sprint: null
start_date: null
due_date: null
time_estimate: "3d"
clickup_task_id: null
---

# Playback Log Ingestion

## User Story

**As a** Device,
**I want** gửi playback logs khi phát quảng cáo,
**So that** hệ thống có thể tính billing chính xác.

## Acceptance Criteria

- [ ] POST `/api/v1/playback-logs` nhận single playback log
- [ ] POST `/api/v1/playback-logs/batch` nhận batch of logs
- [ ] Logs được lưu vào NoSQL (MongoDB/ClickHouse)
- [ ] Kafka event `playback.logged` được publish
- [ ] Endpoint handle > 10,000 requests/second
- [ ] Response time < 50ms

## Technical Notes

**API Endpoints:**
```
POST /api/v1/playback-logs
POST /api/v1/playback-logs/batch
```

**Single Log Payload:**
```json
{
    "device_id": "uuid",
    "campaign_id": "uuid",
    "content_id": "uuid",
    "started_at": "2026-02-02T10:30:00Z",
    "ended_at": "2026-02-02T10:30:15Z",
    "duration_seconds": 15,
    "status": "completed",
    "metadata": {
        "playlist_position": 3,
        "screen_resolution": "1920x1080"
    }
}
```

**Batch Payload:**
```json
{
    "logs": [
        { /* log 1 */ },
        { /* log 2 */ },
        { /* log 3 */ }
    ]
}
```

**Batch Response:**
```json
{
    "processed": 100,
    "failed": 2,
    "errors": [
        {"index": 45, "error": "invalid campaign_id"}
    ]
}
```

**NoSQL Schema (MongoDB):**
```json
{
    "_id": "ObjectId",
    "device_id": "uuid",
    "campaign_id": "uuid",
    "content_id": "uuid",
    "started_at": "ISODate",
    "ended_at": "ISODate",
    "duration_seconds": 15,
    "status": "completed",
    "store_id": "uuid",
    "supplier_id": "uuid",
    "created_at": "ISODate"
}
```

**Kafka Topic:** `playback-logs`

**Performance Optimizations:**
- Async write to NoSQL
- Batch Kafka publishing
- Connection pooling
- Consider message queue buffer

## Checklist (Subtasks)

- [ ] Setup MongoDB/ClickHouse connection
- [ ] Implement single log endpoint
- [ ] Implement batch log endpoint
- [ ] Setup Kafka producer
- [ ] Publish events to Kafka
- [ ] Add store_id, supplier_id enrichment
- [ ] Implement validation
- [ ] Load testing (target: 10k/s)
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
