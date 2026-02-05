# Campaign Module - Business Rules Document

**Version**: 1.0
**Date**: 2026-01-23
**Status**: Draft for Review
**Owner**: Product Team

---

## Table of Contents

1. [Overview](#overview)
2. [Domain Entities](#domain-entities)
3. [Campaign Lifecycle](#campaign-lifecycle)
4. [Campaign Editing Rules](#campaign-editing-rules)
5. [Emergency Stop Mechanism](#emergency-stop-mechanism)
6. [Campaign Preview & Testing](#campaign-preview--testing)
7. [A/B Testing Support](#ab-testing-support)
8. [Business Rules](#business-rules)
9. [Billing & Pricing](#billing--pricing)
10. [Impression Tracking](#impression-tracking)
11. [Competitor Blocking](#competitor-blocking)
12. [Edge Cases & Error Handling](#edge-cases--error-handling)
13. [Validation Rules](#validation-rules)
14. [Calculations & Formulas](#calculations--formulas)

---

## Overview

### Purpose
This document defines ALL business rules for the Campaign module in RMN-Arms platform. It serves as the single source of truth for:
- Product team (requirement validation)
- Development team (implementation reference)
- QA team (test case creation)
- Business stakeholders (process understanding)

### Scope
- Campaign creation and management
- Impression-based billing
- Budget management
- Content distribution
- Competitor blocking
- Revenue sharing with suppliers

### Out of Scope
- User authentication (see Auth module)
- Content upload/storage (see CMS module)
- Device management (see Device module)

---

## Domain Entities

### 1. Campaign

**Definition**: An advertising initiative created by an advertiser to display content on retail media networks.

**Attributes**:

| Field | Type | Required | Default | Business Rule |
|-------|------|----------|---------|---------------|
| `id` | UUID | Yes | Auto-generated | Immutable after creation |
| `advertiser_id` | UUID | Yes | Current user | Must be active advertiser |
| `name` | String(100) | Yes | - | Unique per advertiser |
| `description` | Text | No | null | Max 500 characters |
| `brand_name` | String(50) | Yes | - | For competitor blocking |
| `category` | Enum | Yes | - | See [Category Enum](#category-enum) |
| `budget` | Decimal(10,2) | Yes | - | Min: $100.00, Max: $1,000,000.00 |
| `spent` | Decimal(10,2) | Yes | 0.00 | Auto-calculated, read-only |
| `remaining_budget` | Decimal(10,2) | Yes | = budget | Computed: budget - spent |
| `start_date` | DateTime | Yes | - | Must be >= NOW + 24 hours |
| `end_date` | DateTime | Yes | - | Must be > start_date |
| `status` | Enum | Yes | DRAFT | See [Status Lifecycle](#status-lifecycle) |
| `target_stores` | Array[UUID] | Yes | [] | Min: 1, Max: 1000 stores |
| `blocked_stores` | Array[UUID] | Yes | [] | Auto-populated by blocking rules |
| `content_assets` | Array[UUID] | Yes | [] | Min: 1 asset |
| `priority` | Integer | Yes | 5 | Range: 1-10 (10 = highest) |
| `daily_cap` | Decimal(10,2) | No | null | Optional daily budget limit |
| `impression_goal` | Integer | No | null | Target impressions (informational) |
| `created_at` | DateTime | Yes | NOW() | Immutable |
| `updated_at` | DateTime | Yes | NOW() | Auto-updated |
| `activated_at` | DateTime | No | null | Set when status = ACTIVE |
| `completed_at` | DateTime | No | null | Set when status = COMPLETED |

#### Category Enum
```
- FOOD_BEVERAGE
- ELECTRONICS
- FASHION_APPAREL
- HEALTH_BEAUTY
- HOME_GARDEN
- AUTOMOTIVE
- ENTERTAINMENT
- FINANCIAL_SERVICES
- TELECOM
- OTHER
```

#### Status Lifecycle
```
DRAFT → PENDING_APPROVAL → SCHEDULED → ACTIVE → PAUSED → COMPLETED
                                  ↓                    ↓
                               REJECTED              CANCELLED
```

**State Descriptions**:
- `DRAFT`: Campaign being created, not submitted
- `PENDING_APPROVAL`: Submitted, awaiting admin review (if required)
- `SCHEDULED`: Approved, waiting for start_date
- `ACTIVE`: Currently serving ads
- `PAUSED`: Temporarily stopped (by user or system)
- `COMPLETED`: Ended normally (date reached or budget exhausted)
- `CANCELLED`: Terminated by user before completion
- `REJECTED`: Admin rejected the campaign

---

### 2. Impression

**Definition**: A single verified playback of campaign content on a device.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `campaign_id` | UUID | Yes | Must be ACTIVE campaign |
| `device_id` | UUID | Yes | Must be registered device |
| `store_id` | UUID | Yes | Derived from device |
| `content_asset_id` | UUID | Yes | Which asset was played |
| `played_at` | DateTime | Yes | Server timestamp (UTC) |
| `duration_expected` | Integer | Yes | Content duration (seconds) |
| `duration_actual` | Integer | Yes | Actual play time (seconds) |
| `verified` | Boolean | Yes | Default: false |
| `proof_hash` | String(64) | No | SHA256 of proof-of-play |
| `cost` | Decimal(10,4) | Yes | Calculated CPM cost |
| `cpm_rate` | Decimal(10,2) | Yes | Rate at time of impression |
| `is_peak_hour` | Boolean | Yes | For billing calculation |
| `supplier_revenue` | Decimal(10,4) | Yes | 80% of cost |
| `platform_revenue` | Decimal(10,4) | Yes | 20% of cost |
| `status` | Enum | Yes | PENDING/VERIFIED/REJECTED |
| `rejection_reason` | String(200) | No | If status = REJECTED |
| `created_at` | DateTime | Yes | Immutable |

---

### 3. BudgetTransaction

**Definition**: Record of budget change events for auditability.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `campaign_id` | UUID | Yes | - |
| `transaction_type` | Enum | Yes | DEBIT/CREDIT/HOLD/RELEASE/REFUND |
| `amount` | Decimal(10,2) | Yes | Always positive |
| `balance_before` | Decimal(10,2) | Yes | Snapshot |
| `balance_after` | Decimal(10,2) | Yes | Snapshot |
| `reference_id` | UUID | No | Impression ID or refund ID |
| `description` | String(200) | Yes | Human-readable reason |
| `created_at` | DateTime | Yes | Immutable |

---

## Campaign Lifecycle

### 1. Creation Flow

#### Step 1: Initialize Draft
```
Actor: Advertiser
Trigger: User clicks "Create Campaign"

Process:
1. System creates campaign with status = DRAFT
2. System generates campaign.id
3. System sets advertiser_id = current_user.id
4. System sets created_at = NOW()

Business Rules:
- Advertiser must have verified email
- Advertiser account must be ACTIVE status
- No limit on number of DRAFT campaigns

Output:
- campaign_id returned to frontend
- User redirected to campaign editor
```

#### Step 2: Basic Information
```
Actor: Advertiser
Input:
  - name: String
  - description: String (optional)
  - brand_name: String
  - category: Enum
  - budget: Decimal
  - start_date: DateTime
  - end_date: DateTime
  - daily_cap: Decimal (optional)

Validation Rules:
✓ name: Length 3-100 chars, unique per advertiser
✓ brand_name: Length 2-50 chars, required for competitor matching
✓ category: Must be valid enum value
✓ budget: >= $100.00 AND <= $1,000,000.00
✓ start_date: >= NOW() + 24 hours (minimum lead time)
✓ end_date: > start_date AND <= start_date + 365 days
✓ daily_cap: If provided, must be >= $10 AND <= budget

Business Rules:
- 24-hour lead time allows content pre-distribution
- Max 365 days prevents indefinite campaigns
- Daily cap helps advertisers control burn rate

Error Messages:
- "Campaign name already exists"
- "Minimum budget is $100"
- "Start date must be at least 24 hours in future"
- "Campaign duration cannot exceed 1 year"

Output:
- Campaign updated with basic info
- Status remains DRAFT
```

#### Step 3: Content Selection
```
Actor: Advertiser
Input:
  - content_assets: Array[UUID]

Validation Rules:
✓ content_assets: Min 1, Max 10 assets
✓ Each asset must belong to current advertiser
✓ Each asset must have status = APPROVED
✓ All assets must have valid media files (video/image)

Business Rules:
- System rotates multiple assets evenly if >1 provided
- Video duration: 10-60 seconds
- Image duration: 10 seconds (configurable per device)
- Supported formats: MP4, JPG, PNG
- Max file size: 50MB per asset
- Min resolution: 1920x1080

Error Messages:
- "At least 1 content asset required"
- "Asset not found or access denied"
- "Asset not approved by admin"
- "Video duration must be 10-60 seconds"

Output:
- Campaign.content_assets updated
- System calculates total content duration
```

#### Step 4: Target Store Selection
```
Actor: Advertiser
Input:
  - target_stores: Array[UUID] OR targeting_criteria: Object

Option A: Manual Selection
  User selects individual stores from list

Option B: Criteria-Based Selection
  targeting_criteria: {
    regions: ["North", "South"],
    categories: ["Supermarket", "Mall"],
    min_foot_traffic: 5000,
    max_distance_km: 50 from lat/lng
  }

Validation Rules:
✓ If manual: Min 1, Max 1000 stores
✓ If criteria: At least one criterion specified
✓ Selected stores must have status = ACTIVE
✓ Selected stores must have >= 1 ACTIVE device

Business Rules:
- System applies competitor blocking rules (see section 7)
- System calculates eligible stores = target_stores - blocked_stores
- System estimates impressions based on:
  * Store foot traffic
  * Device advertising slots
  * Campaign duration
- System estimates cost = estimated_impressions × avg_CPM / 1000

Competitor Blocking:
FOR EACH store IN target_stores:
  IF store has blocking rule matching campaign.brand_name:
    ADD store to blocked_stores
    REMOVE store from eligible stores

Estimation Formula:
estimated_impressions = SUM(
  store.daily_foot_traffic
  × store.device_count
  × store.avg_dwell_time_minutes / 60
  × campaign.duration_days
) × 0.7 (conservative estimate)

estimated_cost = estimated_impressions × avg_CPM / 1000

Validation After Blocking:
✓ eligible_stores.length >= 1 (must have at least 1 store)
✓ estimated_cost <= campaign.budget × 1.2 (allow 20% variance)

Error Messages:
- "All selected stores blocked by competitor rules"
- "Estimated cost ($X) exceeds budget ($Y)"
- "No stores match your targeting criteria"
- "Selected stores have no active devices"

Output:
- campaign.target_stores updated
- campaign.blocked_stores updated
- Return to user:
  * eligible_stores: Array[Store]
  * blocked_stores: Array[{store, reason}]
  * estimated_impressions: Integer
  * estimated_cost: Decimal
  * estimated_CPM: Decimal
```

#### Step 5: Review & Submit
```
Actor: Advertiser
Display:
  - Campaign summary (all fields)
  - Cost breakdown:
    * Total budget: $X
    * Estimated cost: $Y
    * Estimated impressions: Z
    * Average CPM: $A
    * Number of stores: B
  - Terms & Conditions checkbox

Validation Rules:
✓ All required fields completed
✓ Terms accepted = true
✓ Advertiser wallet balance >= campaign.budget

Business Rules:
- Check wallet balance at submit time (may have changed)
- Create budget hold transaction
- Determine if manual approval needed

Content Approval Logic:
IF content_scan_flags IN ["ALCOHOL", "TOBACCO", "GAMBLING", "ADULT"]:
  requires_approval = true
  next_status = PENDING_APPROVAL
ELSE IF campaign.budget > $10,000:
  requires_approval = true
  next_status = PENDING_APPROVAL
ELSE:
  requires_approval = false
  next_status = SCHEDULED

Process:
1. Create BudgetTransaction:
   - type = HOLD
   - amount = campaign.budget
   - description = "Budget hold for campaign: {name}"

2. Deduct from wallet:
   wallet.available_balance -= campaign.budget
   wallet.held_balance += campaign.budget

3. Update campaign:
   - status = next_status
   - updated_at = NOW()

4. If next_status = PENDING_APPROVAL:
   - Create admin review task
   - Send notification to admin team
   - Send email to advertiser: "Campaign pending approval"

5. If next_status = SCHEDULED:
   - Schedule activation job at start_date
   - Send email: "Campaign scheduled"

Error Messages:
- "Insufficient wallet balance ($X available, $Y required)"
- "Please accept Terms & Conditions"
- "Campaign validation failed: {reason}"

Output:
- Campaign submitted successfully
- User redirected to campaign dashboard
- Display appropriate message based on status
```

---

### 2. Approval Flow (If Required)

```
Actor: Admin
Trigger: Campaign status = PENDING_APPROVAL

Admin Review Interface:
- Campaign details (all fields)
- Content preview (video/image player)
- AI content scan results
- Advertiser history (previous campaigns, disputes)
- Store targeting map

Admin Actions:
[APPROVE] [REJECT] [REQUEST_CHANGES]

Action: APPROVE
Process:
1. Update campaign:
   - status = SCHEDULED
   - updated_at = NOW()

2. Schedule activation:
   - Create cron job for start_date
   - Pre-distribute content to CDN

3. Notify advertiser:
   - Email: "Campaign approved"
   - Push notification to dashboard

Action: REJECT
Input:
  - rejection_reason: String (required)

Process:
1. Update campaign:
   - status = REJECTED
   - rejection_reason = input
   - updated_at = NOW()

2. Release budget hold:
   - Create BudgetTransaction (type = RELEASE)
   - wallet.held_balance -= campaign.budget
   - wallet.available_balance += campaign.budget

3. Notify advertiser:
   - Email: "Campaign rejected: {reason}"
   - Allow resubmission after fixes

Business Rules:
- Admin must provide reason for rejection
- Advertiser can edit and resubmit rejected campaigns
- Budget automatically released on rejection
```

---

### 3. Activation Flow

```
Trigger:
  - Current time >= campaign.start_date
  - Campaign status = SCHEDULED

Pre-flight Checks:
✓ Campaign status = SCHEDULED
✓ Campaign.remaining_budget > 0
✓ At least 1 target device is ONLINE
✓ Content assets accessible on CDN

Process:
1. Verify budget:
   IF remaining_budget < (avg_CPM / 1000):
     ABORT activation
     status = PAUSED
     Send notification: "Insufficient budget"
     EXIT

2. Distribute content:
   FOR EACH device IN eligible_devices:
     - Push content manifest to device
     - Include: campaign_id, asset_urls, priority
     - Wait for ACK (timeout: 30 seconds)

   eligible_devices = devices WHERE:
     - device.store_id IN campaign.target_stores
     - device.status = ACTIVE
     - device.last_heartbeat > NOW() - 5 minutes

3. Update campaign:
   - status = ACTIVE
   - activated_at = NOW()
   - updated_at = NOW()

4. Initialize tracking:
   - Create impression counter (Redis)
   - Start real-time budget monitoring
   - Enable billing engine for this campaign

5. Notify advertiser:
   - Email: "Campaign is now live"
   - Dashboard: Show "ACTIVE" status
   - Enable real-time stats view

Edge Cases:

Case 1: All Devices Offline
Action:
- Status = ACTIVE (keep trying)
- Log warning: "No online devices for campaign {id}"
- Retry content push every 5 minutes
- If no device online after 1 hour:
  * Send alert to advertiser
  * Suggest pausing campaign
- No billing occurs until first impression

Case 2: Content Distribution Failed
Action:
- Retry up to 3 times (exponential backoff)
- If still failed:
  * Status = ERROR
  * Log error details
  * Send urgent notification to admin & advertiser
  * Offer: "Pause campaign or retry"

Case 3: Start Date in Past (System Downtime)
Action:
- Activate immediately if:
  * start_date < NOW() < end_date
  * remaining_budget > 0
- Skip pre-flight grace period
- Log late activation warning

Business Rules:
- Campaign remains ACTIVE even if all devices go offline
- First impression must occur within 24 hours or trigger alert
- Content cached on devices for 7 days
```

---

## Campaign Editing Rules

### Rule 0: Field Editability by Status

#### BR-CAMP-EDIT-001: Edit Matrix by Campaign Status

| Field | DRAFT | PENDING_APPROVAL | SCHEDULED | ACTIVE | PAUSED | COMPLETED |
|-------|-------|------------------|-----------|--------|--------|-----------|
| name | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✗ Read-only |
| description | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✗ Read-only |
| brand_name | ✓ Edit | ✓ Edit | ✗ Read-only | ✗ Read-only | ✗ Read-only | ✗ Read-only |
| category | ✓ Edit | ✓ Edit | ✗ Read-only | ✗ Read-only | ✗ Read-only | ✗ Read-only |
| budget | ✓ Edit | ✓ Edit | ✓ Increase only | ✓ Increase only | ✓ Increase only | ✗ Read-only |
| start_date | ✓ Edit | ✓ Edit | ✓ Edit* | ✗ Read-only | ✗ Read-only | ✗ Read-only |
| end_date | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Extend only | ✓ Extend only | ✗ Read-only |
| daily_cap | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✗ Read-only |
| target_stores | ✓ Edit | ✓ Edit | ✓ Add only | ✓ Add only | ✓ Add only | ✗ Read-only |
| content_assets | ✓ Edit | ✗ Read-only** | ✗ Read-only | ✗ Read-only*** | ✗ Read-only | ✗ Read-only |
| priority | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✓ Edit | ✗ Read-only |

```
* start_date in SCHEDULED: Can only move forward (delay), minimum 24h from NOW
** content_assets in PENDING_APPROVAL: Editing requires re-submission
*** content_assets in ACTIVE: Can add new approved assets, cannot remove playing assets
```

#### BR-CAMP-EDIT-002: Edit Validation Rules
```
BUDGET CHANGES:
  - DECREASE allowed only in DRAFT
  - INCREASE allowed in DRAFT, PENDING_APPROVAL, SCHEDULED, ACTIVE, PAUSED
  - Increase requires wallet balance check
  - Increase applies immediately

DATE CHANGES:
  - start_date delay (SCHEDULED): Minimum 24h lead time maintained
  - start_date advance: Not allowed after SCHEDULED
  - end_date extension: Allowed if budget remaining
  - end_date shortening: Allowed in SCHEDULED, triggers recalculation

TARGET_STORES CHANGES:
  - Add stores: Allowed in SCHEDULED, ACTIVE, PAUSED
  - Remove stores: Only allowed in DRAFT, PENDING_APPROVAL
  - Adding stores triggers blocking rule check

CONTENT_ASSETS CHANGES:
  - Add approved assets: Allowed in ACTIVE if content already approved
  - Remove assets: Not allowed if asset currently playing
  - Replace assets: Requires pause, update, resume
```

#### BR-CAMP-EDIT-003: Edit Audit Trail
```
Every edit creates AuditLog entry:
{
  campaign_id: UUID,
  field_changed: String,
  old_value: Any,
  new_value: Any,
  changed_by: UUID (user_id),
  changed_at: DateTime,
  change_type: "MANUAL" | "SYSTEM" | "API",
  ip_address: String,
  reason: String (optional)
}

RETENTION:
- Audit logs retained for 7 years
- Immutable after creation
- Accessible via admin dashboard
```

---

## Emergency Stop Mechanism

### BR-CAMP-EMERGENCY-001: Emergency Stop Triggers

```
EMERGENCY STOP can be triggered by:

1. ADVERTISER:
   - One-click "Emergency Stop" button in dashboard
   - Available for ACTIVE campaigns only
   - No confirmation required (immediate action)

2. ADMIN:
   - Emergency stop any campaign
   - Can stop multiple campaigns at once
   - Required for policy violations

3. SYSTEM:
   - Fraud detection triggers
   - Security incident response
   - Platform-wide emergency

4. SUPPLIER:
   - Can request emergency stop for campaigns on their stores
   - Requires admin approval (unless safety concern)
```

### BR-CAMP-EMERGENCY-002: Emergency Stop Process
```
IMMEDIATE ACTIONS (< 30 seconds):
1. Campaign status → PAUSED
2. pause_reason = "EMERGENCY_STOP"
3. emergency_stopped_at = NOW()
4. emergency_stopped_by = user_id
5. Send STOP command to ALL devices

DEVICE RESPONSE:
- Devices receive stop command via push notification
- Devices must stop playback within 30 seconds
- Current impression completes (not interrupted mid-play)
- Remove campaign from local playlist

FOLLOW-UP ACTIONS:
1. Log emergency stop event
2. Notify advertiser (if not self-initiated)
3. Notify affected suppliers
4. Freeze any pending transactions
5. Generate incident report
```

### BR-CAMP-EMERGENCY-003: Emergency Stop vs Regular Pause
```
                        | REGULAR PAUSE    | EMERGENCY STOP
------------------------|------------------|------------------
Initiation              | User clicks pause| Emergency button/trigger
Confirmation required   | Yes              | No
Grace period            | 5 minutes        | 30 seconds
In-flight impressions   | Honored          | Completed only
Resume capability       | Immediate        | Requires review
Notification            | Standard         | Urgent + escalation
Audit level             | Normal           | Enhanced
Billing                 | Continue 5min    | Stop immediately
```

### BR-CAMP-EMERGENCY-004: Emergency Stop Reasons
```
REASON_CODES:
- BRAND_SAFETY: Content appearing in inappropriate context
- CONTENT_ERROR: Wrong or corrupted content playing
- LEGAL_DEMAND: Court order or legal requirement
- FRAUD_DETECTED: Suspicious activity detected
- SECURITY_INCIDENT: Platform security event
- ADVERTISER_REQUEST: Advertiser emergency (no reason required)
- SUPPLIER_COMPLAINT: Supplier raised urgent concern
- TECHNICAL_ISSUE: System malfunction
- BUDGET_FRAUD: Suspicious budget manipulation
- OTHER: Requires free-text explanation

MANDATORY FIELDS:
- reason_code: Enum (required)
- reason_detail: String (required if OTHER)
- evidence_urls: Array[String] (optional)
```

### BR-CAMP-EMERGENCY-005: Post-Emergency Stop Procedure
```
INVESTIGATION (within 24 hours):
1. Review stop reason and evidence
2. Check device logs for affected period
3. Review impressions during incident
4. Assess financial impact
5. Document findings

RESOLUTION OPTIONS:
A) FALSE ALARM:
   - Allow resume
   - No penalties
   - Optional compensation for lost impressions

B) VALID CONCERN:
   - Require issue resolution
   - May require content re-approval
   - May require additional verification

C) POLICY VIOLATION:
   - Campaign remains paused
   - Issue formal warning
   - May require account review

D) FRAUD CONFIRMED:
   - Campaign terminated
   - Account investigation
   - Potential legal action
```

---

## Campaign Preview & Testing

### BR-CAMP-PREVIEW-001: Preview Mode
```
PURPOSE: Allow advertisers to see how content appears before going live

PREVIEW TYPES:
1. CONTENT_PREVIEW: View content as it will appear on device
2. DEVICE_PREVIEW: Simulate on specific device type/size
3. STORE_PREVIEW: Preview in context of store environment
4. SCHEDULE_PREVIEW: See how rotation will work

CONTENT_PREVIEW:
- Available in: DRAFT, PENDING_APPROVAL, SCHEDULED
- Shows: Rendered content at target resolution
- Duration: Actual playback duration
- Audio: Included if applicable

DEVICE_PREVIEW:
- Simulate different screen sizes (32", 42", 55", 65")
- Simulate different resolutions (1080p, 4K)
- Simulate different orientations (landscape, portrait)
- Show safe zone margins

STORE_PREVIEW:
- Mock-up of content in store context
- Show position relative to other campaigns
- Preview rotation with other active campaigns
- NOT available for ACTIVE campaigns (use live dashboard)
```

### BR-CAMP-PREVIEW-002: Test Mode
```
PURPOSE: Run campaign in limited scope before full launch

TEST MODE RULES:
- Available only for SCHEDULED campaigns
- Maximum test duration: 24 hours
- Maximum test stores: 3
- Maximum test budget: $50

TEST MODE PROCESS:
1. Advertiser selects "Run Test"
2. Select 1-3 test stores (from target stores)
3. Set test budget ($10-$50)
4. Test period: Up to 24 hours

DURING TEST:
- Campaign status = TEST (special sub-status of SCHEDULED)
- Content delivered only to test stores
- Impressions counted normally (real billing)
- Real-time metrics available
- Test can be stopped anytime

AFTER TEST:
- Test results summary provided
- Actual CPM vs estimate
- Impression quality score
- Store performance comparison
- Option to: Proceed / Modify / Cancel

TEST MODE RESTRICTIONS:
- Cannot test ACTIVE campaigns
- Cannot test after start_date passed
- Test budget deducted from campaign budget
- Test impressions count toward campaign total
```

### BR-CAMP-PREVIEW-003: Simulation Mode
```
PURPOSE: Estimate campaign performance without spending

SIMULATION PARAMETERS:
- Same targeting as actual campaign
- Uses historical data for predictions
- Does NOT create real impressions
- Does NOT charge budget

SIMULATION OUTPUTS:
{
  estimated_impressions: {
    low: Integer,      // Conservative estimate
    mid: Integer,      // Expected estimate
    high: Integer      // Optimistic estimate
  },
  estimated_spend: {
    low: Decimal,
    mid: Decimal,
    high: Decimal
  },
  estimated_cpm: {
    average: Decimal,
    range: [min, max]
  },
  store_distribution: [
    { store_id, store_name, pct_impressions }
  ],
  hourly_distribution: [
    { hour, pct_impressions, is_peak }
  ],
  confidence_level: "LOW" | "MEDIUM" | "HIGH"
}

CONFIDENCE FACTORS:
- HIGH: Similar campaigns exist, stable historical data
- MEDIUM: Limited historical data, new stores
- LOW: New category, no comparable campaigns
```

---

## A/B Testing Support

### BR-CAMP-AB-001: A/B Test Campaign Structure
```
A/B TEST DEFINITION:
- Parent campaign with 2+ variants
- Variants share: budget, dates, target stores
- Variants differ: content assets, priority weights

ENTITY: CampaignABTest
{
  id: UUID,
  parent_campaign_id: UUID,
  variants: [
    {
      variant_id: "A",
      content_assets: [UUID],
      weight: 50,  // Percentage of impressions
      name: "Control"
    },
    {
      variant_id: "B",
      content_assets: [UUID],
      weight: 50,
      name: "New Creative"
    }
  ],
  test_metric: "ENGAGEMENT" | "COMPLETION_RATE" | "IMPRESSIONS",
  confidence_threshold: 95,  // Percentage for statistical significance
  auto_winner: Boolean,
  status: "RUNNING" | "COMPLETED" | "CANCELLED"
}

CONSTRAINTS:
- Minimum 2 variants, maximum 4 variants
- Variant weights must sum to 100
- Minimum weight per variant: 10%
- Minimum test duration: 7 days
- Minimum impressions for significance: 1,000 per variant
```

### BR-CAMP-AB-002: A/B Test Impression Distribution
```
DISTRIBUTION ALGORITHM:
1. Campaign selected for impression (normal selection)
2. If campaign has A/B test:
   a. Generate random number 0-100
   b. Select variant based on cumulative weights

EXAMPLE:
  Variant A: weight 60%
  Variant B: weight 40%

  Random = 45 → Variant A (0-60)
  Random = 75 → Variant B (60-100)

TRACKING:
- Each impression tagged with variant_id
- Separate metrics per variant
- Same device may see different variants
- No variant persistence per device (pure random)
```

### BR-CAMP-AB-003: A/B Test Metrics & Analysis
```
METRICS TRACKED PER VARIANT:
- Total impressions
- Completion rate (% viewed to end)
- Average view duration
- Unique devices reached
- Unique stores reached
- Cost per impression
- Time of day performance

STATISTICAL ANALYSIS:
- Chi-square test for significant difference
- Confidence interval calculation
- P-value computation
- Sample size adequacy check

WINNER DETERMINATION:
IF auto_winner = true:
  When confidence >= confidence_threshold:
    1. Identify winning variant
    2. Reallocate 100% traffic to winner
    3. Mark test as COMPLETED
    4. Notify advertiser

IF auto_winner = false:
  When confidence >= confidence_threshold:
    1. Notify advertiser
    2. Show recommendation
    3. Advertiser manually selects winner
    4. Test continues until manual action
```

### BR-CAMP-AB-004: A/B Test Edge Cases
```
CASE 1: Insufficient Impressions
  - Test continues past planned end date
  - Notify advertiser of low volume
  - Option to: extend, end without winner, cancel

CASE 2: No Statistical Significance
  - Variants perform similarly
  - Mark as "NO_SIGNIFICANT_DIFFERENCE"
  - Recommend: Run longer or accept any variant

CASE 3: Budget Exhausted During Test
  - Test ends early
  - Report based on available data
  - Confidence_level may be LOW
  - Winner may be inconclusive

CASE 4: Variant Content Rejected
  - Remove variant from rotation
  - Redistribute weight to remaining variants
  - If only 1 variant remains: End test, use remaining

CASE 5: Mid-Test Campaign Pause
  - Test paused (not cancelled)
  - Resume continues from where stopped
  - Statistical model accounts for gap
```

### BR-CAMP-AB-005: A/B Test Reporting
```
REPORT STRUCTURE:
{
  test_id: UUID,
  campaign_id: UUID,
  duration_days: Integer,
  total_impressions: Integer,
  variants: [
    {
      variant_id: "A",
      impressions: Integer,
      completion_rate: Decimal,
      avg_view_duration: Decimal,
      cost: Decimal,
      cpm: Decimal
    },
    ...
  ],
  statistical_analysis: {
    test_type: "chi_square",
    p_value: Decimal,
    confidence_level: Decimal,
    is_significant: Boolean
  },
  recommendation: {
    winner: "A" | "B" | null,
    reasoning: String,
    confidence: "HIGH" | "MEDIUM" | "LOW"
  }
}
```

---

## Business Rules

### Rule 1: Budget Management

#### 1.1 Budget Allocation
```
When: Campaign created
Rule: Budget is held (escrowed) from advertiser wallet

Process:
1. Validate: wallet.available_balance >= campaign.budget
2. Execute:
   wallet.available_balance -= campaign.budget
   wallet.held_balance += campaign.budget
   campaign.remaining_budget = campaign.budget

3. Create transaction record:
   BudgetTransaction {
     type: HOLD,
     amount: campaign.budget,
     balance_before: wallet.available_balance (before deduction),
     balance_after: wallet.available_balance (after deduction),
     description: "Budget hold for campaign: {name}"
   }

Business Rules:
- Budget must be fully available at submission time
- Partial budget allocation NOT allowed
- Budget hold is immediate and atomic
- Failed hold = campaign creation fails
```

#### 1.2 Real-time Budget Tracking
```
When: Each impression recorded
Rule: Deduct cost immediately from campaign budget

Process:
1. Calculate impression cost (see section 5)
2. Validate: campaign.remaining_budget >= impression.cost
3. Execute (ATOMIC):
   campaign.spent += impression.cost
   campaign.remaining_budget -= impression.cost

4. Create transaction:
   BudgetTransaction {
     type: DEBIT,
     amount: impression.cost,
     reference_id: impression.id,
     description: "Impression cost: Device {device_id}"
   }

5. Check threshold:
   IF remaining_budget < (campaign.budget × 0.1):
     Send notification: "Campaign budget 90% depleted"

   IF remaining_budget < (avg_CPM / 1000):
     Trigger auto-pause (see Rule 1.3)

Business Rules:
- Budget updates are real-time (< 500ms)
- Use database transactions for atomicity
- Concurrent impressions handled via row-level locking
- Budget never goes negative (pre-check before recording)
```

#### 1.3 Auto-Pause on Budget Exhaustion
```
Trigger Conditions:
A) remaining_budget < (current_CPM_rate / 1000)
   Reason: Cannot afford next impression

B) remaining_budget <= 0
   Reason: Budget fully spent

Process:
1. Update campaign:
   status = PAUSED
   pause_reason = "BUDGET_EXHAUSTED"
   updated_at = NOW()

2. Stop ad serving:
   - Remove campaign from device playlists
   - Send STOP command to all devices
   - Wait for in-flight impressions (5 min grace)

3. Final reconciliation:
   - Process any in-flight impressions
   - Calculate final totals
   - Release remaining budget (if any due to rounding)

4. Notify advertiser:
   Email & Push: "Campaign paused - budget exhausted"
   Display:
     - Total spent: $X
     - Total impressions: Y
     - Effective CPM: $Z
     - Option to add budget and resume

Grace Period:
- Allow 5 minutes for impressions already playing
- If impression started before pause → still counted
- If impression started after pause → rejected

Business Rules:
- Auto-pause is immediate (no delay)
- Advertiser can add budget to resume
- If end_date not reached → can resume
- If end_date passed → status changes to COMPLETED
```

#### 1.4 Budget Top-Up (Resume Campaign)
```
Actor: Advertiser
Trigger: User adds budget to PAUSED campaign

Input:
  - additional_budget: Decimal

Validation:
✓ additional_budget >= $50 (minimum top-up)
✓ wallet.available_balance >= additional_budget
✓ campaign.status IN [PAUSED, ACTIVE]
✓ campaign.end_date > NOW() (not expired)

Process:
1. Hold additional budget:
   wallet.available_balance -= additional_budget
   wallet.held_balance += additional_budget

2. Update campaign:
   campaign.budget += additional_budget
   campaign.remaining_budget += additional_budget

3. Create transaction:
   BudgetTransaction {
     type: CREDIT,
     amount: additional_budget,
     description: "Budget top-up by advertiser"
   }

4. If status was PAUSED:
   IF pause_reason = "BUDGET_EXHAUSTED":
     status = ACTIVE
     Re-enable ad serving
     Notify advertiser: "Campaign resumed"

Business Rules:
- No limit on number of top-ups
- Top-up extends campaign run-time (not dates)
- Campaign end_date unchanged
- If end_date passed → top-up rejected
```

#### 1.5 Budget Refund (Campaign Completion)
```
Trigger: Campaign ends (COMPLETED or CANCELLED)

Calculation:
refund_amount = campaign.remaining_budget

Process:
IF refund_amount > 0:
  1. Release hold:
     wallet.held_balance -= campaign.budget

  2. Credit unused:
     wallet.available_balance += refund_amount

  3. Create transaction:
     BudgetTransaction {
       type: REFUND,
       amount: refund_amount,
       description: "Unused budget refund"
     }

  4. Notify advertiser:
     "Campaign ended. Refund: ${refund_amount}"

Business Rules:
- Refunds processed immediately at campaign end
- No refund fees or penalties
- Refund rounded to 2 decimal places
- Transaction history preserved for auditing
```

---

### Rule 2: Campaign Priority & Scheduling

#### 2.1 Priority Levels
```
Priority Scale: 1-10 (10 = highest)

Default Priority by Budget:
- Budget < $500:       Priority = 3
- Budget $500-$2000:   Priority = 5
- Budget $2000-$10000: Priority = 7
- Budget > $10000:     Priority = 9

Advertiser can manually adjust priority (±2 levels)

Business Rules:
- Higher priority = more frequent ad slots
- Priority affects slot allocation, not billing rate
- Devices serve ads in priority order
```

#### 2.2 Ad Slot Allocation
```
When: Device requests next ad to play
Input: device_id, current_time

Process:
1. Get eligible campaigns:
   eligible = campaigns WHERE:
     - status = ACTIVE
     - remaining_budget > 0
     - target_stores CONTAINS device.store_id
     - start_date <= NOW() <= end_date

2. Sort by priority (DESC), then created_at (ASC)

3. Select campaign using weighted random:
   weight = campaign.priority × campaign.remaining_budget_ratio

   remaining_budget_ratio = remaining_budget / budget

   Example:
   Campaign A: priority=10, ratio=0.9 → weight=9.0
   Campaign B: priority=7, ratio=0.5 → weight=3.5
   Campaign C: priority=5, ratio=1.0 → weight=5.0

   Total weight = 17.5
   Random selection weighted by these values

4. Return selected campaign to device

Business Rules:
- Campaigns with more budget left get more plays
- High priority campaigns play more frequently
- Randomization prevents impression fatigue
- Same campaign max 2 times per hour per device
```

#### 2.3 Daily Budget Cap
```
When: campaign.daily_cap is set
Rule: Stop serving ads when daily spend reaches cap

Process:
1. Track daily spend (reset at 00:00 UTC):
   daily_spent = SUM(impressions.cost) WHERE:
     - campaign_id = X
     - played_at >= TODAY 00:00:00 UTC

2. Before serving ad:
   IF daily_spent >= campaign.daily_cap:
     Skip this campaign
     Log: "Daily cap reached"

3. At 00:00 UTC:
   Reset daily_spent counter
   Resume serving if status = ACTIVE

Business Rules:
- Daily cap does NOT reduce total budget
- Useful for spreading budget evenly over campaign duration
- Campaign may end with unused budget if daily cap too low
- Daily cap can be adjusted anytime by advertiser
```

---

### Rule 3: Campaign Pausing & Resuming

#### 3.1 Manual Pause by Advertiser
```
Actor: Advertiser
Action: User clicks "Pause Campaign"

Validation:
✓ campaign.status = ACTIVE
✓ User is campaign owner

Process:
1. Update campaign:
   status = PAUSED
   pause_reason = "USER_REQUESTED"
   paused_at = NOW()

2. Stop ad serving:
   - Remove from device playlists
   - Complete in-flight impressions (5 min grace)

3. Notify:
   "Campaign paused successfully"

Business Rules:
- Budget remains held
- Can resume anytime before end_date
- Impressions during grace period still counted
- No penalty or fees
```

#### 3.2 Manual Resume by Advertiser
```
Actor: Advertiser
Action: User clicks "Resume Campaign"

Validation:
✓ campaign.status = PAUSED
✓ campaign.end_date > NOW()
✓ campaign.remaining_budget > 0
✓ User is campaign owner

Process:
1. Update campaign:
   status = ACTIVE
   pause_reason = null
   resumed_at = NOW()

2. Re-distribute content:
   - Push to device playlists
   - Resume impression tracking

3. Notify:
   "Campaign resumed successfully"

Business Rules:
- Cannot resume expired campaigns
- Cannot resume if budget = 0
- Content re-distribution takes up to 5 minutes
```

#### 3.3 Auto-Pause by System
```
Triggers:
A) Budget exhausted (see Rule 1.3)
B) All target devices offline for 24+ hours
C) Campaign flagged for policy violation
D) Advertiser account suspended

Process:
1. Update campaign:
   status = PAUSED
   pause_reason = {trigger}
   auto_paused_at = NOW()

2. Notify advertiser:
   Email: "Campaign auto-paused: {reason}"
   Action required: {resolution steps}

3. Resolution:
   - Budget exhausted: Add budget
   - Devices offline: Wait for reconnection
   - Policy violation: Contact support
   - Account suspended: Resolve account issues

Business Rules:
- Auto-pause is immediate
- Advertiser cannot resume policy/account pauses
- Admin must approve resume for policy violations
```

---

## Billing & Pricing

### Rule 4: CPM Calculation

#### 4.1 Base CPM Rates

**Rate Table by Store Category**:

| Store Category | Peak CPM | Off-Peak CPM | Premium Multiplier |
|----------------|----------|--------------|-------------------|
| Premium Mall | $50.00 | $30.00 | 2.0x |
| Shopping Mall | $40.00 | $25.00 | 1.6x |
| Supermarket | $35.00 | $20.00 | 1.4x |
| Department Store | $30.00 | $18.00 | 1.2x |
| Convenience Store | $25.00 | $15.00 | 1.0x |
| Gas Station | $20.00 | $12.00 | 0.8x |
| Restaurant | $18.00 | $12.00 | 0.7x |
| Other | $15.00 | $10.00 | 0.6x |

**Peak Hours Definition**:
```
Weekdays (Mon-Fri):
  Peak: 11:00-14:00, 17:00-21:00
  Off-Peak: All other hours

Weekends (Sat-Sun):
  Peak: 10:00-22:00
  Off-Peak: All other hours

Holidays:
  Treated as weekend peak hours
```

#### 4.2 CPM Calculation Formula

**Formula**: `Final CPM = Base Rate × Traffic Multiplier × Quality Multiplier`

**Traffic Multiplier Table**:

| Daily Foot Traffic | Multiplier |
|--------------------|------------|
| ≥ 10,000 | 1.5x |
| 5,000 - 9,999 | 1.2x |
| 2,000 - 4,999 | 1.0x |
| < 2,000 | 0.8x |

**Device Quality Multiplier**:

| Device Specs | Multiplier |
|--------------|------------|
| ≥ 55" + 4K resolution | 1.3x |
| ≥ 42" screen | 1.0x |
| < 42" screen | 0.9x |

**Base Rate**: Determined by store category and time of day (peak vs off-peak)

**Example Calculation**:
```
Store: Premium Mall
Foot Traffic: 8,000 daily
Device: 55" 4K screen
Time: Friday 18:30 (peak)

Step 1: Base rate = $50.00 (peak rate for Premium Mall)
Step 2: Traffic multiplier = 1.2 (5000-10000 range)
Step 3: Quality multiplier = 1.3 (55" 4K)
Step 4: Final CPM = $50.00 × 1.2 × 1.3 = $78.00

Cost per impression = $78.00 / 1000 = $0.078
```

#### 4.3 Impression Cost Calculation

**Formula**: `Final Cost = (CPM Rate ÷ 1000) × Duration Discount × Priority Adjustment`

**Duration Discount** (for videos < 15 seconds):
- 15s video = 100% cost
- 10s video = 66.7% cost (10/15)
- 5s video = 33.3% cost (5/15)

**Priority Adjustment**:

| Campaign Priority | Adjustment |
|-------------------|------------|
| High (≥ 9) | +10% premium |
| Normal (4-8) | No adjustment |
| Low (≤ 3) | -10% discount |

**Example**:
```
CPM Rate: $78.00
Content: 10-second video
Priority: 5 (normal)

Step 1: Base cost = $78.00 / 1000 = $0.0780
Step 2: Duration discount = 10/15 = 0.6667
Step 3: Adjusted cost = $0.0780 × 0.6667 = $0.0520
Step 4: Priority adjustment = 1.00 (normal)
Step 5: Final cost = $0.0520
```

---

### Rule 5: Revenue Sharing

#### 5.1 Revenue Split
```
Platform Fee: 20%
Supplier Share: 80%

For each impression:
  impression.cost = $0.0780
  platform_revenue = $0.0780 × 0.20 = $0.0156
  supplier_revenue = $0.0780 × 0.80 = $0.0624
```

#### 5.2 Supplier Payout Process
```
Schedule: Daily at 00:00 UTC
Hold Period: 7 days (anti-fraud)

Process:
1. Calculate daily revenue:
   daily_revenue = SUM(impressions.supplier_revenue) WHERE:
     - store.supplier_id = X
     - played_at BETWEEN (TODAY - 7 days) AND (TODAY - 7 days + 1 day)
     - status = VERIFIED
     - NOT disputed

2. Apply minimum payout threshold:
   IF daily_revenue < $50.00:
     Accumulate for next day
   ELSE:
     Process payout

3. Create payout record:
   SupplierPayout {
     supplier_id: X,
     amount: daily_revenue,
     period_start: TODAY - 7 days,
     period_end: TODAY - 6 days,
     impression_count: Y,
     status: PENDING
   }

4. Transfer funds:
   supplier.wallet.available_balance += daily_revenue

5. Update payout:
   status = COMPLETED
   completed_at = NOW()

6. Notify supplier:
   Email: "Daily payout: ${daily_revenue}"

Business Rules:
- 7-day hold prevents chargeback losses
- Minimum $50 payout reduces transaction fees
- Disputed impressions excluded until resolved
- Supplier can withdraw anytime after payout
```

#### 5.3 Chargeback Handling
```
Trigger: Impression disputed by advertiser

Process:
1. Investigation (Admin):
   - Review proof-of-play
   - Check device logs
   - Validate timestamps

2. If chargeback approved:
   - Refund advertiser: impression.cost
   - Deduct from supplier revenue:
     * If not yet paid: Remove from pending
     * If already paid: Deduct from next payout

3. Update records:
   impression.status = REJECTED
   impression.rejection_reason = "Chargeback approved: {reason}"

4. Notify both parties:
   - Advertiser: "Refund issued: ${cost}"
   - Supplier: "Chargeback: ${cost} - {reason}"

Business Rules:
- Chargeback window: 30 days from impression
- Valid reasons: Proof invalid, device offline, duplicate
- Invalid reasons: "Too expensive", "Changed mind"
- Excessive chargebacks (>5%) flag supplier for review
```

---

## Impression Tracking

### Rule 6: Impression Recording

#### 6.1 Valid Impression Criteria

An impression is considered VALID if ALL conditions met:

```
✓ Campaign status = ACTIVE
✓ Campaign remaining_budget >= impression cost
✓ Device status = ACTIVE
✓ Device belongs to target store
✓ Store NOT in blocked_stores list
✓ Played duration >= 80% of content duration
✓ Proof-of-play provided and valid
✓ No duplicate within 5 minutes
✓ Timestamp within campaign date range
✓ Device heartbeat within last 5 minutes
```

#### 6.2 Impression Submission API

```
POST /api/v1/impressions

Request Body:
{
  "campaign_id": "uuid",
  "device_id": "uuid",
  "content_asset_id": "uuid",
  "played_at": "2026-01-23T14:30:00Z",
  "duration_actual": 28,  // seconds
  "proof": {
    "screenshot_hash": "sha256...",
    "device_signature": "base64...",
    "location": {
      "lat": 10.762622,
      "lng": 106.660172
    }
  }
}

Validation:
1. Authenticate device (JWT or device token)
2. Validate campaign exists and ACTIVE
3. Validate device belongs to target store
4. Check duplicate (campaign_id + device_id + played_at within 5min)
5. Validate duration (>= 80% of expected)
6. Verify proof signature

Response Success (201):
{
  "impression_id": "uuid",
  "status": "VERIFIED",
  "cost": 0.0780,
  "campaign_remaining_budget": 245.32
}

Response Error (400/422):
{
  "error": "INVALID_DURATION",
  "message": "Played duration 20s < required 24s (80% of 30s)",
  "required_duration": 24,
  "actual_duration": 20
}

Error Codes:
- CAMPAIGN_NOT_ACTIVE: Campaign not running
- INSUFFICIENT_BUDGET: Campaign budget exhausted
- DUPLICATE_IMPRESSION: Already recorded within 5min
- INVALID_DURATION: Playback too short
- INVALID_PROOF: Signature verification failed
- DEVICE_NOT_AUTHORIZED: Device not in target stores
- STORE_BLOCKED: Store blocked by competitor rules
```

#### 6.3 Duplicate Prevention

```
Algorithm:
1. Generate dedup key:
   key = SHA256(campaign_id + device_id + floor(played_at / 5min))

2. Check Redis cache:
   IF EXISTS key:
     REJECT with "DUPLICATE_IMPRESSION"
   ELSE:
     SET key = 1 WITH EXPIRY 5 minutes
     PROCEED with recording

Example:
  Impression 1: played_at = 14:30:00
  Impression 2: played_at = 14:31:30

  Both floor to 14:30:00 (5min bucket)
  → Same dedup key → Second rejected

  Impression 3: played_at = 14:35:01
  → Floors to 14:35:00 → Different key → Accepted

Business Rules:
- 5-minute window prevents accidental duplicates
- Redis expiry auto-cleanup (no manual maintenance)
- Legitimate re-play after 5 minutes allowed
```

#### 6.4 Proof-of-Play Verification

```
Required Proof Components:
1. Screenshot hash (SHA256 of frame)
2. Device signature (signed with device private key)
3. Timestamp (from device clock)
4. GPS location (optional but recommended)

Verification Process:
1. Validate signature:
   public_key = device.public_key
   payload = campaign_id + played_at + screenshot_hash
   valid = verify_signature(device_signature, payload, public_key)

   IF NOT valid:
     REJECT with "INVALID_SIGNATURE"

2. Validate timestamp:
   server_time = NOW()
   device_time = parsed(played_at)
   time_diff = abs(server_time - device_time)

   IF time_diff > 5 minutes:
     REJECT with "TIMESTAMP_DRIFT"
     Suggest: "Sync device clock"

3. Validate location (if provided):
   device_location = proof.location
   store_location = store.location
   distance = haversine(device_location, store_location)

   IF distance > 1km:
     FLAG as "SUSPICIOUS_LOCATION"
     Manual review required

4. Store proof:
   Save screenshot_hash for audit
   DO NOT store actual screenshot (privacy + storage)

Business Rules:
- Signature mandatory (prevent spoofing)
- Timestamp drift allowed ±5 minutes (clock skew)
- Location optional but increases trust score
- Suspicious impressions held for 24h review
```

---

### Rule 7: Impression Verification States

```
State Machine:

PENDING → VERIFIED (auto, if all checks pass)
       → REJECTED (auto, if checks fail)
       → UNDER_REVIEW (manual, if suspicious)

UNDER_REVIEW → VERIFIED (admin approves)
             → REJECTED (admin rejects)

Terminal States: VERIFIED, REJECTED
```

**State: PENDING**
```
Initial state when submitted
Duration: < 1 second (automated checks)
Billing: Hold impression cost
Visible: Not yet in advertiser dashboard
```

**State: VERIFIED**
```
All validation passed
Billing: Cost deducted from campaign
Supplier: Revenue credited
Visible: Counts toward campaign stats
Immutable: Cannot be changed (only disputed)
```

**State: REJECTED**
```
Failed validation
Billing: No charge
Supplier: No revenue
Visible: Shown in error logs only
Reason: Stored in rejection_reason field
```

**State: UNDER_REVIEW**
```
Triggered by:
- Location anomaly (GPS far from store)
- High frequency (>12 impressions/hour from device)
- New device (first 10 impressions)
- Large budget campaign (>$10k)

Process:
- Hold billing for 24 hours
- Admin reviews proof-of-play
- Manual approval/rejection

Resolution:
- If approved: State → VERIFIED, process billing
- If rejected: State → REJECTED, notify supplier
```

---

## Competitor Blocking

### Rule 8: Blocking Rules Definition

#### 8.1 Store Blocking Rules

```
Entity: StoreBlockingRule

Attributes:
| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Unique identifier |
| store_id | UUID | Store this rule applies to |
| rule_type | Enum | BRAND / CATEGORY / KEYWORD |
| blocked_value | String | Brand name, category, or keyword |
| reason | String | Why this is blocked (optional) |
| created_by | UUID | Supplier who created rule |
| is_active | Boolean | Can be disabled temporarily |

Example Rules:
1. {
     store_id: "store-123",
     rule_type: "BRAND",
     blocked_value: "Coca-Cola",
     reason: "Exclusive partnership with Pepsi"
   }

2. {
     store_id: "store-456",
     rule_type: "CATEGORY",
     blocked_value: "ALCOHOL",
     reason: "Family-friendly venue"
   }

3. {
     store_id: "store-789",
     rule_type: "KEYWORD",
     blocked_value: "energy drink",
     reason: "No stimulant products"
   }
```

#### 8.2 Blocking Logic

```
Function: is_campaign_blocked(campaign, store)

Input:
  - campaign: Campaign object
  - store: Store object with blocking_rules

Output:
  - blocked: Boolean
  - reason: String (if blocked)

Algorithm:
1. Get all active blocking rules for store:
   rules = StoreBlockingRule.where(
     store_id = store.id,
     is_active = true
   )

2. For each rule, check match:
   FOR EACH rule IN rules:
     CASE rule.rule_type:

       WHEN "BRAND":
         IF campaign.brand_name.lowercase == rule.blocked_value.lowercase:
           RETURN (true, "Brand blocked: " + rule.blocked_value)

       WHEN "CATEGORY":
         IF campaign.category == rule.blocked_value:
           RETURN (true, "Category blocked: " + rule.blocked_value)

       WHEN "KEYWORD":
         keywords = [campaign.name, campaign.description, campaign.brand_name]
         combined = " ".join(keywords).lowercase
         IF rule.blocked_value.lowercase IN combined:
           RETURN (true, "Keyword blocked: " + rule.blocked_value)

3. If no matches:
   RETURN (false, null)

Example:
  Campaign: { brand_name: "Coca-Cola", category: "FOOD_BEVERAGE" }
  Store: Has rule blocking "Coca-Cola"

  Result: (true, "Brand blocked: Coca-Cola")
```

#### 8.3 Blocking Application

**During Campaign Creation (Step 4)**:
```
When advertiser selects target stores:

Process:
1. Get selected stores
2. For each store, check blocking:

   FOR EACH store IN selected_stores:
     (blocked, reason) = is_campaign_blocked(campaign, store)

     IF blocked:
       blocked_stores.append({
         store_id: store.id,
         store_name: store.name,
         reason: reason
       })
     ELSE:
       eligible_stores.append(store)

3. Return results:
   {
     eligible_stores: [...],
     blocked_stores: [...],
     eligible_count: X,
     blocked_count: Y
   }

4. Validate:
   IF eligible_count == 0:
     ERROR: "All selected stores are blocked by competitor rules"
```

**During Campaign Activation**:
```
When distributing content to devices:

Process:
1. Get all devices in target stores
2. Filter out blocked stores:

   eligible_devices = devices.filter(device =>
     device.store_id IN campaign.target_stores
     AND device.store_id NOT IN campaign.blocked_stores
   )

3. Push content only to eligible_devices

Business Rule:
- Blocked stores never receive campaign content
- If store adds blocking rule AFTER campaign active:
  * Immediately remove from that store
  * Notify advertiser of change
```

#### 8.4 Dynamic Blocking Updates

```
Scenario: Supplier adds new blocking rule after campaign started

Trigger: New StoreBlockingRule created

Process:
1. Find affected campaigns:
   affected = campaigns WHERE:
     - status = ACTIVE
     - target_stores CONTAINS rule.store_id
     - Matches blocking rule (check brand/category/keyword)

2. For each affected campaign:
   - Add store to blocked_stores
   - Remove store from eligible stores
   - Stop serving ads to that store
   - Send notification to advertiser:
     "Store {name} now blocks your campaign due to: {reason}"

3. Recalculate estimates:
   - Update estimated impressions
   - Adjust budget utilization forecast

Business Rules:
- Blocking applies immediately (no grace period)
- Advertiser budget not affected
- May result in unused budget (refunded at end)
- Advertiser can remove store or continue with fewer stores
```

#### 8.5 Competitor Blocking Override (Admin)

```
Actor: Super Admin
Use Case: Override blocking rule for specific campaign

Process:
1. Admin reviews blocking:
   - Campaign details
   - Store blocking rule
   - Business justification

2. Create override:
   BlockingRuleOverride {
     rule_id: rule.id,
     campaign_id: campaign.id,
     approved_by: admin.id,
     reason: "Manual override: {justification}",
     expires_at: campaign.end_date
   }

3. Update campaign:
   - Remove store from blocked_stores
   - Add store to eligible_stores
   - Resume ad serving to that store

4. Notify supplier:
   "Admin override: Campaign {name} approved for your store"

Business Rules:
- Override requires admin approval
- Supplier must be notified
- Override expires with campaign
- Logged for audit trail
```

---

## Edge Cases & Error Handling

### Edge Case 1: Device Goes Offline Mid-Campaign

```
Scenario: Device was online when campaign started, goes offline later

Behavior:
- Campaign remains ACTIVE
- Device stops receiving content updates
- No impressions recorded while offline
- No billing during offline period

When device comes back online:
- Device syncs with server
- Downloads latest campaign manifest
- Resumes ad serving
- Impressions resume

Business Rule:
- Offline time does NOT count toward campaign duration
- Advertiser not charged for offline period
- Supplier not penalized for downtime
```

---

### Edge Case 2: Campaign End Date Reached Mid-Day

```
Scenario: Campaign end_date = 2026-02-01 23:59:59
Current time: 2026-02-01 18:30:00

Process:
1. Allow campaign to run until end_date
2. At end_date (23:59:59):
   - Status = COMPLETED
   - Stop serving new ads
   - Grace period: 5 minutes for in-flight impressions

3. At end_date + 5 min:
   - Final reconciliation
   - Calculate totals
   - Refund unused budget
   - Generate final report

Business Rule:
- Campaign runs through entire last day
- No pro-rated partial day billing
- End time is inclusive (runs until 23:59:59)
```

---

### Edge Case 3: All Stores Blocked After Campaign Activation

```
Scenario:
1. Campaign activated with 10 target stores
2. All 10 stores add blocking rules
3. Campaign has 0 eligible stores

Behavior:
1. System detects no eligible stores
2. Status → PAUSED
3. Pause reason: "NO_ELIGIBLE_STORES"
4. Notify advertiser:
   "All target stores have blocked your campaign"
   Options:
   - Add new target stores
   - Contact blocked stores for exemption
   - Cancel campaign (refund remaining budget)

Business Rule:
- Campaign auto-pauses (not cancelled)
- Budget preserved (held, not refunded yet)
- Advertiser can resolve and resume
```

---

### Edge Case 4: Concurrent Impressions Exceed Budget

```
Scenario:
- Campaign remaining_budget = $0.10
- Impression cost = $0.08
- 3 devices submit impressions simultaneously

Race Condition Prevention:
1. Use database row-level locking:
   BEGIN TRANSACTION;
   SELECT remaining_budget FROM campaigns
   WHERE id = X FOR UPDATE;

2. First impression:
   ✓ remaining_budget ($0.10) >= cost ($0.08)
   → Record impression
   → remaining_budget = $0.02
   COMMIT;

3. Second impression:
   ✓ remaining_budget ($0.02) < cost ($0.08)
   → Reject impression
   → Status = PAUSED
   ROLLBACK;

4. Third impression:
   ✗ Campaign status = PAUSED
   → Reject impression

Business Rule:
- Atomic budget checks prevent overspending
- Last impression may be rejected unfairly (acceptable)
- Budget never goes negative
```

---

### Edge Case 5: Device Clock Skew (Future Timestamp)

```
Scenario: Device reports impression with played_at in future

Example:
  Server time: 2026-01-23 14:30:00
  Device time: 2026-01-23 14:37:00 (7 min ahead)

Validation:
IF played_at > server_time + 5 minutes:
  REJECT with "INVALID_TIMESTAMP_FUTURE"
  Log warning: "Device clock {device_id} is ahead by {diff}"
  Suggest: "Sync device clock with NTP"

Business Rule:
- Allow up to 5 minutes future drift (lenient)
- Beyond 5 min → clear clock issue → reject
- Track devices with chronic time issues
- Admin can flag for maintenance
```

---

### Edge Case 6: Impression During Grace Period After Pause

```
Scenario:
1. Campaign auto-paused at 14:30:00 (budget exhausted)
2. Device started playing ad at 14:29:30
3. Device submits impression at 14:30:20 (20 sec later)

Validation:
grace_period = 5 minutes
impression_started_at = played_at - duration_actual

IF impression_started_at < campaign.paused_at:
  → Accept impression (started before pause)
  → May cause negative balance (acceptable)
  → Create BudgetTransaction with note: "Grace period impression"
ELSE:
  → Reject impression

Business Rule:
- Honor impressions that started before pause
- Prevents unfair rejection of legitimate plays
- Small negative balance acceptable (rounded to $0 at completion)
```

---

### Edge Case 7: Campaign Budget Less Than One Impression

```
Scenario: Campaign has $0.03 remaining, impression costs $0.08

Behavior:
1. Before impression submission:
   System detects remaining_budget < min_impression_cost
   → Auto-pause campaign
   → Notify advertiser

2. If impression submitted anyway:
   → Reject with "INSUFFICIENT_BUDGET"
   → Response: {
       error: "INSUFFICIENT_BUDGET",
       remaining_budget: 0.03,
       required_budget: 0.08,
       message: "Please add at least $0.05 to resume"
     }

Business Rule:
- Proactive pause prevents wasted ad plays
- Device not penalized for trying
- Clear messaging helps advertiser understand
```

---

### Edge Case 8: Advertiser Account Suspended Mid-Campaign

```
Scenario: Advertiser account suspended while campaigns are active

Trigger Reasons:
- Payment default (invoice overdue > 60 days)
- Policy violation (serious)
- Fraud investigation
- Legal/regulatory requirement
- KYC verification failure

Immediate Actions:
1. All ACTIVE campaigns → PAUSED
2. All SCHEDULED campaigns → PAUSED
3. pause_reason = "ACCOUNT_SUSPENDED"
4. No new impressions accepted
5. Notify all affected suppliers

Budget Handling:
- Held budget remains held
- No refunds until suspension resolved
- Pending payouts to suppliers processed normally
- Disputed impressions frozen

Resolution Paths:
A) SUSPENSION LIFTED:
   - Campaigns can be manually resumed
   - No automatic resume (advertiser must confirm)
   - 7-day grace period to resume

B) ACCOUNT TERMINATED:
   - All campaigns → CANCELLED
   - Remaining budget refunded (minus outstanding debts)
   - Final settlement within 30 days
```

---

### Edge Case 9: Content Asset Expires Mid-Campaign

```
Scenario: Content asset license expires while campaign is active

Detection:
- System checks content expiration daily at 00:00 UTC
- Alert sent 7 days before expiration
- Alert sent 1 day before expiration

When Asset Expires:
1. If campaign has multiple assets:
   - Remove expired asset from rotation
   - Continue with remaining assets
   - Notify advertiser

2. If campaign has only expired asset:
   - Campaign → PAUSED
   - pause_reason = "CONTENT_EXPIRED"
   - Notify advertiser immediately

Resolution:
- Advertiser uploads new content (requires approval)
- Advertiser extends content license
- Advertiser adds new approved content
- Campaign cancelled if no action in 7 days

Business Rules:
- Expired content never plays
- No billing for failed impressions due to expired content
- Device receives updated playlist within 5 minutes
```

---

### Edge Case 10: Dayparting Schedule Conflict

```
Scenario: Campaign has time-of-day restrictions that conflict with store hours

Example:
- Campaign scheduled: 6 PM - 10 PM only
- Store hours: 9 AM - 6 PM (closes at 6 PM)
- Result: Zero eligible play time

Detection:
- At campaign submission: Warning displayed
- System calculates effective play hours per store

Behavior:
1. Warning shown but campaign allowed
2. Stores with zero overlap flagged
3. Estimated impressions adjusted
4. Advertiser can remove conflicting stores

If All Stores Conflict:
- Campaign submission blocked
- Error: "No stores available during scheduled hours"
- Suggest: Adjust schedule or target different stores

Business Rules:
- Advertiser responsible for schedule/store alignment
- System provides warnings but doesn't auto-fix
- Zero-overlap stores contribute $0 to campaign
```

---

### Edge Case 11: Currency/Price Update Mid-Campaign

```
Scenario: Platform updates CPM rates while campaigns are active

Rate Change Policy:
- CPM rates may change quarterly (announced 30 days prior)
- New rates apply to new impressions only
- Already-recorded impressions not affected

Process:
1. Announcement: 30 days before rate change
2. Active campaigns: Notified of impact
3. Estimate recalculation: Show new projected cost
4. On effective date: New rates for new impressions

Advertiser Options:
- Accept new rates (default, no action needed)
- Pause campaign before rate change
- Adjust budget to accommodate new rates

Budget Protection:
- If new rates would exhaust budget faster:
  * Notify advertiser
  * Suggest budget increase
  * No auto-budget-add

Business Rules:
- No retroactive rate changes
- 30-day minimum notice for rate changes
- Rate changes apply equally to all advertisers
- Special contracts may have rate locks
```

---

### Edge Case 12: Network Partition (Delayed Impression Submission)

```
Scenario: Device plays ad but network outage delays submission

Example Timeline:
- 14:00:00 - Ad plays on device (network down)
- 14:00:30 - Impression queued locally on device
- 14:15:00 - Network restored
- 14:15:05 - Queued impression submitted
- 14:15:06 - Server receives impression with played_at = 14:00:30

Validation:
1. Check played_at vs received_at:
   delay = received_at - played_at

2. Accept if:
   - delay <= 4 hours
   - Campaign was ACTIVE at played_at
   - Budget was available at played_at

3. Reject if:
   - delay > 4 hours
   - Campaign was PAUSED at played_at
   - Budget was exhausted at played_at

Billing:
- Use CPM rate effective at played_at
- Use budget state at played_at (snapshot)
- Log as "delayed_submission"

Device Requirements:
- Device must queue impressions locally
- Queue capacity: 1000 impressions
- Queue persists across reboots
- Submit in FIFO order when online

Business Rules:
- 4-hour maximum delay window
- Proof-of-play timestamp must match played_at
- Suppliers still earn revenue for valid delayed impressions
```

---

### Edge Case 13: Duplicate Campaign Detection

```
Scenario: Advertiser creates campaign very similar to existing one

Detection Criteria (any 3 of 5):
- Same brand_name
- Same category
- 80%+ overlap in target_stores
- Same content_assets
- Overlapping dates

System Response:
1. Warning displayed (not blocking)
2. Message: "Similar campaign detected: {campaign_name}"
3. Show comparison table
4. Require confirmation to proceed

Fraud Prevention:
- If advertiser creates >5 near-duplicate campaigns:
  * Flag for review
  * May indicate budget manipulation attempt
  * Admin notification

Legitimate Use Cases:
- A/B testing with minor variations
- Regional campaigns with similar content
- Seasonal campaign renewals

Business Rules:
- Duplicates allowed (not blocked)
- Warning must be acknowledged
- Audit log tracks duplicate creation
```

---

### Edge Case 14: Campaign Spanning Time Zone Changes (DST)

```
Scenario: Campaign active during daylight saving time transition

Example (US):
- Campaign: March 1 - April 1, 2026
- DST starts: March 8, 2026 (clocks forward 1 hour)
- Peak hours: 5 PM - 9 PM

Impact:
- March 7: Peak = 17:00-21:00 EST
- March 8: Peak = 17:00-21:00 EDT (jumped 1 hour)
- Campaign continues normally (no gap)

Handling:
- All times stored in UTC
- Peak hours defined in store's local time zone
- DST handled by time zone database
- No manual adjustment needed

Edge Case: Lost/Gained Hour
- Spring forward: 2:00 AM → 3:00 AM
  * If impression played at "2:30 AM": Doesn't exist
  * Device should report UTC time

- Fall back: 2:00 AM → 1:00 AM (repeated)
  * Impressions at 1:30 AM may occur twice
  * UTC timestamps distinguish them

Business Rules:
- Always use UTC internally
- Convert to local time only for display
- Peak hours based on local wall clock time
- No billing adjustments for DST transitions
```

---

### Edge Case 15: Budget Hold Expiration

```
Scenario: Campaign submitted but never approved (stuck in PENDING_APPROVAL)

Hold Duration Limits:
- Maximum hold period: 30 days
- After 30 days: Auto-release hold

Process at Day 25:
- Send warning: "Campaign pending approval for 25 days"
- Remind advertiser to contact support
- Remind admin to review

Process at Day 30:
1. Campaign status → EXPIRED (new terminal state)
2. Budget hold released:
   wallet.held_balance -= campaign.budget
   wallet.available_balance += campaign.budget
3. Notification to advertiser:
   "Campaign expired due to prolonged pending status"
4. Alert to admin: "Expired campaign - review queue"

Advertiser Options:
- Resubmit as new campaign
- Contact support to expedite future reviews

Business Rules:
- 30-day maximum hold for pending campaigns
- Auto-release protects advertiser funds
- No penalty for expiration
- Resubmission restarts the process
```

---

### Edge Case 16: Impression Backfill After Device Recovery

```
Scenario: Device was offline, comes back online with queued impressions

Backfill Rules:
- Maximum backfill window: 4 hours
- Impressions older than 4 hours: Rejected
- Impressions within window: Processed normally

Validation Order:
1. Check timestamp age (must be within 4 hours)
2. Check campaign was ACTIVE at played_at
3. Check budget was available at played_at
4. Check device was legitimate at played_at
5. Validate proof-of-play

Budget Snapshot:
- System maintains hourly budget snapshots
- Backfilled impression uses historical snapshot
- May result in slight over-budget (accepted)

Supplier Revenue:
- Valid backfilled impressions earn revenue
- Revenue credited with 7-day hold (normal)
- Flagged as "backfill" in reports

Business Rules:
- 4-hour window balances accuracy vs fairness
- Beyond 4 hours: Too much risk of manipulation
- Backfill impressions count toward daily caps
- No preferential treatment for backfill
```

---

### Edge Case 17: Campaign with Zero Impressions

```
Scenario: Campaign completed but delivered zero impressions

Possible Causes:
- All target stores offline entire duration
- All devices failed content sync
- Competitor blocking applied after activation
- Technical failure on platform side

Detection:
- Campaign completes with spent = $0
- Alert triggered for admin review

Investigation:
1. Check device uptime during campaign
2. Check content distribution logs
3. Check blocking rules history
4. Check for platform incidents

Resolution by Cause:

A) STORE/DEVICE ISSUES:
   - Full budget refund
   - Offer free campaign extension
   - No platform fault

B) BLOCKING RULE CHANGES:
   - Full budget refund
   - Notify advertiser of blocking
   - No SLA violation

C) PLATFORM FAULT:
   - Full budget refund
   - SLA credit applied
   - Post-mortem required

D) FORCE MAJEURE:
   - Full budget refund
   - No credits/penalties
   - Documentation for records

Business Rules:
- Zero-impression campaigns always investigated
- Default to full refund
- Protect advertiser from platform failures
```

---

## Validation Rules

### Campaign Validation Matrix

| Field | Rule | Error Message |
|-------|------|---------------|
| name | Length 3-100 | "Name must be 3-100 characters" |
| name | Unique per advertiser | "Campaign name already exists" |
| brand_name | Length 2-50 | "Brand name must be 2-50 characters" |
| brand_name | Not empty | "Brand name required for competitor blocking" |
| budget | >= 100.00 | "Minimum budget is $100.00" |
| budget | <= 1000000.00 | "Maximum budget is $1,000,000.00" |
| budget | Max 2 decimals | "Budget must have max 2 decimal places" |
| start_date | >= NOW + 24h | "Start date must be at least 24 hours in future" |
| start_date | < end_date | "Start date must be before end date" |
| end_date | <= start_date + 365d | "Campaign duration cannot exceed 1 year" |
| target_stores | Length >= 1 | "At least 1 target store required" |
| target_stores | Length <= 1000 | "Maximum 1000 target stores allowed" |
| content_assets | Length >= 1 | "At least 1 content asset required" |
| content_assets | Length <= 10 | "Maximum 10 content assets allowed" |
| daily_cap | >= 10.00 if set | "Minimum daily cap is $10.00" |
| daily_cap | <= budget if set | "Daily cap cannot exceed total budget" |

---

## Calculations & Formulas

### Formula Summary

#### 1. Impression Cost
```
impression_cost = (CPM_rate / 1000)
                  × duration_adjustment
                  × priority_premium
                  × quality_multiplier

Where:
- CPM_rate: Based on store category + time + traffic
- duration_adjustment: 1.0 for >=15s, else (actual/15)
- priority_premium: 0.90-1.10 based on campaign priority
- quality_multiplier: 0.9-1.3 based on device specs
```

#### 2. Campaign Estimated Cost
```
estimated_cost = estimated_impressions × avg_CPM / 1000

estimated_impressions = SUM(
  store.daily_foot_traffic
  × store.device_count
  × store.avg_dwell_time_minutes / 60
  × campaign.duration_days
) × 0.7  // Conservative estimate factor
```

#### 3. Revenue Share
```
platform_revenue = impression_cost × 0.20
supplier_revenue = impression_cost × 0.80
```

#### 4. Remaining Budget
```
remaining_budget = campaign.budget - campaign.spent

// Alternative (for audit):
remaining_budget = campaign.budget
                   - SUM(impressions.cost WHERE status = VERIFIED)
```

#### 5. Campaign Completion Percentage
```
completion_pct = (campaign.spent / campaign.budget) × 100

// Time-based completion:
time_completion_pct = (
  (NOW() - start_date) / (end_date - start_date)
) × 100

// Overall health:
IF completion_pct > time_completion_pct + 20:
  status = "BURNING_TOO_FAST"
ELSE IF completion_pct < time_completion_pct - 20:
  status = "UNDERDELIVERING"
ELSE:
  status = "ON_TRACK"
```

#### 6. Effective CPM (Campaign Performance)
```
effective_CPM = (campaign.spent / total_impressions) × 1000

// Compare to estimated:
CPM_variance = (effective_CPM - estimated_CPM) / estimated_CPM × 100

Example:
  Spent: $500
  Impressions: 10,000
  Effective CPM: ($500 / 10,000) × 1000 = $50.00

  If estimated CPM was $45:
  Variance: (50 - 45) / 45 × 100 = +11.1% (over estimate)
```

---

## Appendix: Business Rule Change Log

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-01-23 | Initial document creation | Product Team |

---

## Appendix: Glossary

**Campaign**: An advertising initiative with budget, target stores, and content
**Impression**: Single verified playback of ad content on a device
**CPM**: Cost Per Mille (cost per 1000 impressions)
**Peak Hours**: High-traffic time periods with premium pricing
**Proof-of-Play**: Cryptographic evidence that ad was actually displayed
**Blocking Rule**: Supplier-defined rule to prevent competitor ads
**Grace Period**: Time window to complete in-flight operations
**Hold**: Temporary reservation of budget (escrowed)

---

**Document Status**: Ready for review
**Next Steps**:
1. Review with stakeholders
2. Developer technical review
3. QA test case creation
4. Implementation planning
