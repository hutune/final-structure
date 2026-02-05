---
id: "STORY-4.3"
epic_id: "EPIC-004"
title: "Proof-of-Play Generation"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "device", "proof-of-play", "aggregation"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmdf"
---

# Proof-of-Play Generation

## User Story

**As an** Advertiser,
**I want** verifiable proof that my ads were actually played,
**So that** I have evidence for billing and can resolve any disputes.

## Business Context

Proof-of-play builds advertiser trust:
- Provides auditable evidence of ad delivery
- Contains immutable records for dispute resolution
- Includes geographic and temporal breakdown
- Required for premium advertisers and agency contracts

## Business Rules

> Reference: [06-business-rules-impression.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/06-business-rules-impression.md)

### Proof Components
| Component | Description | Source |
|-----------|-------------|--------|
| Screenshot | Frame capture during playback | Device |
| Signature | RSA-signed playback hash | Device |
| Timestamp | Server-verified time | System |
| Location | GPS coordinates | Device |
| Duration | Actual vs expected | Device |

### Screenshot Requirements
- Captured at random point during playback
- Stored as compressed JPEG (quality 75)
- SHA-256 hash included in proof
- Retained for 90 days

### Aggregation Schedule
- **Daily:** Midnight UTC aggregation job
- **Real-time:** Available for current day
- **Immutable:** Once generated, cannot be modified

### Dispute Resolution
| Dispute Type | Evidence Required |
|--------------|-------------------|
| Missing impression | Screenshot + log |
| Wrong duration | Playback log + device log |
| Wrong location | GPS + store geofence |
| Fraudulent | Full audit trail |

## Acceptance Criteria

### For Advertisers
- [ ] View daily proof-of-play reports
- [ ] See hourly breakdown of impressions
- [ ] Geographic distribution by region/store
- [ ] Download proof document (PDF)
- [ ] Access screenshots on demand

### For Reporting
- [ ] Total impressions per day
- [ ] Unique devices and stores
- [ ] Total playback duration
- [ ] Hourly and geographic breakdown

### For Disputes
- [ ] Records are immutable after generation
- [ ] Full audit trail for each impression
- [ ] Screenshots available for 90 days

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET /api/v1/campaigns/{id}/proof-of-play?date=2026-02-05
GET /api/v1/campaigns/{id}/proof-of-play?from=...&to=...
GET /api/v1/impressions/{id}/screenshot
GET /api/v1/campaigns/{id}/proof-of-play/download  # PDF
```

**Response:**
```json
{
  "campaign_id": "uuid",
  "date": "2026-02-05",
  "total_impressions": 15000,
  "unique_devices": 45,
  "unique_stores": 12,
  "total_duration_seconds": 225000,
  "hourly_breakdown": {"09": 890, "10": 1200, ...},
  "geographic_breakdown": {
    "regions": {"Ho Chi Minh": 8000, "Ha Noi": 5000},
    "stores": [{"store_id": "uuid", "name": "...", "impressions": 2000}]
  }
}
```

</details>

## Checklist (Subtasks)

- [ ] Create proof_of_play table (immutable)
- [ ] Implement daily aggregation job
- [ ] Aggregate by hour, region, store
- [ ] Implement proof-of-play API
- [ ] Screenshot storage (S3 + 90-day retention)
- [ ] PDF export generation
- [ ] Unit tests for aggregation
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:17** - Rewrote with proof components, screenshot requirements, and dispute resolution from impression business rules.
