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
4. [Business Rules](#business-rules)
5. [Billing & Pricing](#billing--pricing)
6. [Impression Tracking](#impression-tracking)
7. [Competitor Blocking](#competitor-blocking)
8. [Edge Cases & Error Handling](#edge-cases--error-handling)
9. [Validation Rules](#validation-rules)
10. [Calculations & Formulas](#calculations--formulas)

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

```python
def calculate_cpm(store, timestamp):
    # 1. Get base rate
    base_rate = get_base_rate(store.category, timestamp)

    # 2. Apply foot traffic multiplier
    if store.daily_foot_traffic >= 10000:
        traffic_multiplier = 1.5
    elif store.daily_foot_traffic >= 5000:
        traffic_multiplier = 1.2
    elif store.daily_foot_traffic >= 2000:
        traffic_multiplier = 1.0
    else:
        traffic_multiplier = 0.8

    # 3. Apply device quality multiplier
    if device.screen_size >= 55 and device.resolution == "4K":
        quality_multiplier = 1.3
    elif device.screen_size >= 42:
        quality_multiplier = 1.0
    else:
        quality_multiplier = 0.9

    # 4. Calculate final CPM
    final_cpm = base_rate × traffic_multiplier × quality_multiplier

    # 5. Round to 2 decimals
    return round(final_cpm, 2)

def get_base_rate(category, timestamp):
    is_peak = is_peak_hour(timestamp)
    rate_table = CATEGORY_RATES[category]
    return rate_table["peak"] if is_peak else rate_table["off_peak"]
```

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

```python
def calculate_impression_cost(campaign, device, store, timestamp):
    # 1. Get CPM rate
    cpm_rate = calculate_cpm(store, timestamp)

    # 2. Calculate base cost
    base_cost = cpm_rate / 1000

    # 3. Apply duration adjustment (if video < 15s)
    if content.type == "VIDEO" and content.duration < 15:
        duration_discount = content.duration / 15
        base_cost = base_cost × duration_discount

    # 4. Apply campaign priority adjustment (±10%)
    if campaign.priority >= 9:
        priority_premium = 1.10
    elif campaign.priority <= 3:
        priority_premium = 0.90
    else:
        priority_premium = 1.00

    final_cost = base_cost × priority_premium

    # 5. Round to 4 decimals
    return round(final_cost, 4)
```

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
