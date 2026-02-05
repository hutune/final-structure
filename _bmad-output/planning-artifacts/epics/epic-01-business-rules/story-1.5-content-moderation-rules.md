---
id: "STORY-1.5"
epic_id: "EPIC-001"
title: "Content & Moderation Rules"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["business-rules", "content", "moderation", "approval"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# Content & Moderation Rules

## Purpose

Define all rules governing content upload, moderation, and approval.

## Business Rules Overview

> Reference: [10-business-rules-content.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/10-business-rules-content.md)

### Content Lifecycle
```
UPLOADED → PROCESSING → PENDING_APPROVAL → APPROVED → ACTIVE
                               ↓
                           REJECTED
```

### Supported Formats
| Type | Formats | Max Size |
|------|---------|----------|
| Image | JPG, PNG, GIF, WebP | 10 MB |
| Video | MP4 (H.264) | 500 MB |
| Audio | MP3, AAC | 50 MB |

### Resolution Requirements
| Format | Minimum Resolution |
|--------|-------------------|
| Standard | 1920 × 1080 |
| Portrait | 1080 × 1920 |
| Square | 1080 × 1080 |

### AI Moderation Scoring
| Score Range | Action | SLA |
|-------------|--------|-----|
| 90-100 | Auto-APPROVE | Instant |
| 70-89 | FLAGGED → Manual | 24 hours |
| < 70 | Auto-REJECT | Instant |

### Prohibited Content
- Adult/sexual content
- Violence or gore
- Hate speech, discrimination
- Illegal products/services
- Copyright infringement
- Misleading claims

### Restricted Content (Requires Approval)
| Category | Requirements |
|----------|--------------|
| Alcohol | Advertiser license, age-gating |
| Gambling | Gambling license, age-gating |
| Pharmaceutical | FDA approval docs |
| Political | Special approval process |

### Appeal Process
- 1 appeal per asset allowed
- Senior reviewer decision
- SLA: 48 hours
- Final decision binding

### Content Distribution
| Stage | Timing |
|-------|--------|
| Pre-distribution | 24h before campaign start |
| Device caching | Until campaign ends |
| CDN TTL | 24 hours |
| Signed URLs | 72 hours expiry |

## Acceptance Criteria

- [ ] All content scanned by AI before use
- [ ] Prohibited content blocked
- [ ] Restricted content properly gated
- [ ] Appeal process documented

## Checklist (Subtasks)

- [ ] Document upload requirements
- [ ] Document moderation thresholds
- [ ] Document prohibited/restricted lists
- [ ] Document appeal workflow
- [ ] Review with legal/brand safety

## Updates

**2026-02-05 09:37** - Created as business rules story for content and moderation domain.
