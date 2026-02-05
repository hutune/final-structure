---
id: "STORY-8.3"
epic_id: "EPIC-008"
title: "Dispute Resolution"
status: "to-do"
priority: "medium"
assigned_to: null
tags: ["backend", "admin", "dispute", "resolution"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm8n"
---

# Dispute Resolution

## User Story

**As a** Platform Admin,
**I want** to fairly resolve disputes between advertisers and suppliers,
**So that** trust is maintained and issues are resolved transparently.

## Business Context

Dispute resolution is critical for platform trust:
- Advertisers may question impression counts
- Suppliers may dispute revenue calculations
- Transparent process with evidence review
- Fair outcomes build long-term relationships

## Business Rules

### Dispute Types
| Type | Description | Evidence Required |
|------|-------------|-------------------|
| Billing | Incorrect charges | Proof-of-play logs |
| Playback | Ads not shown correctly | Device logs, screenshots |
| Content | Content approval issues | Moderation history |
| Revenue | Incorrect supplier payment | Billing records |

### Dispute Status Flow
```
OPEN → UNDER_REVIEW → INVESTIGATING → RESOLVED
                                    → REJECTED
```

### Resolution Options
| Resolution | Action |
|------------|--------|
| Refund | Credit back to advertiser wallet |
| Adjustment | Correct supplier earnings |
| No action | Dispute not valid |
| Credit | Goodwill credit for future use |

### SLA Targets
| Priority | Response | Resolution |
|----------|----------|------------|
| High (> $1000) | 4h | 48h |
| Medium ($100-1000) | 24h | 5 days |
| Low (< $100) | 48h | 10 days |

## Acceptance Criteria

### For Dispute Creation
- [ ] Users can submit dispute with type and details
- [ ] Attach evidence (screenshots, URLs)
- [ ] Link to specific campaign
- [ ] Receive confirmation with ticket number

### For Admin Review
- [ ] View dispute queue by status/priority
- [ ] See full context (campaign, proof-of-play)
- [ ] Access all related logs and evidence
- [ ] Communication thread with user

### For Resolution
- [ ] Resolve with action (refund/adjustment/none)
- [ ] Reason required for all resolutions
- [ ] Automatic refund processing
- [ ] Both parties notified of outcome

### For Transparency
- [ ] Users can view their dispute history
- [ ] See resolution reason
- [ ] Appeal option (once per dispute)

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
# User endpoints
POST /api/v1/disputes                   # Create dispute
GET  /api/v1/disputes                   # My disputes
GET  /api/v1/disputes/{id}              # Dispute details
POST /api/v1/disputes/{id}/message      # Add message

# Admin endpoints
GET  /api/v1/admin/disputes?status=...  # Dispute queue
GET  /api/v1/admin/disputes/{id}        # Full details + logs
POST /api/v1/admin/disputes/{id}/resolve
POST /api/v1/admin/disputes/{id}/escalate
```

**Resolution with Refund:**
```go
func (s *DisputeService) Resolve(disputeID string, resolution Resolution) error {
    dispute := s.repo.Get(disputeID)
    
    // Apply financial action
    if resolution.Action == "refund" && resolution.Amount > 0 {
        s.walletService.Credit(
            dispute.ReporterID,
            resolution.Amount,
            fmt.Sprintf("Dispute refund #%s", disputeID),
        )
    }
    
    // Update dispute
    dispute.Status = "resolved"
    dispute.Resolution = resolution.Reason
    dispute.ResolvedBy = adminID
    dispute.ResolvedAt = time.Now()
    
    // Notify both parties
    s.notify(dispute.ReporterID, "dispute_resolved", resolution)
    
    return nil
}
```

</details>

## Checklist (Subtasks)

- [ ] Create disputes table migration
- [ ] Implement user dispute submission
- [ ] Implement admin dispute queue
- [ ] Integrate proof-of-play data
- [ ] Implement resolution with actions
- [ ] Process refunds automatically
- [ ] Implement appeal workflow
- [ ] Email notifications
- [ ] Audit logging
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:26** - Rewrote with dispute types, resolution options, and SLA targets.
