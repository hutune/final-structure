# Business Rules: Admin & Platform Operations

**Version**: 1.0  
**Date**: 2026-02-05  
**Status**: Draft  
**Owner**: Product Team  

---

## 1. Overview

### 1.1 Purpose
This document defines the business rules for platform administration and operations. It covers admin roles, user management, content moderation workflows, platform configuration, and audit requirements.

### 1.2 Scope
- Admin user roles and permissions
- Content moderation workflows
- User account management (admin actions)
- Platform configuration
- Audit trail requirements

### 1.3 Out of Scope
- Technical implementation
- API specifications
- Database design

---

## 2. Admin Roles

### 2.1 Role Hierarchy

| Role | Description | Access Level |
|------|-------------|--------------|
| **Super Admin** | Full platform access, can manage other admins | Full |
| **Finance Admin** | Financial operations, payouts, refunds | Finance only |
| **Content Moderator** | Review and approve/reject content | Content only |
| **Support Agent** | Handle user issues, view accounts | Read + limited write |
| **Viewer** | Read-only access for reporting | Read only |

### 2.2 Permission Matrix

| Permission | Super Admin | Finance Admin | Content Mod | Support Agent | Viewer |
|------------|-------------|---------------|-------------|---------------|--------|
| Manage admins | ✅ | ❌ | ❌ | ❌ | ❌ |
| View all users | ✅ | ✅ | ❌ | ✅ | ✅ |
| Suspend users | ✅ | ❌ | ❌ | ✅ | ❌ |
| Process refunds | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve payouts | ✅ | ✅ | ❌ | ❌ | ❌ |
| Moderate content | ✅ | ❌ | ✅ | ❌ | ❌ |
| View financials | ✅ | ✅ | ❌ | ❌ | ✅ |
| Platform config | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## 3. User Management Rules

### Rule 1: Account Suspension

**Admins can suspend user accounts under these conditions:**

| Reason | Authority Required | Duration |
|--------|-------------------|----------|
| Policy violation | Support Agent+ | Up to 7 days |
| Fraud suspected | Finance Admin+ | Pending investigation |
| Legal request | Super Admin | As required |
| Repeated violations | Super Admin | Permanent |

**Suspension process:**
1. Admin documents reason
2. User notified with reason
3. Active campaigns paused
4. Payouts held
5. Appeal option provided (within 14 days)

---

### Rule 2: Account Ban (Permanent)

**Only Super Admin can permanently ban accounts.**

**Ban criteria:**
- Confirmed fraud
- Repeated policy violations (3+ suspensions)
- Legal requirement
- Security threat

**Ban effects:**
- All campaigns terminated
- Content deleted after 30 days
- Pending payouts processed (if legitimate)
- User cannot create new account

---

### Rule 3: Account Reinstatement

**Suspended accounts can be reinstated:**
- By the suspending admin or higher
- After appeal review
- After issue resolution

**Banned accounts reinstatement:**
- Only by Super Admin
- Requires documented justification
- Rare exception cases only

---

## 4. Content Moderation Rules

### Rule 4: Moderation Queue

**Content enters moderation queue when:**
- AI moderation score between 70-89
- User-flagged content
- Category requires manual review (alcohol, gambling)
- First-time advertiser upload

**Queue priority:**
1. Enterprise customer content
2. Campaign starting within 24 hours
3. Appeal reviews
4. Standard queue (FIFO)

---

### Rule 5: Moderation Decisions

**Moderator options:**

| Decision | Effect | User Notification |
|----------|--------|-------------------|
| **Approve** | Content ready for campaigns | "Your content has been approved" |
| **Reject** | Cannot be used | Reason provided, resubmit allowed |
| **Request Changes** | Minor edits needed | Specific feedback provided |
| **Escalate** | Needs senior review | Processing notification |

**Rejection requires:**
- Specific policy cited
- Clear explanation
- Suggestion for fix (when possible)

---

### Rule 6: Moderation SLA

| Customer Tier | Standard Queue | Priority Queue |
|---------------|----------------|----------------|
| FREE | 48 hours | N/A |
| BASIC | 24 hours | N/A |
| PREMIUM | 24 hours | 8 hours |
| ENTERPRISE | 8 hours | 4 hours |

---

## 5. Financial Operations Rules

### Rule 7: Refund Authority

| Refund Amount | Authority Required |
|---------------|-------------------|
| ≤ $100 | Support Agent |
| $101 - $500 | Finance Admin |
| $501 - $5,000 | Finance Admin + approval |
| > $5,000 | Super Admin |

**Refund conditions:**
- Service not delivered
- Technical failure
- Billing error
- Customer request within 7 days

---

### Rule 8: Payout Approval

**Manual payout approval required when:**
- First payout from new supplier
- Amount > $10,000
- Account flagged for review
- Bank account recently changed

**Approval workflow:**
1. System flags payout
2. Finance Admin reviews
3. Documents verified
4. Approval or rejection
5. Supplier notified

---

### Rule 9: Write-off Authority

| Write-off Amount | Authority |
|------------------|-----------|
| ≤ $500 | Finance Admin |
| $501 - $5,000 | Finance Admin + Super Admin |
| > $5,000 | Super Admin + CFO |

---

## 6. Platform Configuration

### Rule 10: Configuration Changes

**Configuration categories:**

| Category | Examples | Change Authority |
|----------|----------|------------------|
| **Feature Flags** | Enable/disable features | Super Admin |
| **Pricing** | CPM rates, fees | Super Admin + Finance |
| **Limits** | Rate limits, quotas | Super Admin |
| **Content Policies** | Prohibited categories | Super Admin + Legal |

**All configuration changes:**
- Logged with who/when/what
- Require justification
- Can be rolled back
- Major changes require 24-hour notice

---

### Rule 11: Scheduled Maintenance

**Maintenance window rules:**
- Standard window: Tuesday 2-6 AM UTC
- 7-day advance notice required
- Maximum 2 hours for standard maintenance
- Extended maintenance: 14-day notice

**Emergency maintenance:**
- Security patches: ASAP
- Critical fixes: As needed
- Notification: Best effort

---

## 7. Audit Trail Requirements

### Rule 12: Auditable Actions

**All following actions MUST be logged:**

| Category | Actions Logged |
|----------|----------------|
| **User Management** | Login, logout, password change, suspension, ban |
| **Financial** | Transactions, refunds, payouts, write-offs |
| **Content** | Upload, moderation decisions, deletion |
| **Configuration** | All setting changes |
| **Admin Actions** | All admin operations |

---

### Rule 13: Audit Log Retention

| Log Type | Retention |
|----------|-----------|
| Financial logs | 7 years |
| User activity | 2 years |
| Admin actions | 5 years |
| Content moderation | 3 years |
| Security events | 3 years |

---

### Rule 14: Audit Access

**Audit logs accessible by:**
- Super Admin: Full access
- Finance Admin: Financial logs only
- External auditors: With Super Admin approval
- Legal/Compliance: As required

**Audit logs are:**
- Read-only (no modification)
- Tamper-evident
- Exportable for compliance

---

## 8. Admin Account Security

### Rule 15: Admin Authentication

- All admins require 2FA
- Session timeout: 30 minutes inactive
- IP allowlist optional (recommended)
- Login anomaly alerts

### Rule 16: Admin Onboarding/Offboarding

**Onboarding:**
- Background check (if applicable)
- Role assigned by Super Admin
- Training required before access
- Probation period: 30 days limited access

**Offboarding:**
- Access revoked immediately upon termination
- All sessions terminated
- Audit of recent actions
- Credentials rotated if necessary
