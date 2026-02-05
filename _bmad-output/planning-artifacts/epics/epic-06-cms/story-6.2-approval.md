---
id: "STORY-6.2"
epic_id: "EPIC-006"
title: "Content Approval Workflow"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "cms", "approval", "admin"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm9x"
---

# Content Approval Workflow

## User Story

**As an** Advertiser,
**I want** to know if my content is approved quickly,
**So that** I can launch my campaign on time.

## Business Context

Content moderation protects brand safety for all parties:
- Prevents inappropriate content on devices
- Reduces legal risk for suppliers and platform
- Builds advertiser trust through fast approval
- Uses AI to automate most approvals

## Business Rules

> Reference: [10-business-rules-content.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/10-business-rules-content.md)

### Two-Tier Moderation
1. **AI Moderation (automatic):** All content scanned on upload
2. **Manual Review:** Flagged content reviewed by human

### AI Moderation Scoring
| Score Range | Action | SLA |
|-------------|--------|-----|
| 90-100 | Auto-APPROVE | Instant |
| 70-89 | FLAGGED → Manual review | 24h |
| < 70 | Auto-REJECT | Instant |

### Content Scan Categories
- Adult/sexual content
- Violence/gore
- Hate symbols/speech
- Copyright issues
- Weapons, drugs, alcohol

### Prohibited Content
Automatic rejection:
- Adult/sexual content
- Violence or graphic imagery
- Hate speech, discrimination
- Illegal products or services

### Appeal Process
- 1 appeal allowed per asset
- Senior reviewer decision is final
- Appeal SLA: 48 hours

## Acceptance Criteria

### For Advertisers
- [ ] See content status (pending/approved/rejected)
- [ ] Receive notification when approved/rejected
- [ ] View rejection reason with policy link
- [ ] Appeal rejected content (once)
- [ ] SLA: 90% approved within 24h

### For Admins
- [ ] View queue of flagged content
- [ ] One-click approve/reject
- [ ] Must provide reason for rejection
- [ ] View AI moderation score and flags

### For System
- [ ] Auto-approve score ≥ 90
- [ ] Auto-reject score < 70
- [ ] Flag for review score 70-89
- [ ] Audit log for all decisions

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET  /api/v1/admin/content/pending      # Review queue
POST /api/v1/admin/content/{id}/approve # Approve
POST /api/v1/admin/content/{id}/reject  # Reject (reason required)
POST /api/v1/content/{id}/appeal        # Advertiser appeal
```

**AI Integration:**
- AWS Rekognition or Google Cloud Vision
- Return moderation_score (0-100)
- Return moderation_flags array

</details>

## Checklist (Subtasks)

- [ ] Integrate AI moderation service
- [ ] Implement auto-approve/reject logic
- [ ] Create admin review queue
- [ ] Implement approve/reject endpoints
- [ ] Create audit log table
- [ ] Implement appeal workflow
- [ ] Send notifications on status change
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:20** - Rewrote with AI moderation scoring thresholds and appeal process from CMS business rules.
