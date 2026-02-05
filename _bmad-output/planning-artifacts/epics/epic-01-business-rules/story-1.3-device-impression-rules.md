---
id: "STORY-1.3"
epic_id: "EPIC-001"
title: "Device & Impression Rules"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["business-rules", "device", "impression", "proof-of-play"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Device & Impression Rules

## Purpose

Define all rules governing device operation and impression verification.

## Business Rules Overview

> Reference: [05-business-rules-device.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/05-business-rules-device.md)
> Reference: [06-business-rules-impression.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/06-business-rules-impression.md)

### Device Lifecycle
```
PENDING → REGISTERED → ACTIVATED → ONLINE
                                     ↓
                                  OFFLINE
                                     ↓
                               MAINTENANCE
```

### Heartbeat Rules
| Parameter | Value |
|-----------|-------|
| Interval | Every 5 minutes |
| Offline threshold | 10 minutes no heartbeat |
| Signature | RSA-256 signed |
| Payload | Device ID, status, GPS, timestamp |

### Device Health Score
```
Health = (Uptime × 0.4) + (Playback × 0.3) + (Sync × 0.2) + (Network × 0.1)
```

### Impression Verification Pipeline
```
Raw Log → Deduplication → Signature Verify → Device Verify → Quality Score → Billing
```

### Impression Quality Scoring
| Factor | Weight | Criteria |
|--------|--------|----------|
| Duration | 30% | Played ≥ 95% of content length |
| Visibility | 25% | Screen on, not occluded |
| Location | 20% | Device at registered location |
| Time | 15% | During store operating hours |
| Signature | 10% | Valid RSA signature |

### Fraud Detection
| Pattern | Action |
|---------|--------|
| Duplicate impression | Reject, flag device |
| Invalid signature | Reject, alert |
| Wrong location | Suspend device, investigate |
| Abnormal volume | Hold revenue, review |

### Proof-of-Play Components
- Screenshot (1/minute during playback)
- Playback log with timestamps
- Device signature
- GPS coordinates
- Aggregated into daily reports

## Acceptance Criteria

- [ ] All impressions verified before billing
- [ ] Fraud patterns detected and handled
- [ ] Proof-of-play available for disputes
- [ ] Device health tracked accurately

## Checklist (Subtasks)

- [ ] Document heartbeat protocol
- [ ] Document verification pipeline
- [ ] Define fraud detection rules
- [ ] Define proof-of-play format
- [ ] Review with operations team

## Updates

**2026-02-05 09:37** - Created as business rules story for device and impression domain.
