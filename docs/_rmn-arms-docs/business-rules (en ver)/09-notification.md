# Business Rules: Notification & Alerts

## Document Information
| Field | Value |
|-------|-------|
| Domain | Notification & Alerts |
| Version | 1.0.0 |
| Last Updated | 2025-02-05 |
| Owner | Platform Team |
| Status | Draft |

---

## 1. Overview

### 1.1 Purpose
This document defines the business rules governing all notifications and alerts within the RMN platform. Notifications are critical for keeping users informed about account status, campaign performance, device health, financial transactions, and compliance requirements.

### 1.2 Scope
- In-app notifications (notification center)
- Email notifications
- SMS alerts (critical only)
- Push notifications (mobile app)
- Webhook notifications (API integrations)
- System alerts (admin dashboard)

### 1.3 Notification Priority Levels

| Priority | Description | Delivery Channels | Max Delay |
|----------|-------------|-------------------|-----------|
| CRITICAL | Requires immediate action, security/financial impact | SMS + Email + Push + In-App | < 1 minute |
| HIGH | Important but not time-critical | Email + Push + In-App | < 5 minutes |
| MEDIUM | Standard operational notifications | Email + In-App | < 15 minutes |
| LOW | Informational, no action required | In-App only | < 1 hour |

---

## 2. Notification Categories

### 2.1 Category Taxonomy

```
NOTIFICATIONS
├── ACCOUNT
│   ├── Security (login, password, 2FA)
│   ├── Verification (KYC, documents)
│   ├── Tier changes
│   └── Team management
├── FINANCIAL
│   ├── Balance alerts
│   ├── Top-up confirmations
│   ├── Withdrawal status
│   ├── Invoice generated
│   └── Payment failures
├── CAMPAIGN
│   ├── Status changes
│   ├── Budget alerts
│   ├── Performance updates
│   ├── Approval required
│   └── Completion summaries
├── DEVICE
│   ├── Health alerts
│   ├── Offline warnings
│   ├── Sync failures
│   └── Maintenance required
├── CONTENT
│   ├── Moderation status
│   ├── Approval/rejection
│   ├── Expiration warnings
│   └── License issues
├── COMPLIANCE
│   ├── Document expiration
│   ├── Policy violations
│   ├── Audit requirements
│   └── Regulatory updates
├── DISPUTE
│   ├── New dispute filed
│   ├── Status updates
│   ├── Resolution required
│   └── Appeal deadlines
└── SYSTEM
    ├── Scheduled maintenance
    ├── Feature announcements
    ├── API deprecation
    └── Platform updates
```

---

## 3. Account Notifications

### 3.1 Security Notifications

#### BR-NOTIF-001: New Login Alert
```
TRIGGER: Successful login from new device/location
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Device type and browser
  - IP address and approximate location
  - Timestamp
  - "Not you?" action link
RULES:
  - Send within 30 seconds of login
  - Include one-click "Secure Account" button
  - Do NOT reveal full IP to prevent enumeration
  - Mask to first two octets (e.g., "192.168.x.x")
```

#### BR-NOTIF-002: Suspicious Login Attempt
```
TRIGGER: Failed login attempt (3+ failures in 10 minutes)
PRIORITY: CRITICAL
CHANNELS: SMS + Email + Push + In-App
CONTENT:
  - Number of failed attempts
  - Time range
  - Approximate location
  - Account lock status
RULES:
  - Send immediately upon 3rd failure
  - Include password reset link
  - Include "This was me" confirmation option
  - If 10+ failures: auto-lock account, require email verification
```

#### BR-NOTIF-003: Password Changed
```
TRIGGER: Password successfully changed
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Timestamp of change
  - Device used for change
  - "Didn't make this change?" action
RULES:
  - Send within 1 minute
  - Include link to immediately lock account
  - Must be sent even if user initiated change
```

#### BR-NOTIF-004: Two-Factor Authentication Events
```
TRIGGER: 2FA enabled, disabled, or recovery codes used
PRIORITY: HIGH
CHANNELS: Email + In-App
CONTENT:
  - Action taken (enabled/disabled/codes used)
  - Timestamp
  - Device information
RULES:
  - 2FA disable requires 24-hour delay notification BEFORE taking effect
  - Recovery code usage triggers additional verification requirement
  - Notify on each recovery code used (with remaining count)
```

### 3.2 Verification Notifications

#### BR-NOTIF-005: KYC Submission Received
```
TRIGGER: User submits KYC documents
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Submission timestamp
  - Documents received
  - Expected review timeline (24-48 hours)
  - Tracking reference number
RULES:
  - Send within 5 minutes of submission
  - Include link to check status
```

#### BR-NOTIF-006: KYC Verification Result
```
TRIGGER: KYC review completed
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Verification result (APPROVED/REJECTED/NEEDS_MORE_INFO)
  - If rejected: specific reason(s)
  - If needs info: list of required documents
  - Next steps
RULES:
  - Send within 5 minutes of decision
  - APPROVED: include congratulations and unlocked features
  - REJECTED: include appeal process (30-day window)
  - NEEDS_MORE_INFO: include deadline (7 days)
```

#### BR-NOTIF-007: Document Expiration Warning
```
TRIGGER: KYC document approaching expiration
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 30 days before: First warning (MEDIUM priority)
  - 14 days before: Second warning (HIGH priority)
  - 7 days before: Final warning (HIGH priority)
  - Day of expiration: CRITICAL alert
  - 1 day after: Account restricted notification
CONTENT:
  - Document type expiring
  - Expiration date
  - Upload link
  - Impact if not renewed
RULES:
  - Do not send more than one reminder per day
  - Include direct upload link with pre-filled form
```

### 3.3 Account Tier Notifications

#### BR-NOTIF-008: Tier Upgrade Confirmation
```
TRIGGER: Account tier upgraded
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - New tier name
  - New limits and features unlocked
  - Billing changes (if any)
  - Effective date
RULES:
  - Send immediately upon upgrade
  - Include comparison of old vs new limits
  - If payment-based upgrade: include receipt
```

#### BR-NOTIF-009: Tier Downgrade Warning
```
TRIGGER: Scheduled tier downgrade (subscription expiry)
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 14 days before: First notice
  - 7 days before: Second notice
  - 3 days before: Final warning
  - Day of: Downgrade executed notification
CONTENT:
  - Current tier and new tier
  - Features being lost
  - Active campaigns that exceed new tier limits
  - Payment link to maintain tier
RULES:
  - Pause campaigns that exceed new tier limits
  - Do NOT auto-delete any data
  - Provide 30-day grace period to upgrade before data cleanup
```

### 3.4 Team Management Notifications

#### BR-NOTIF-010: Team Member Invitation
```
TRIGGER: User invited to join organization
PRIORITY: HIGH
CHANNELS: Email
CONTENT:
  - Organization name
  - Inviting user name
  - Assigned role
  - Invitation link (24-hour expiry)
  - Accept/Decline buttons
RULES:
  - Link expires after 24 hours
  - Maximum 3 resends per invitation
  - Include brief role description
```

#### BR-NOTIF-011: Team Role Changed
```
TRIGGER: User's role modified within organization
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Old role and new role
  - Changed permissions
  - Who made the change
  - Effective immediately
RULES:
  - Send to affected user
  - Send audit notification to org admins
  - If DOWNGRADE: include appeal process
```

#### BR-NOTIF-012: Team Member Removed
```
TRIGGER: User removed from organization
PRIORITY: HIGH
CHANNELS: Email + In-App
CONTENT:
  - Organization name
  - Removal reason (if provided)
  - Data access termination notice
  - Contact for disputes
RULES:
  - Send to removed user immediately
  - Send audit notification to org admins
  - Include data export option (7-day window)
```

---

## 4. Financial Notifications

### 4.1 Balance Alerts

#### BR-NOTIF-020: Low Balance Warning
```
TRIGGER: Available balance falls below threshold
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
THRESHOLDS (Advertiser):
  - WARNING: Balance < 3 days of avg daily spend
  - CRITICAL: Balance < 1 day of avg daily spend
  - EMERGENCY: Balance < $100 or 4 hours of spend
THRESHOLDS (Supplier):
  - WARNING: Pending payout > $1,000 (for tracking)
CONTENT:
  - Current balance
  - Daily average spend (last 7 days)
  - Estimated days remaining
  - Active campaign count
  - One-click top-up link
RULES:
  - Calculate avg daily spend from last 7 days
  - If no spending history: use campaign daily budget sum
  - Send maximum once per day per threshold level
  - Reset threshold when balance tops up above 7 days of spend
```

#### BR-NOTIF-021: Balance Depleted
```
TRIGGER: Available balance reaches $0
PRIORITY: CRITICAL
CHANNELS: SMS + Email + Push + In-App
CONTENT:
  - Balance now $0
  - Campaigns being paused
  - Immediate top-up link
  - Grace period details (if any)
RULES:
  - Send immediately
  - Pause all active campaigns within 15 minutes
  - 24-hour grace period for PREMIUM+ tiers
  - Include scheduled campaigns affected
```

#### BR-NOTIF-022: Budget Hold Alert
```
TRIGGER: Funds held for campaign exceeds threshold
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Total held amount
  - Breakdown by campaign
  - Available vs held balance
  - Expected release dates
RULES:
  - Send daily digest if held > 50% of total balance
  - Include timeline for hold release
```

### 4.2 Top-Up Notifications

#### BR-NOTIF-023: Top-Up Initiated
```
TRIGGER: Payment initiated for wallet top-up
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Amount
  - Payment method
  - Reference number
  - Expected processing time
RULES:
  - Send within 1 minute of initiation
  - Include cancel window (if applicable)
```

#### BR-NOTIF-024: Top-Up Successful
```
TRIGGER: Wallet credited with top-up amount
PRIORITY: MEDIUM
CHANNELS: Email + Push + In-App
CONTENT:
  - Amount credited
  - New balance
  - Transaction reference
  - Receipt download link
RULES:
  - Send within 1 minute of credit
  - Include PDF receipt attachment in email
```

#### BR-NOTIF-025: Top-Up Failed
```
TRIGGER: Payment processing failed
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Failure reason (user-friendly)
  - Original amount
  - Suggested resolution
  - Retry link
  - Alternative payment methods
FAILURE_REASONS:
  - INSUFFICIENT_FUNDS: "Your payment method has insufficient funds"
  - CARD_DECLINED: "Your card was declined by the issuing bank"
  - EXPIRED_CARD: "Your card has expired"
  - FRAUD_SUSPECTED: "Transaction flagged for security review"
  - PROCESSING_ERROR: "Temporary processing issue"
RULES:
  - Send immediately upon failure
  - Do NOT expose raw gateway error codes
  - Log detailed error for support reference
  - Include support ticket option for repeated failures
```

### 4.3 Withdrawal Notifications

#### BR-NOTIF-026: Withdrawal Requested
```
TRIGGER: Supplier requests payout
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Amount requested
  - Bank account (masked)
  - Expected processing time (3-5 business days)
  - Reference number
RULES:
  - Send within 5 minutes
  - Include cancellation window (2 hours)
```

#### BR-NOTIF-027: Withdrawal Processing
```
TRIGGER: Withdrawal sent to bank
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Amount
  - Bank reference
  - Expected arrival date
  - Bank processing notice
RULES:
  - Send when bank ACH/wire initiated
  - Include bank's estimated arrival
```

#### BR-NOTIF-028: Withdrawal Completed
```
TRIGGER: Withdrawal confirmed by bank
PRIORITY: MEDIUM
CHANNELS: Email + Push + In-App
CONTENT:
  - Amount received
  - Bank account (masked)
  - Transaction reference
  - New wallet balance
RULES:
  - Send upon bank confirmation
  - May take 24-48 hours for confirmation
```

#### BR-NOTIF-029: Withdrawal Failed/Returned
```
TRIGGER: Bank returns or rejects withdrawal
PRIORITY: CRITICAL
CHANNELS: SMS + Email + Push + In-App
CONTENT:
  - Amount returned to wallet
  - Failure reason
  - Bank account status
  - Required action
FAILURE_REASONS:
  - ACCOUNT_CLOSED: "The bank account appears to be closed"
  - INVALID_ACCOUNT: "Account number does not match records"
  - NAME_MISMATCH: "Account holder name does not match"
  - BANK_REJECTED: "Receiving bank rejected the transfer"
RULES:
  - Credit amount back to wallet immediately
  - Require bank account re-verification
  - Flag account for manual review after 2 failures
```

### 4.4 Invoice & Statement Notifications

#### BR-NOTIF-030: Invoice Generated
```
TRIGGER: Monthly invoice generated
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Invoice number
  - Billing period
  - Total amount
  - Payment due date
  - PDF attachment
RULES:
  - Generate on 1st of month for previous month
  - Include itemized spending by campaign
  - Auto-pay reminder if enabled
```

#### BR-NOTIF-031: Payment Due Reminder
```
TRIGGER: Invoice payment approaching due date
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 7 days before: First reminder
  - 3 days before: Second reminder
  - 1 day before: Final reminder
  - Day of: Due today notice
  - 1 day after: Overdue notice (CRITICAL)
CONTENT:
  - Invoice number
  - Amount due
  - Due date
  - Payment link
  - Late fee warning (if applicable)
RULES:
  - Late fee: 1.5% per month after 30 days
  - Account restrictions after 60 days overdue
  - Collections referral after 90 days
```

#### BR-NOTIF-032: Revenue Statement Ready (Supplier)
```
TRIGGER: Monthly revenue statement generated
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Statement period
  - Total impressions
  - Total revenue
  - Platform fees
  - Net earnings
  - PDF attachment
RULES:
  - Generate by 5th of month for previous month
  - Include store-by-store breakdown
  - Include YTD summary
```

---

## 5. Campaign Notifications

### 5.1 Campaign Lifecycle

#### BR-NOTIF-040: Campaign Created
```
TRIGGER: New campaign saved (DRAFT status)
PRIORITY: LOW
CHANNELS: In-App
CONTENT:
  - Campaign name
  - Next steps to launch
  - Checklist status
RULES:
  - Only in-app notification
  - Include setup completion percentage
```

#### BR-NOTIF-041: Campaign Submitted for Review
```
TRIGGER: Campaign submitted for approval
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Campaign name
  - Submitted content items
  - Expected review time (24-48 hours)
  - Tracking link
RULES:
  - Send to campaign owner
  - Send to approvers (REVIEWER, ADMIN roles)
```

#### BR-NOTIF-042: Campaign Approved
```
TRIGGER: Campaign passes review
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Approved content list
  - Scheduled start date
  - Expected reach estimation
RULES:
  - Send within 5 minutes of approval
  - Include launch countdown if scheduled
```

#### BR-NOTIF-043: Campaign Rejected
```
TRIGGER: Campaign fails review
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Rejection reasons (specific)
  - Violating content items
  - Resubmission instructions
  - Appeal option
RULES:
  - Send within 5 minutes of rejection
  - Include specific policy violations
  - Provide editing link
  - 3 resubmission attempts before permanent rejection
```

#### BR-NOTIF-044: Campaign Started
```
TRIGGER: Campaign transitions to ACTIVE status
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Start timestamp
  - Target store/device count
  - Daily budget
  - Performance dashboard link
RULES:
  - Send within 5 minutes of start
  - Include first 4-hour performance check reminder
```

#### BR-NOTIF-045: Campaign Paused
```
TRIGGER: Campaign paused (manual or automatic)
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Pause reason
  - Pause timestamp
  - Resume instructions
  - Impact summary (missed impressions estimate)
PAUSE_REASONS:
  - MANUAL: "You paused this campaign"
  - BUDGET_EXHAUSTED: "Daily budget exhausted"
  - BALANCE_LOW: "Account balance too low"
  - CONTENT_FLAGGED: "Content requires review"
  - POLICY_VIOLATION: "Policy violation detected"
  - SCHEDULE: "Scheduled pause (dayparting)"
RULES:
  - Send immediately upon pause
  - Different messaging based on reason
  - If BALANCE_LOW: include top-up link
  - If CONTENT_FLAGGED: include review link
```

#### BR-NOTIF-046: Campaign Completed
```
TRIGGER: Campaign reaches end date or full budget spent
PRIORITY: MEDIUM
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Final performance summary
  - Total impressions
  - Total spend
  - Average CPM achieved
  - Full report link
RULES:
  - Send within 1 hour of completion
  - Include "Create Similar Campaign" CTA
  - Include feedback request
```

### 5.2 Campaign Budget Alerts

#### BR-NOTIF-050: Daily Budget Exhausted
```
TRIGGER: Campaign daily budget fully spent
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Campaign name
  - Spend amount
  - Impressions delivered
  - Resume time (next day start)
  - Option to increase budget
RULES:
  - Send once per day per campaign
  - Include performance vs benchmark
```

#### BR-NOTIF-051: Campaign Budget Low
```
TRIGGER: Campaign budget running low
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
THRESHOLDS:
  - 25% remaining: First alert
  - 10% remaining: Second alert
  - 5% remaining: Final warning
CONTENT:
  - Campaign name
  - Remaining budget
  - Estimated days remaining
  - Add budget link
RULES:
  - Calculate based on 7-day average daily spend
  - Only alert once per threshold
```

#### BR-NOTIF-052: Campaign Budget Depleted
```
TRIGGER: Campaign total budget exhausted
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Final spend
  - Total impressions
  - Campaign now COMPLETED
  - Add budget to extend option
RULES:
  - Send immediately
  - Include option to extend campaign with new budget
  - Include final performance metrics
```

### 5.3 Campaign Performance

#### BR-NOTIF-053: Campaign Performance Report
```
TRIGGER: Scheduled (daily/weekly based on preference)
PRIORITY: LOW
CHANNELS: Email + In-App
FREQUENCY:
  - Daily: 8 AM local time
  - Weekly: Monday 8 AM local time
CONTENT:
  - Campaign performance summary
  - Impressions vs goal
  - Spend vs budget
  - Top performing stores
  - Recommendations
RULES:
  - User-configurable frequency
  - Aggregate all active campaigns
  - Include trend indicators (↑↓)
```

#### BR-NOTIF-054: Campaign Underperforming Alert
```
TRIGGER: Campaign performing significantly below target
PRIORITY: HIGH
CHANNELS: Email + In-App
THRESHOLD:
  - < 50% of projected impressions for 2+ consecutive days
CONTENT:
  - Campaign name
  - Expected vs actual performance
  - Potential causes
  - Optimization suggestions
SUGGESTIONS:
  - Expand targeting (more stores/times)
  - Increase bid/budget
  - Review content quality
  - Check device availability
RULES:
  - Do not send for campaigns < 3 days old
  - Maximum one alert per campaign per week
```

#### BR-NOTIF-055: Campaign Goal Achieved
```
TRIGGER: Campaign reaches impression/spend goal ahead of schedule
PRIORITY: MEDIUM
CHANNELS: Email + Push + In-App
CONTENT:
  - Campaign name
  - Goal achieved
  - Days remaining
  - Options: continue, pause, extend goal
RULES:
  - Celebrate achievement
  - Provide options for remaining budget/time
```

---

## 6. Device Notifications

### 6.1 Device Health Alerts

#### BR-NOTIF-060: Device Offline
```
TRIGGER: Device misses 2+ consecutive heartbeats (10+ minutes)
PRIORITY: HIGH (escalates to CRITICAL after 1 hour)
CHANNELS: Email + Push + In-App (SMS after 1 hour)
CONTENT:
  - Device ID and name
  - Store location
  - Last seen timestamp
  - Affected campaigns
  - Troubleshooting steps
ESCALATION:
  - 10 min: Initial alert (HIGH)
  - 1 hour: Escalated alert (CRITICAL) + SMS
  - 4 hours: Store contact attempted
  - 24 hours: Service ticket created
RULES:
  - Group multiple offline devices at same store
  - Provide remote restart option if available
  - Include historical uptime for context
```

#### BR-NOTIF-061: Device Back Online
```
TRIGGER: Previously offline device reconnects
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Device ID and name
  - Downtime duration
  - Missed impressions estimate
  - Current status
RULES:
  - Send within 5 minutes of reconnection
  - Include downtime impact summary
  - Close any open tickets automatically
```

#### BR-NOTIF-062: Device Health Degraded
```
TRIGGER: Device quality score drops below threshold
PRIORITY: HIGH
CHANNELS: Email + In-App
THRESHOLDS:
  - Score < 70: Warning
  - Score < 50: Critical
  - Score < 30: Removal warning
CONTENT:
  - Device ID and name
  - Current quality score
  - Degraded metrics
  - Impact on revenue
  - Improvement recommendations
METRICS_CHECKED:
  - Uptime percentage
  - Content sync success rate
  - Proof-of-play submission rate
  - Network stability
RULES:
  - Send at most once per day per device
  - Include comparison to fleet average
```

#### BR-NOTIF-063: Device Maintenance Required
```
TRIGGER: Device requires attention (storage full, update needed, etc.)
PRIORITY: MEDIUM
CHANNELS: Email + In-App
MAINTENANCE_TYPES:
  - STORAGE_FULL: "Storage at 90%+ capacity"
  - UPDATE_AVAILABLE: "Firmware update available"
  - UPDATE_REQUIRED: "Mandatory security update"
  - CERTIFICATE_EXPIRING: "Security certificate expires in 7 days"
  - HARDWARE_ISSUE: "Hardware diagnostic failure"
CONTENT:
  - Device ID and name
  - Maintenance type
  - Required action
  - Deadline (if any)
  - Impact if not addressed
RULES:
  - UPDATE_REQUIRED: 7-day deadline, then force update
  - STORAGE_FULL: Auto-cleanup old content if not addressed in 48 hours
```

### 6.2 Device Sync Notifications

#### BR-NOTIF-064: Content Sync Failed
```
TRIGGER: Device fails to download campaign content
PRIORITY: HIGH
CHANNELS: Email + In-App
CONTENT:
  - Device ID and name
  - Failed content items
  - Error reason
  - Retry status
  - Manual intervention steps
RETRY_POLICY:
  - Automatic retry: 3 attempts over 30 minutes
  - If all fail: alert sent
RULES:
  - Only alert after retry exhaustion
  - Include specific failure reason
  - Provide manual sync trigger option
```

#### BR-NOTIF-065: Playlist Update Deployed
```
TRIGGER: New playlist successfully deployed to device
PRIORITY: LOW
CHANNELS: In-App only
CONTENT:
  - Device count updated
  - Campaign changes
  - Deployment timestamp
RULES:
  - Aggregate multiple devices
  - Do not spam for routine updates
  - Only notify if user explicitly subscribes
```

---

## 7. Content Notifications

### 7.1 Content Moderation

#### BR-NOTIF-070: Content Upload Successful
```
TRIGGER: Content file successfully uploaded
PRIORITY: LOW
CHANNELS: In-App
CONTENT:
  - File name
  - File size
  - Processing status
  - Estimated moderation time
RULES:
  - Immediate in-app only
  - Include processing progress bar
```

#### BR-NOTIF-071: Content Moderation Pending
```
TRIGGER: Content requires manual review (AI score 70-90)
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Content name
  - Flagged reasons (general categories)
  - Expected review time
  - Position in queue
RULES:
  - Send within 5 minutes of AI flagging
  - Do not reveal specific AI scores
```

#### BR-NOTIF-072: Content Approved
```
TRIGGER: Content passes moderation
PRIORITY: MEDIUM
CHANNELS: Email + Push + In-App
CONTENT:
  - Content name
  - Approval timestamp
  - Approved for use in campaigns
  - Preview link
RULES:
  - Send within 5 minutes of approval
  - Include direct "Add to Campaign" CTA
```

#### BR-NOTIF-073: Content Rejected
```
TRIGGER: Content fails moderation
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Content name
  - Rejection reasons (specific)
  - Policy violations cited
  - Appeal instructions
  - Upload revised version link
REJECTION_REASONS:
  - PROHIBITED_CONTENT: Explicitly forbidden content type
  - QUALITY_INSUFFICIENT: Does not meet quality standards
  - POLICY_VIOLATION: Violates specific advertising policy
  - COPYRIGHT_CONCERN: Potential IP/copyright issue
  - MISSING_DISCLOSURE: Required disclosures missing
RULES:
  - Send within 5 minutes of rejection
  - Include specific timestamps of violations (for video)
  - 1 appeal allowed per rejection
  - Different policies for auto-reject vs manual reject
```

#### BR-NOTIF-074: Content Expiring
```
TRIGGER: Licensed content approaching expiration
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 30 days before: First notice
  - 7 days before: Urgent notice
  - 1 day before: Final warning
CONTENT:
  - Content name
  - Expiration date
  - Campaigns using this content
  - Renewal options
  - Replacement upload link
RULES:
  - Auto-pause campaigns using expired content
  - Provide license renewal workflow if applicable
```

### 7.2 Content Library

#### BR-NOTIF-075: Content Version Replaced
```
TRIGGER: New version uploaded for existing content
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Content name
  - Old vs new version
  - Campaigns affected
  - New moderation status
RULES:
  - Require re-moderation for new version
  - Campaigns continue with old version until new approved
```

#### BR-NOTIF-076: Content Removed from Library
```
TRIGGER: Content deleted or expired
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Content name
  - Removal reason
  - Campaigns affected
  - Replacement needed
RULES:
  - 30-day soft delete for recovery
  - Immediate hard delete for policy violations
```

---

## 8. Compliance Notifications

### 8.1 Document & License Expiration

#### BR-NOTIF-080: Business License Expiring
```
TRIGGER: Business license approaching expiration
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 60 days before: First notice
  - 30 days before: Second notice
  - 14 days before: Urgent notice
  - 7 days before: Final warning
CONTENT:
  - License type
  - Expiration date
  - Upload new license link
  - Impact if not renewed (account restrictions)
RULES:
  - Account restricted to view-only if license expires
  - 30-day grace period to upload new license
  - After grace period: campaigns paused, payouts held
```

#### BR-NOTIF-081: Tax Document Required
```
TRIGGER: Tax document missing or expired
PRIORITY: HIGH
CHANNELS: Email + In-App
DOCUMENTS:
  - W-9 (US individuals/entities)
  - W-8BEN (International individuals)
  - W-8BEN-E (International entities)
CONTENT:
  - Required document type
  - Deadline to submit
  - Impact of non-compliance
  - Upload link
RULES:
  - 24% backup withholding applied without valid W-9
  - Payouts held without valid tax documentation
  - Annual re-certification reminder
```

### 8.2 Policy Compliance

#### BR-NOTIF-082: Policy Violation Warning
```
TRIGGER: Account flagged for policy violation
PRIORITY: CRITICAL
CHANNELS: Email + In-App
CONTENT:
  - Violation type
  - Specific instance(s)
  - Policy reference
  - Required corrective action
  - Deadline to respond
  - Consequences if not addressed
VIOLATION_TYPES:
  - CONTENT_POLICY: Prohibited content uploaded
  - SPAM: Excessive/repetitive campaigns
  - FRAUD_SUSPECTED: Suspicious activity detected
  - TRADEMARK: Unauthorized trademark use
  - DATA_MISUSE: Privacy/data handling violation
RULES:
  - First violation: Warning + 7-day response window
  - Second violation: Temporary restriction + 3-day response
  - Third violation: Account suspension + appeal required
```

#### BR-NOTIF-083: Account Restricted
```
TRIGGER: Account restrictions applied
PRIORITY: CRITICAL
CHANNELS: SMS + Email + In-App
CONTENT:
  - Restriction type
  - Reason
  - Affected capabilities
  - Resolution steps
  - Appeal process
RESTRICTION_TYPES:
  - CAMPAIGNS_PAUSED: Cannot run campaigns
  - WITHDRAWALS_HELD: Cannot withdraw funds
  - VIEW_ONLY: Full account freeze
  - PERMANENT_BAN: Account terminated
RULES:
  - Clear explanation required
  - Appeal option within 14 days
  - Escalation to legal if permanent ban
```

### 8.3 Regulatory Updates

#### BR-NOTIF-084: Terms of Service Update
```
TRIGGER: Platform ToS updated
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Summary of changes
  - Effective date (30 days notice)
  - Full document link
  - Accept/review required
RULES:
  - 30-day advance notice required
  - Highlight material changes
  - Continued use = acceptance after effective date
```

#### BR-NOTIF-085: Privacy Policy Update
```
TRIGGER: Privacy policy updated
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Summary of changes
  - Data handling changes
  - Effective date
  - Opt-out options (if applicable)
RULES:
  - GDPR/CCPA compliance requirements
  - Clear explanation of data rights
```

---

## 9. Dispute Notifications

### 9.1 Dispute Lifecycle

#### BR-NOTIF-090: Dispute Filed
```
TRIGGER: New dispute submitted
PRIORITY: HIGH
CHANNELS: Email + In-App
RECIPIENTS:
  - Dispute filer: Confirmation
  - Other party: Notification of dispute
  - Admin: New dispute alert
CONTENT:
  - Dispute ID
  - Dispute type
  - Subject (campaign/impression/payout)
  - Amount in question
  - Initial evidence submitted
  - Response deadline (7 days)
RULES:
  - Auto-hold disputed amounts
  - Set response deadline
  - Provide evidence submission portal
```

#### BR-NOTIF-091: Dispute Response Required
```
TRIGGER: Other party has not responded to dispute
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
SCHEDULE:
  - Day 3: Reminder
  - Day 5: Urgent reminder
  - Day 6: Final warning (24 hours remaining)
CONTENT:
  - Dispute ID
  - Time remaining to respond
  - Default judgment warning
  - Response link
RULES:
  - No response = default judgment against non-responder
  - Extension request option (one time, 3 days)
```

#### BR-NOTIF-092: Dispute Evidence Submitted
```
TRIGGER: New evidence added to dispute
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Dispute ID
  - Evidence type
  - Submitting party
  - Review link
  - Counter-response deadline (3 days)
RULES:
  - Both parties can submit evidence
  - Maximum 3 rounds of evidence
  - All evidence visible to both parties
```

#### BR-NOTIF-093: Dispute Under Review
```
TRIGGER: Dispute escalated to admin review
PRIORITY: MEDIUM
CHANNELS: Email + In-App
CONTENT:
  - Dispute ID
  - Escalation reason
  - Expected resolution time (5-10 business days)
  - Review team contact
RULES:
  - No new evidence accepted during review
  - Either party can request expedited review (fee may apply)
```

#### BR-NOTIF-094: Dispute Resolved
```
TRIGGER: Dispute decision made
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Dispute ID
  - Decision (APPROVED/DENIED/PARTIAL)
  - Decision rationale
  - Financial adjustments
  - Appeal option (14 days)
RULES:
  - Clear explanation of decision
  - Immediate financial adjustments
  - One appeal allowed
```

#### BR-NOTIF-095: Dispute Appeal Deadline
```
TRIGGER: Appeal window closing
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 7 days remaining: First notice
  - 3 days remaining: Reminder
  - 1 day remaining: Final notice
CONTENT:
  - Dispute ID
  - Original decision
  - Appeal deadline
  - Appeal submission link
RULES:
  - Appeal requires new evidence or procedural objection
  - One appeal per dispute
```

---

## 10. System Notifications

### 10.1 Platform Maintenance

#### BR-NOTIF-100: Scheduled Maintenance
```
TRIGGER: Maintenance window scheduled
PRIORITY: MEDIUM
CHANNELS: Email + In-App
SCHEDULE:
  - 7 days before: Announcement
  - 24 hours before: Reminder
  - 1 hour before: Final notice
  - During: Status updates
  - After: Completion notice
CONTENT:
  - Maintenance window (start/end)
  - Affected services
  - Expected impact
  - Workarounds (if any)
  - Status page link
RULES:
  - Minimum 7 days notice for planned maintenance
  - Emergency maintenance: immediate notice
  - Regular status updates during maintenance
```

#### BR-NOTIF-101: Emergency Maintenance
```
TRIGGER: Unplanned maintenance required
PRIORITY: CRITICAL
CHANNELS: SMS + Email + Push + In-App
CONTENT:
  - Issue summary
  - Affected services
  - Estimated resolution time
  - Status page link
  - Credit/SLA impact notice
RULES:
  - Send immediately upon decision
  - Update every 30 minutes
  - Post-incident report within 24 hours
```

#### BR-NOTIF-102: Service Restored
```
TRIGGER: Service restored after outage
PRIORITY: HIGH
CHANNELS: Email + Push + In-App
CONTENT:
  - Services restored
  - Outage duration
  - Root cause summary
  - Data integrity confirmation
  - Credit applied (if applicable)
RULES:
  - Confirm all data integrity
  - Link to full incident report
```

### 10.2 Feature & API Notifications

#### BR-NOTIF-103: New Feature Announcement
```
TRIGGER: New platform feature released
PRIORITY: LOW
CHANNELS: Email + In-App
CONTENT:
  - Feature name
  - Feature description
  - How to access
  - Documentation link
RULES:
  - Segment by user type (advertiser/supplier)
  - Include tutorial/walkthrough
  - Respect marketing opt-out preferences
```

#### BR-NOTIF-104: API Deprecation Notice
```
TRIGGER: API version/endpoint deprecation
PRIORITY: HIGH
CHANNELS: Email + In-App
SCHEDULE:
  - 90 days before: Announcement
  - 60 days before: Reminder
  - 30 days before: Urgent notice
  - 7 days before: Final warning
  - Sunset date: Deprecation active
CONTENT:
  - Deprecated endpoint/version
  - Sunset date
  - Migration guide
  - New endpoint details
  - Support contact
RULES:
  - Minimum 90 days notice
  - Include code migration examples
  - Offer migration assistance
```

#### BR-NOTIF-105: API Rate Limit Warning
```
TRIGGER: API usage approaching rate limit
PRIORITY: HIGH
CHANNELS: Email + In-App
THRESHOLDS:
  - 80% of limit: Warning
  - 95% of limit: Critical
  - 100%: Rate limited notification
CONTENT:
  - Current usage
  - Rate limit
  - Reset time
  - Upgrade options
  - Optimization suggestions
RULES:
  - Per-tier rate limits enforced
  - Include specific endpoints consuming quota
```

---

## 11. Notification Preferences & Management

### 11.1 User Preferences

#### BR-NOTIF-PREF-001: Notification Channels
```
Users can configure preferred channels per category:
- CRITICAL: Cannot be disabled, always all channels
- HIGH: Email required, Push/SMS optional
- MEDIUM: Email required, others optional
- LOW: All optional

DEFAULTS:
  - Security: All channels enabled
  - Financial: Email + Push enabled
  - Campaign: Email + In-App enabled
  - Device: Email + In-App enabled
  - Content: In-App enabled
  - System: Email + In-App enabled
```

#### BR-NOTIF-PREF-002: Digest Options
```
Users can opt for digest notifications:
- IMMEDIATE: Real-time delivery
- HOURLY: Aggregated hourly
- DAILY: Daily digest at configured time
- WEEKLY: Weekly summary

RESTRICTIONS:
  - CRITICAL priority: Always immediate
  - HIGH priority: Immediate or hourly only
  - MEDIUM/LOW: Any frequency
```

#### BR-NOTIF-PREF-003: Quiet Hours
```
Users can set quiet hours for non-critical notifications:
- Configurable start/end time
- Configurable days
- Exceptions for CRITICAL priority
- Time zone aware

DEFAULT:
  - 10 PM - 8 AM local time
  - Weekends optional
```

### 11.2 Organization Settings

#### BR-NOTIF-ORG-001: Role-Based Notifications
```
Notifications routed by role:
- OWNER: All notifications
- ADMIN: All except billing details
- CAMPAIGN_MANAGER: Campaign + Content notifications
- CONTENT_CREATOR: Content notifications only
- VIEWER: Performance summaries only
- BILLING: Financial notifications only
```

#### BR-NOTIF-ORG-002: Escalation Contacts
```
Organization can configure escalation contacts:
- Primary contact (required)
- Secondary contact (optional)
- After-hours contact (optional)
- Emergency contact (CRITICAL only)

ESCALATION_RULES:
  - CRITICAL not acknowledged in 15 min → secondary
  - CRITICAL not acknowledged in 30 min → after-hours
  - CRITICAL not acknowledged in 1 hour → emergency
```

---

## 12. Webhook Notifications (API Integrations)

### 12.1 Webhook Configuration

#### BR-NOTIF-WEBHOOK-001: Webhook Setup
```
API integrations can receive notifications via webhooks:
- HTTPS endpoints only
- Signature verification required
- Retry policy: 3 attempts with exponential backoff
- Timeout: 30 seconds per request

CONFIGURATION:
  - Endpoint URL
  - Secret key for signature
  - Event subscriptions
  - Active/inactive status
```

#### BR-NOTIF-WEBHOOK-002: Webhook Payload

**Payload Contents**:

| Field | Description |
|-------|-------------|
| Event Type | Type of event (e.g., campaign.status_changed) |
| Event ID | Unique event identifier |
| Timestamp | When event occurred |
| Data | Event-specific payload data |
| Signature | SHA-256 signature for verification |

The payload includes all relevant data for the event type, allowing the receiving system to process the notification without making additional API calls.

#### BR-NOTIF-WEBHOOK-003: Webhook Events Available
```
CAMPAIGN_EVENTS:
  - campaign.created
  - campaign.submitted
  - campaign.approved
  - campaign.rejected
  - campaign.started
  - campaign.paused
  - campaign.completed
  - campaign.budget_low

FINANCIAL_EVENTS:
  - wallet.topup_completed
  - wallet.topup_failed
  - wallet.withdrawal_completed
  - wallet.withdrawal_failed
  - wallet.balance_low

DEVICE_EVENTS:
  - device.online
  - device.offline
  - device.health_changed
  - device.sync_completed
  - device.sync_failed

CONTENT_EVENTS:
  - content.uploaded
  - content.approved
  - content.rejected
  - content.expired

IMPRESSION_EVENTS:
  - impression.verified
  - impression.rejected
  - impression.disputed
```

### 12.2 Webhook Reliability

#### BR-NOTIF-WEBHOOK-004: Retry Policy
```
RETRY_SCHEDULE:
  - Attempt 1: Immediate
  - Attempt 2: 1 minute delay
  - Attempt 3: 5 minutes delay
  - Attempt 4: 30 minutes delay
  - Attempt 5: 2 hours delay

FAILURE_RESPONSES:
  - 2xx: Success, no retry
  - 3xx: Follow redirect once, then fail
  - 4xx: No retry (client error)
  - 5xx: Retry according to schedule
  - Timeout: Retry according to schedule

AFTER_ALL_RETRIES_FAIL:
  - Log failure
  - Send email alert to webhook owner
  - Disable webhook after 100 consecutive failures
```

#### BR-NOTIF-WEBHOOK-005: Webhook Health Monitoring
```
HEALTH_METRICS:
  - Success rate (last 24 hours)
  - Average response time
  - Error rate by type

ALERTS:
  - Success rate < 95%: Warning email
  - Success rate < 80%: Webhook paused, urgent alert
  - Success rate < 50% for 24 hours: Webhook disabled
```

---

## 13. Notification Templates & Localization

### 13.1 Template Structure

#### BR-NOTIF-TEMPLATE-001: Template Components
```
Each notification template includes:
- Subject line (email)
- Preview text (email, 100 chars max)
- Body (HTML for email, plain for SMS)
- Action buttons (email, push)
- Unsubscribe link (email)
- Footer (email)

VARIABLES:
  - {{user.name}}
  - {{user.email}}
  - {{organization.name}}
  - {{campaign.name}}
  - {{device.name}}
  - {{amount}}
  - {{date}}
  - {{action_url}}
```

### 13.2 Localization

#### BR-NOTIF-LOCALE-001: Supported Languages
```
SUPPORTED_LANGUAGES:
  - English (en) - Default
  - Vietnamese (vi)
  - [Extensible for additional languages]

RULES:
  - User preference takes precedence
  - Organization default as fallback
  - English as final fallback
  - Date/time/currency formatted per locale
```

---

## 14. Notification Analytics & Reporting

### 14.1 Delivery Metrics

#### BR-NOTIF-ANALYTICS-001: Tracking Metrics
```
METRICS_TRACKED:
  - Sent count
  - Delivered count
  - Opened count (email)
  - Clicked count (email)
  - Bounce rate (email)
  - Unsubscribe rate (email)
  - Response time (from send to action)

REPORTING:
  - Real-time dashboard for admins
  - Daily summary reports
  - Monthly trends
  - Anomaly detection (spike/drop in deliveries)
```

### 14.2 Compliance Tracking

#### BR-NOTIF-ANALYTICS-002: Audit Log
```
All notifications logged with:
  - Notification ID
  - Recipient
  - Channel
  - Timestamp sent
  - Timestamp delivered
  - Timestamp opened/read
  - User action taken
  - Template version used

RETENTION:
  - Logs retained for 2 years
  - Anonymized after retention period
```

---

## 15. Edge Cases & Error Handling

### 15.1 Delivery Failures

#### BR-NOTIF-EDGE-001: Email Bounce Handling
```
SOFT_BOUNCE:
  - Mailbox full
  - Server temporarily unavailable
  - Message too large
  ACTION: Retry up to 3 times over 24 hours

HARD_BOUNCE:
  - Invalid email address
  - Domain does not exist
  - Permanent failure
  ACTION: Mark email invalid, notify user to update
```

#### BR-NOTIF-EDGE-002: SMS Delivery Failure
```
FAILURE_REASONS:
  - Invalid phone number
  - Carrier rejection
  - User opted out
  - Number ported
  ACTION:
  - Mark number as invalid after 3 failures
  - Fall back to email for critical notifications
  - Request number update from user
```

#### BR-NOTIF-EDGE-003: Push Notification Failure
```
FAILURE_REASONS:
  - Device token expired
  - App uninstalled
  - Notification permissions revoked
  ACTION:
  - Remove invalid tokens
  - Fall back to email
  - Do not retry push failures
```

### 15.2 Rate Limiting & Spam Prevention

#### BR-NOTIF-EDGE-004: Anti-Spam Rules
```
LIMITS:
  - Maximum 50 notifications per user per day
  - Maximum 10 notifications per user per hour
  - Maximum 5 same-type notifications per day

EXCEPTIONS:
  - CRITICAL priority bypasses limits
  - Security notifications bypass limits
  - User-initiated notifications bypass limits

AGGREGATION:
  - If limit reached, aggregate into digest
  - Send digest at next scheduled time
```

#### BR-NOTIF-EDGE-005: Duplicate Prevention
```
RULES:
  - Deduplicate identical notifications within 5 minutes
  - Hash: notification_type + user_id + key_identifiers
  - Store dedup cache for 1 hour

EXCEPTIONS:
  - Security alerts never deduplicated
  - User actions trigger fresh notification
```

### 15.3 Time-Sensitive Handling

#### BR-NOTIF-EDGE-006: Expired Notifications
```
RULES:
  - Time-sensitive notifications have TTL
  - Do not deliver after TTL expires
  - Log as "expired, not sent"

EXAMPLES:
  - "Campaign starts in 1 hour" - TTL: 1 hour
  - "Budget exhausted" - TTL: 4 hours
  - "Daily report" - TTL: 24 hours

HANDLING:
  - Check TTL before each delivery attempt
  - If expired, skip and log
```

#### BR-NOTIF-EDGE-007: Time Zone Edge Cases
```
SCENARIOS:
  - User changes time zone mid-schedule
  - Daylight saving time transitions
  - Cross-midnight notifications

RULES:
  - Use user's current time zone at send time
  - DST: Prefer local wall clock time
  - Cross-midnight: Attribute to original trigger day
```

---

## 16. Appendices

### Appendix A: Notification Priority Matrix

| Notification Type | Default Priority | Can Escalate? | User Can Modify? |
|-------------------|------------------|---------------|------------------|
| Security Alert | CRITICAL | No | No |
| Fraud Detection | CRITICAL | No | No |
| Account Restricted | CRITICAL | No | No |
| Balance Depleted | CRITICAL | No | Channel only |
| Device Offline | HIGH | Yes → CRITICAL | Yes |
| Campaign Paused | HIGH | No | Yes |
| Content Rejected | HIGH | No | Yes |
| Dispute Filed | HIGH | No | No |
| Low Balance | HIGH | Yes → CRITICAL | Threshold only |
| Top-up Success | MEDIUM | No | Yes |
| Campaign Started | MEDIUM | No | Yes |
| Performance Report | LOW | No | Yes |
| Feature Announcement | LOW | No | Yes |

### Appendix B: Channel Capabilities

| Channel | Max Length | Rich Content | Action Buttons | Tracking | Cost |
|---------|------------|--------------|----------------|----------|------|
| Email | Unlimited | Yes (HTML) | Yes | Opens, Clicks | Low |
| SMS | 160 chars | No | No (link only) | Delivery | High |
| Push | 256 chars | Limited | Yes (2 max) | Opens | None |
| In-App | Unlimited | Yes | Yes | Views, Actions | None |
| Webhook | Unlimited | JSON | N/A | Delivery | None |

### Appendix C: Notification SLAs

| Priority | Send Latency | Delivery Target | Retry Window |
|----------|--------------|-----------------|--------------|
| CRITICAL | < 30 seconds | 99.9% | 24 hours |
| HIGH | < 2 minutes | 99.5% | 12 hours |
| MEDIUM | < 10 minutes | 99% | 6 hours |
| LOW | < 1 hour | 95% | 4 hours |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-02-05 | Platform Team | Initial document creation |
