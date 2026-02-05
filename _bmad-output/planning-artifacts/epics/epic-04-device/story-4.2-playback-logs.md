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
clickup_task_id: "86ewgdmcp"
---

# Playback Log Ingestion

## User Story

**As an** Advertiser,
**I want** accurate playback data from devices,
**So that** I can trust that I'm only billed for actual ad plays.

## Business Context

Playback logs are the source of truth for billing. Every ad impression must:
- Be recorded accurately at the device
- Be transmitted securely to the server
- Be verified before billing
- Include proof-of-play metadata

## Business Rules

> Reference: [06-business-rules-impression.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/06-business-rules-impression.md)

### Playback Requirements
| Field | Requirement | Purpose |
|-------|-------------|---------|
| Duration | ≥ 80% of content | Proof of completion |
| Timestamp | Within 10 min of server | Clock sync validation |
| Signature | RSA-signed | Authenticity |
| GPS (if available) | Within 5km of store | Location verification |

### Playback Status
| Status | Description | Billable |
|--------|-------------|----------|
| COMPLETED | Played ≥ 80% | Yes |
| PARTIAL | Played < 80% | No |
| SKIPPED | User skipped | No |
| ERROR | Playback failed | No |

### Batch Processing
- Devices can batch up to 100 logs per request
- Logs queued during offline, sent when online
- Logs older than 24 hours rejected

## Acceptance Criteria

### For Ingestion
- [ ] Accept single and batch playback logs
- [ ] Validate all required fields
- [ ] Verify RSA signature on each log
- [ ] Reject logs older than 24 hours
- [ ] Enrich with store_id, supplier_id

### For Performance
- [ ] Handle 10,000+ logs per second
- [ ] Response time < 50ms (single), < 200ms (batch)
- [ ] Async write to storage
- [ ] Kafka publishing for billing pipeline

### For Reliability
- [ ] No data loss on system failure (durable queue)
- [ ] Idempotent processing (dedup by log ID)
- [ ] Batch response shows success/failure per log

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
POST /api/v1/playback-logs         # Single log
POST /api/v1/playback-logs/batch   # Up to 100 logs
```

**Log Payload:**
```json
{
  "log_id": "uuid",
  "device_id": "uuid",
  "campaign_id": "uuid",
  "content_id": "uuid",
  "started_at": "2026-02-05T10:00:00Z",
  "ended_at": "2026-02-05T10:00:15Z",
  "duration_actual": 15,
  "duration_expected": 15,
  "status": "COMPLETED",
  "location": {"lat": 10.76, "lng": 106.66},
  "screenshot_hash": "sha256...",
  "signature": "device-rsa-signature"
}
```

**Kafka Topic:** `playback-logs`
**Storage:** ClickHouse (analytics), MongoDB (raw logs)

</details>

## Checklist (Subtasks)

- [ ] Implement single log endpoint
- [ ] Implement batch endpoint with partial failure handling
- [ ] RSA signature verification
- [ ] Timestamp validation (24h window)
- [ ] Store enrichment (add store_id, supplier_id)
- [ ] Kafka publishing to `playback-logs`
- [ ] Deduplication by log_id
- [ ] Load test (target: 10k/sec)
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:15** - Rewrote with playback requirements, status types, and batch processing from impression business rules.
