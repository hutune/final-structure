# Impression Recording Module - Business Rules Document

**Version**: 1.0
**Date**: 2026-01-23
**Status**: Draft for Review
**Owner**: Product Team

---

## Table of Contents

1. [Overview](#overview)
2. [Domain Entities](#domain-entities)
3. [Impression Lifecycle](#impression-lifecycle)
4. [Business Rules](#business-rules)
5. [Proof-of-Play Specification](#proof-of-play-specification)
6. [Verification & Validation](#verification--validation)
7. [Fraud Detection](#fraud-detection)
8. [Quality Scoring](#quality-scoring)
9. [Dispute & Chargeback](#dispute--chargeback)
10. [Edge Cases & Error Handling](#edge-cases--error-handling)
11. [Validation Rules](#validation-rules)
12. [Calculations & Formulas](#calculations--formulas)

---

## Overview

### Purpose
This document expands on impression recording business rules from the Campaign module, providing comprehensive details on verification, fraud detection, quality scoring, and dispute resolution.

### Scope
- Impression recording and validation
- Proof-of-play requirements
- Verification state machine
- Fraud detection algorithms
- Quality scoring system
- Dispute and chargeback processes

### Out of Scope
- Campaign management (see Campaign module)
- Device management (see Device module)
- Billing calculations (covered in Campaign module)

### Key Concepts
- **Impression**: Single verified playback of ad content
- **Proof-of-Play**: Evidence that ad was actually displayed
- **Verification**: Process of validating impression authenticity
- **Quality Score**: Metric indicating impression value/reliability
- **Dispute**: Challenge to impression validity by advertiser

---

## Domain Entities

### 1. Impression (Expanded)

**Definition**: A verified playback event of advertising content on a device.

**Extended Attributes** (beyond Campaign module):

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `verification_status` | Enum | Yes | PENDING/VERIFIED/REJECTED/UNDER_REVIEW/DISPUTED |
| `verification_timestamp` | DateTime | No | When verification completed |
| `verification_method` | Enum | Yes | AUTOMATIC/MANUAL/HYBRID |
| `quality_score` | Integer | Yes | 0-100, computed quality metric |
| `fraud_flags` | JSON | Yes | Array of fraud detection flags |
| `fraud_score` | Integer | Yes | 0-100 (0=clean, 100=definitely fraud) |
| `proof_screenshot_url` | String(500) | No | S3 URL to screenshot (temp, 30 days) |
| `proof_screenshot_hash` | String(64) | Yes | SHA256 hash of screenshot |
| `proof_device_signature` | Text | Yes | RSA signature from device |
| `proof_gps_lat` | Decimal(10,8) | No | GPS latitude at play time |
| `proof_gps_lng` | Decimal(11,8) | No | GPS longitude at play time |
| `proof_gps_accuracy` | Integer | No | GPS accuracy in meters |
| `attention_score` | Integer | No | 0-100 if using attention detection AI |
| `viewability_score` | Integer | Yes | 0-100 percentage of screen visible |
| `audio_enabled` | Boolean | Yes | Was audio playing |
| `environment_brightness` | Integer | No | Ambient light sensor reading |
| `distance_from_store` | Integer | No | Meters from registered store location |
| `time_drift_seconds` | Integer | Yes | Difference between device and server time |
| `verification_notes` | Text | No | Admin notes if manually reviewed |
| `rejected_reason` | String(200) | No | Why verification failed |
| `dispute_id` | UUID | No | Link to dispute if challenged |
| `chargeback_at` | DateTime | No | When chargeback issued |
| `chargeback_reason` | String(200) | No | Reason for chargeback |

---

### 2. ImpressionVerificationLog

**Definition**: Detailed log of verification process for auditability.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `impression_id` | UUID | Yes | Link to impression |
| `step` | String(50) | Yes | Verification step name |
| `status` | Enum | Yes | PASS/FAIL/SKIP/WARN |
| `check_type` | Enum | Yes | SIGNATURE/TIMESTAMP/DURATION/LOCATION/DUPLICATE |
| `expected_value` | Text | No | What was expected |
| `actual_value` | Text | No | What was found |
| `result_message` | Text | Yes | Human-readable result |
| `severity` | Enum | Yes | INFO/WARNING/ERROR/CRITICAL |
| `processing_time_ms` | Integer | Yes | Time to complete this check |
| `created_at` | DateTime | Yes | Immutable |

---

### 3. ImpressionQualityMetrics

**Definition**: Detailed quality metrics for impression scoring.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `impression_id` | UUID | Yes | Link to impression |
| `viewability_score` | Integer | Yes | 0-100% content visible |
| `completion_rate` | Decimal(5,2) | Yes | % of content played |
| `attention_score` | Integer | No | AI-detected attention (0-100) |
| `audio_enabled` | Boolean | Yes | Was audio on |
| `screen_brightness` | Integer | No | Screen brightness % |
| `environment_brightness` | Integer | No | Ambient light level |
| `device_orientation_correct` | Boolean | Yes | Content matches screen orientation |
| `network_quality` | Enum | Yes | EXCELLENT/GOOD/FAIR/POOR |
| `playback_smoothness` | Integer | No | 0-100, no buffering/stuttering |
| `timestamp_accuracy` | Integer | Yes | Time drift in seconds |
| `location_accuracy` | Integer | No | GPS accuracy in meters |
| `proof_quality` | Integer | Yes | 0-100, proof completeness |
| `overall_quality_score` | Integer | Yes | Computed final score (0-100) |
| `quality_tier` | Enum | Yes | PREMIUM/STANDARD/BASIC/POOR |
| `created_at` | DateTime | Yes | Immutable |

---

### 4. ImpressionDispute

**Definition**: Advertiser challenge to impression validity.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `impression_id` | UUID | Yes | Disputed impression |
| `campaign_id` | UUID | Yes | Related campaign |
| `advertiser_id` | UUID | Yes | Who filed dispute |
| `dispute_type` | Enum | Yes | See [Dispute Types](#dispute-types) |
| `reason` | Text | Yes | Detailed explanation |
| `evidence` | JSON | No | Supporting evidence URLs |
| `status` | Enum | Yes | PENDING/INVESTIGATING/RESOLVED/REJECTED |
| `priority` | Enum | Yes | LOW/NORMAL/HIGH/URGENT |
| `assigned_to` | UUID | No | Admin investigating |
| `investigation_notes` | Text | No | Admin findings |
| `resolution` | Enum | No | CHARGEBACK_APPROVED/CHARGEBACK_DENIED/PARTIAL_REFUND |
| `refund_amount` | Decimal(10,4) | No | Amount refunded |
| `supplier_penalty` | Decimal(10,4) | No | Amount deducted from supplier |
| `filed_at` | DateTime | Yes | When dispute opened |
| `resolved_at` | DateTime | No | When dispute closed |
| `resolution_time_hours` | Integer | No | Computed: resolved_at - filed_at |

#### Dispute Types
```
- INVALID_PROOF: Screenshot/signature invalid
- DEVICE_OFFLINE: Device was offline at reported time
- WRONG_LOCATION: Device far from store location
- DUPLICATE: Same impression reported multiple times
- CONTENT_MISMATCH: Wrong content shown
- TIME_MANIPULATION: Timestamp appears manipulated
- QUALITY_ISSUE: Poor playback quality
- OTHER: Other reason (requires detailed explanation)
```

---

### 5. FraudDetectionRule

**Definition**: Configurable fraud detection rule.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `rule_name` | String(100) | Yes | Human-readable name |
| `rule_type` | Enum | Yes | FREQUENCY/LOCATION/TIMING/PATTERN/SIGNATURE |
| `description` | Text | Yes | What this rule detects |
| `severity` | Enum | Yes | LOW/MEDIUM/HIGH/CRITICAL |
| `threshold_value` | Decimal(10,2) | Yes | Trigger threshold |
| `time_window_minutes` | Integer | No | Rolling time window |
| `action_on_trigger` | Enum | Yes | LOG/FLAG/HOLD/REJECT/SUSPEND |
| `is_active` | Boolean | Yes | Can be disabled |
| `false_positive_rate` | Decimal(5,2) | No | Monitored metric |
| `true_positive_rate` | Decimal(5,2) | No | Monitored metric |
| `triggered_count` | Integer | Yes | Times this rule triggered |
| `last_triggered_at` | DateTime | No | Most recent trigger |
| `created_by` | UUID | Yes | Admin who created |
| `created_at` | DateTime | Yes | Immutable |

---

## Impression Lifecycle

### Verification State Machine

```
                    [Device Submits]
                          ↓
                    ┌─────────┐
                    │ PENDING │ (Initial state)
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        ↓                ↓                ↓
   [All checks     [Suspicious]    [Critical
    pass]                              failure]
        ↓                ↓                ↓
   ┌─────────┐    ┌──────────────┐  ┌──────────┐
   │VERIFIED │    │ UNDER_REVIEW │  │ REJECTED │
   └────┬────┘    └──────┬───────┘  └──────────┘
        │                │
        │         [Admin decision]
        │                │
        │         ┌──────┴──────┐
        │         ↓             ↓
        │    ┌─────────┐   ┌──────────┐
        │    │VERIFIED │   │ REJECTED │
        │    └─────────┘   └──────────┘
        │
 [Advertiser
  disputes]
        ↓
   ┌─────────┐
   │DISPUTED │
   └────┬────┘
        │
 [Admin resolves]
        │
   ┌────┴─────┐
   ↓          ↓
[Upheld]  [Overturned]
   │          │
   ↓          ↓
┌─────────┐ ┌──────────┐
│VERIFIED │ │ REJECTED │
└─────────┘ └──────────┘
             +chargeback
```

### State Descriptions

**PENDING** (Initial):
- Duration: < 5 seconds (automated checks)
- Automated validation in progress
- Not visible in advertiser dashboard yet
- No billing impact yet

**VERIFIED** (Terminal - Success):
- All validation checks passed
- Billing confirmed (cost deducted)
- Supplier revenue credited
- Counts toward campaign metrics
- Can still be disputed (30-day window)

**REJECTED** (Terminal - Failure):
- Failed validation checks
- No billing (cost not charged)
- No supplier revenue
- Logged for device troubleshooting
- Reason stored in rejected_reason field

**UNDER_REVIEW** (Intermediate):
- Duration: Up to 24 hours
- Triggered by suspicious patterns
- Manual admin review required
- Billing held temporarily
- Device notified of review status

**DISPUTED** (Post-verification):
- Advertiser challenged impression
- Investigation in progress
- Billing held/reversed pending resolution
- Admin reviews evidence
- Resolution: Uphold (VERIFIED) or Overturn (REJECTED + chargeback)

---

## Business Rules

### Rule 1: Impression Recording Criteria

#### 1.1 Minimum Playback Duration

```
Rule: Impression only recorded if content played ≥ 80% of duration

Formula:
minimum_duration = content.duration × 0.80

Validation:
IF impression.duration_actual >= minimum_duration:
  Record impression
ELSE:
  Reject with "INSUFFICIENT_DURATION"

Example:
  Content duration: 30 seconds
  Minimum required: 30 × 0.80 = 24 seconds

  Case 1: Played 25 seconds → ✓ Record impression
  Case 2: Played 20 seconds → ✗ Reject (too short)
  Case 3: Played 30 seconds → ✓ Record impression (100%)

Business Rules:
- 80% threshold prevents accidental/incomplete plays
- Partial impressions not counted
- Device must report actual duration
- Server validates duration accuracy
```

#### 1.2 Timestamp Validity Window

```
Rule: Impression timestamp must be within reasonable bounds

Server-side validation:
played_at = impression.played_at
server_time = NOW()

time_diff = abs(played_at - server_time)

IF time_diff > 10 minutes:
  REJECT with "TIMESTAMP_OUT_OF_BOUNDS"
  LOG warning: "Device clock {time_diff} off from server"

IF played_at > server_time + 5 minutes:
  REJECT with "TIMESTAMP_IN_FUTURE"
  LOG warning: "Device clock ahead by {time_diff}"

IF played_at < campaign.start_date:
  REJECT with "BEFORE_CAMPAIGN_START"

IF played_at > campaign.end_date:
  REJECT with "AFTER_CAMPAIGN_END"

Business Rules:
- 10-minute tolerance for clock skew
- Future timestamps rejected (clock ahead)
- Must fall within campaign date range
- Persistent clock issues flag device for maintenance
```

#### 1.3 Device Status Requirements

```
Rule: Device must be in valid state to record impressions

Validation:
device = Device.find(impression.device_id)

Required conditions:
✓ device.status = ACTIVE
✓ device.last_heartbeat_at > NOW() - 10 minutes
✓ device.store_id = impression.store_id
✓ impression.store_id NOT IN campaign.blocked_stores

Rejections:
IF device.status != ACTIVE:
  REJECT with "DEVICE_NOT_ACTIVE"

IF device.last_heartbeat_at < NOW() - 10 minutes:
  REJECT with "DEVICE_OFFLINE"
  // Device should be marked offline

IF device.store_id != impression.store_id:
  REJECT with "STORE_MISMATCH"
  FLAG for fraud investigation

IF impression.store_id IN campaign.blocked_stores:
  REJECT with "STORE_BLOCKED"
  // Competitor blocking rule violation

Business Rules:
- Only active devices can record impressions
- Device must have recent heartbeat (< 10 min)
- Store association must match
- Blocked stores cannot generate impressions
- Violations logged for audit
```

#### 1.4 Campaign Status Requirements

```
Rule: Campaign must be active and have sufficient budget

Validation:
campaign = Campaign.find(impression.campaign_id)

Required conditions:
✓ campaign.status = ACTIVE
✓ campaign.remaining_budget >= impression.cost
✓ campaign.start_date <= impression.played_at <= campaign.end_date

Rejections:
IF campaign.status != ACTIVE:
  REJECT with "CAMPAIGN_NOT_ACTIVE"
  Device should stop serving this campaign

IF campaign.remaining_budget < impression.cost:
  REJECT with "INSUFFICIENT_BUDGET"
  Trigger campaign auto-pause

IF impression.played_at < campaign.start_date:
  REJECT with "BEFORE_CAMPAIGN_START"

IF impression.played_at > campaign.end_date:
  REJECT with "CAMPAIGN_ENDED"
  Device should remove from playlist

Business Rules:
- Only active campaigns count impressions
- Budget checked before recording (prevent overdraft)
- Timestamps must fall within campaign period
- Budget exhaustion triggers auto-pause
- Device playlist should be up-to-date
```

---

### Rule 2: Duplicate Detection

#### 2.1 Short-term Duplicate (5-minute window)

```
Algorithm: Same campaign + device + 5-minute bucket

Implementation:
dedup_key = generate_dedup_key(
  campaign_id: impression.campaign_id,
  device_id: impression.device_id,
  time_bucket: floor(impression.played_at / 5 minutes)
)

Example:
  Campaign: "abc-123"
  Device: "device-456"
  Played at: 14:32:30

  Time bucket: floor(14:32:30 / 5 min) = 14:30:00
  Dedup key: SHA256("abc-123:device-456:14:30:00")

Check Redis:
IF EXISTS(dedup_key):
  REJECT with "DUPLICATE_IMPRESSION"
  LOG: "Duplicate within 5 minutes"
ELSE:
  SET dedup_key = 1
  EXPIRE dedup_key = 300 seconds (5 minutes)
  PROCEED with verification

Business Rules:
- 5-minute window prevents rapid duplicates
- Same campaign + device + time bucket = duplicate
- Redis cache auto-expires after 5 minutes
- Legitimate re-play after 5 min allowed
- Multiple campaigns can play within 5 min (different dedup keys)

Example Scenarios:
Scenario 1: Same ad twice in 3 minutes
  Impression 1: 14:30:00 → Recorded
  Impression 2: 14:33:00 → REJECTED (same bucket)

Scenario 2: Same ad after 6 minutes
  Impression 1: 14:30:00 → Recorded
  Impression 2: 14:36:00 → Recorded (different bucket: 14:35:00)

Scenario 3: Different campaigns within 5 min
  Campaign A at 14:30:00 → Recorded
  Campaign B at 14:32:00 → Recorded (different dedup keys)
```

#### 2.2 Medium-term Duplicate (1-hour window)

```
Algorithm: Same campaign + device + content + 1-hour window

Purpose: Detect abnormal replay frequency

Check database:
recent_impressions = Impressions.where(
  campaign_id: impression.campaign_id,
  device_id: impression.device_id,
  content_asset_id: impression.content_asset_id,
  played_at: [NOW() - 1 hour, NOW()]
).count

max_expected = device.advertising_slots_per_hour / campaign_count_on_device

IF recent_impressions >= max_expected × 1.5:
  FLAG as "HIGH_FREQUENCY"
  IF recent_impressions >= max_expected × 2.0:
    HOLD for review
    LOG: "Abnormal replay frequency"

Example:
  Device has 12 slots/hour
  Device serves 3 campaigns
  Expected per campaign: 12 / 3 = 4 impressions/hour

  Actual: 6 impressions (same campaign in 1 hour)
  → 6 >= 4 × 1.5 = FLAG
  → 6 < 4 × 2.0 = Allow but flag

  Actual: 9 impressions
  → 9 >= 4 × 2.0 = HOLD for review

Business Rules:
- Track replay frequency per campaign per device
- Allow up to 1.5× expected frequency (variance)
- Hold impressions beyond 2× expected (likely fraud)
- Flagged impressions still recorded but marked
- Held impressions require manual review
```

#### 2.3 Long-term Pattern Detection (24-hour window)

```
Algorithm: Detect suspiciously consistent patterns

Analysis:
daily_impressions = Impressions.where(
  device_id: impression.device_id,
  played_at: [NOW() - 24 hours, NOW()]
)

Patterns to detect:

1. Exact timing pattern:
   timestamps = daily_impressions.pluck(:played_at)
   intervals = calculate_intervals(timestamps)

   IF all_intervals_equal(intervals):
     FLAG as "ROBOTIC_PATTERN"
     // Too perfect to be random

2. Suspiciously round timestamps:
   round_timestamps = timestamps.select { |t|
     t.seconds == 0 AND t.minutes % 5 == 0
   }

   IF round_timestamps.count / timestamps.count > 0.8:
     FLAG as "SUSPICIOUS_TIMING"
     // 80% of impressions at exact 5-min marks

3. Overnight activity anomaly:
   IF store.operating_hours.closed_at < impression.played_at:
     FLAG as "AFTER_HOURS_IMPRESSION"
     // Playing ads when store closed

Business Rules:
- Machine-like patterns indicate automation/fraud
- Natural playback has variance
- Round timestamps suspicious (manual submission?)
- After-hours impressions require explanation
- Patterns don't auto-reject, but flag for review
```

---

## Proof-of-Play Specification

### Rule 3: Proof Requirements

#### 3.1 Screenshot Capture

```
Purpose: Visual proof that content was displayed

Requirements:
- Capture random frame between 40%-60% of playback
- Resolution: Minimum 800x600 (lower res acceptable for proof)
- Format: JPEG (compressed, ~50-200KB)
- Quality: 70% JPEG quality sufficient
- Timestamp: Embedded in EXIF data

Process:
1. Device selects random point:
   capture_at = random(40%, 60%) of content.duration

   Example:
   30-second video → capture between 12s and 18s

2. Capture screenshot:
   screenshot = capture_screen(at: capture_at)

3. Compute hash:
   screenshot_hash = SHA256(screenshot)

4. Store temporarily (device side):
   save_to_temp(screenshot) // For potential upload

5. Include hash in impression:
   impression.proof_screenshot_hash = screenshot_hash

6. Conditional upload:
   IF flagged_for_review OR random(5%):
     upload_to_s3(screenshot)
     impression.proof_screenshot_url = s3_url

Business Rules:
- Screenshot required for all impressions
- Hash always sent, file uploaded selectively (5% random + flagged)
- Screenshot stored 30 days then deleted (privacy + storage costs)
- Capture timing randomized (harder to fake)
- Low resolution acceptable (proof, not quality check)
```

#### 3.2 Device Signature

```
Purpose: Cryptographic proof of authenticity

Algorithm: RSA-SHA256 signature

Data to sign:
signature_payload = {
  device_id: "uuid",
  campaign_id: "uuid",
  content_asset_id: "uuid",
  played_at: "2026-01-23T14:30:00Z",
  duration_actual: 28,
  screenshot_hash: "sha256:abc123...",
  location: {lat: 10.762622, lng: 106.660172}
}

canonical_string = JSON.stringify(signature_payload, sorted_keys: true)
signature = RSA_sign(private_key, SHA256(canonical_string))

Impression includes:
- signature_payload (plaintext)
- signature (base64-encoded RSA signature)

Server verification:
canonical_string = JSON.stringify(impression.proof_payload, sorted: true)
public_key = Device.find(impression.device_id).public_key

IF verify_signature(signature, canonical_string, public_key):
  PASS signature check
ELSE:
  REJECT with "INVALID_SIGNATURE"
  consecutive_failures += 1
  IF consecutive_failures >= 3:
    SUSPEND device (compromised?)

Business Rules:
- Signature mandatory for all impressions
- Uses device's RSA private key (unique per device)
- Server has device public key (registered at activation)
- Canonical JSON format (consistent sorting)
- Failed signatures counted (3 strikes = suspend)
- Signature covers all critical fields (tamper-evident)
```

#### 3.3 GPS Location (Optional but Recommended)

```
Purpose: Verify device physically at store location

Collection:
IF device_has_gps:
  location = get_gps_coordinates()
  impression.proof_gps_lat = location.latitude
  impression.proof_gps_lng = location.longitude
  impression.proof_gps_accuracy = location.accuracy_meters

Validation:
IF impression.proof_gps_lat AND impression.proof_gps_lng:
  store = Store.find(device.store_id)
  distance = haversine_distance(
    impression.location,
    store.location
  )

  impression.distance_from_store = distance

  IF distance > 1000 meters: // 1 km
    FLAG as "LOCATION_ANOMALY"
    quality_score -= 20 points

  IF distance > 5000 meters: // 5 km
    FLAG as "LOCATION_CRITICAL"
    HOLD for manual review

  IF distance > 50000 meters: // 50 km
    REJECT with "INVALID_LOCATION"
    // Device likely not at store

Accuracy handling:
IF proof_gps_accuracy > 100 meters:
  // Low GPS accuracy, don't penalize
  Skip location validation
  quality_score -= 5 points (minor penalty)

Business Rules:
- GPS optional but recommended (improves quality score)
- Devices without GPS not penalized (but lower quality)
- Location validated against store coordinates
- Distance < 1km: Normal
- Distance 1-5km: Flagged (investigate)
- Distance > 5km: Hold for review
- Distance > 50km: Reject (clearly wrong)
- Low GPS accuracy forgiven (indoor reception issues)
```

#### 3.4 Timestamp Verification

```
Purpose: Prevent time manipulation attacks

Components:
- device_timestamp: Device local time when played
- server_timestamp: Server time when impression received
- time_drift: Difference between device and server

Calculation:
time_drift_seconds = device_timestamp - server_timestamp

impression.time_drift_seconds = time_drift_seconds

Validation:
IF abs(time_drift_seconds) > 600: // 10 minutes
  FLAG as "CLOCK_SKEW"
  quality_score -= 15 points

IF abs(time_drift_seconds) > 1800: // 30 minutes
  REJECT with "EXCESSIVE_CLOCK_DRIFT"
  Notify supplier: "Device clock needs sync"

IF time_drift_seconds < -300: // 5 min in past
  // Device clock is behind
  WARN: "Device clock slow"

IF time_drift_seconds > 300: // 5 min ahead
  // Device clock is ahead
  FLAG as "CLOCK_AHEAD"
  // Could be time travel attack

Clock drift trending:
recent_drifts = device.recent_impressions.pluck(:time_drift_seconds)

IF increasing_drift_trend(recent_drifts):
  FLAG device for "CLOCK_DRIFT_TREND"
  Suggest NTP sync

Business Rules:
- All impressions include device and server timestamps
- Drift calculated and stored for analysis
- Moderate drift (< 10 min) tolerated but flagged
- Excessive drift (> 30 min) rejected
- Trending drift suggests hardware/software issue
- Devices should sync with NTP regularly
```

---

## Verification & Validation

### Rule 4: Automated Verification Pipeline

```
Processing: Sequential checks, fail-fast

Pipeline stages:

1. SIGNATURE_VERIFICATION (Critical)
   Duration: ~10ms
   verify_device_signature(impression)
   IF FAIL: REJECT immediately (don't continue)

2. TIMESTAMP_VALIDATION (Critical)
   Duration: ~5ms
   validate_timestamp_bounds(impression)
   IF FAIL: REJECT immediately

3. CAMPAIGN_STATUS_CHECK (Critical)
   Duration: ~20ms
   validate_campaign_active_and_funded(impression)
   IF FAIL: REJECT immediately

4. DEVICE_STATUS_CHECK (Critical)
   Duration: ~15ms
   validate_device_active_and_online(impression)
   IF FAIL: REJECT immediately

5. DUPLICATE_CHECK (Critical)
   Duration: ~30ms
   check_redis_dedup_key(impression)
   IF FAIL: REJECT immediately

6. DURATION_VALIDATION (Critical)
   Duration: ~5ms
   validate_minimum_duration(impression)
   IF FAIL: REJECT immediately

7. LOCATION_VALIDATION (High priority)
   Duration: ~10ms
   validate_gps_proximity(impression) IF gps_available
   IF distance > 50km: REJECT
   IF distance > 5km: FLAG and HOLD
   IF distance > 1km: FLAG but CONTINUE

8. QUALITY_CHECKS (Medium priority)
   Duration: ~20ms
   calculate_quality_score(impression)
   IF quality_score < 30: HOLD for review
   IF quality_score < 50: FLAG but CONTINUE

9. FRAUD_DETECTION (Low priority, runs async)
   Duration: ~100ms
   run_fraud_detection_rules(impression)
   IF fraud_score > 80: HOLD for review
   IF fraud_score > 50: FLAG but CONTINUE

10. FINAL_DECISION
    IF no REJECT and no HOLD:
      impression.verification_status = VERIFIED
      process_billing(impression)
    ELSE IF HOLD:
      impression.verification_status = UNDER_REVIEW
      create_review_task(impression)
    ELSE:
      impression.verification_status = REJECTED

Total duration: ~215ms (target < 500ms)

Logging:
FOR EACH stage:
  ImpressionVerificationLog.create(
    impression_id: impression.id,
    step: stage_name,
    status: PASS/FAIL/WARN,
    check_type: check_type,
    result_message: message,
    processing_time_ms: duration
  )

Business Rules:
- Checks run sequentially (fail-fast optimization)
- Critical checks first (reject early)
- Each check logged for audit
- Target: 95% verified within 500ms
- Held impressions reviewed within 24 hours
```

---

## Fraud Detection

### Rule 5: Fraud Detection Rules

#### 5.1 Velocity-based Detection

```
Rule: Excessive impression rate from single device

Threshold:
max_impressions_per_hour = device.advertising_slots_per_hour × 1.2

Detection:
impressions_last_hour = COUNT(
  impressions WHERE device_id = X
  AND played_at > NOW() - 1 hour
)

IF impressions_last_hour > max_impressions_per_hour:
  fraud_score += 30
  FLAG as "EXCESSIVE_VELOCITY"

  IF impressions_last_hour > max_impressions_per_hour × 1.5:
    fraud_score += 50
    HOLD all impressions from this device
    SUSPEND device for investigation

Example:
  Device: 12 slots/hour configured
  Max allowed: 12 × 1.2 = 14.4 → 14 impressions/hour

  Actual: 16 impressions in last hour
  → fraud_score += 30
  → FLAG but allow

  Actual: 22 impressions in last hour
  → fraud_score += 50
  → HOLD and SUSPEND device

Business Rules:
- Velocity tracked per device per hour
- Allow 20% variance (burst traffic)
- 50% over limit triggers suspension
- Applies globally (all campaigns combined)
- Resets every hour (rolling window)
```

#### 5.2 Location-based Detection

```
Rule: Device far from registered store location

Threshold levels:
- < 1km: Normal (0 points)
- 1-5km: Suspicious (+20 points)
- 5-20km: Very suspicious (+40 points)
- 20-50km: Critical (+60 points)
- > 50km: Definite fraud (+100 points, auto-reject)

Detection:
IF impression has GPS:
  distance_km = haversine_distance(
    impression.location,
    device.store.location
  )

  CASE distance_km:
    WHEN < 1:
      fraud_score += 0
    WHEN 1..5:
      fraud_score += 20
      FLAG as "LOCATION_SUSPICIOUS"
    WHEN 5..20:
      fraud_score += 40
      FLAG as "LOCATION_VERY_SUSPICIOUS"
      HOLD for review
    WHEN 20..50:
      fraud_score += 60
      FLAG as "LOCATION_CRITICAL"
      HOLD for review
    WHEN > 50:
      fraud_score = 100
      REJECT with "LOCATION_FRAUD"

Exceptions:
- Device recently transferred to new store (7-day grace)
- Store has multiple locations (check all)
- Device is mobile type (kiosk, vehicle display)

Business Rules:
- GPS required for location-based detection
- Distance calculated using Haversine formula
- Multiple proximity thresholds
- Store transfers get grace period
- Mobile devices exempt from location checks
```

#### 5.3 Temporal Pattern Detection

```
Rule: Detect unnatural playback timing patterns

Pattern 1: Robotic intervals
suspicious_if_variance_low = true

intervals = []
FOR i IN 1..N-1:
  interval = impressions[i+1].played_at - impressions[i].played_at
  intervals.append(interval)

mean_interval = MEAN(intervals)
std_dev = STDDEV(intervals)
coefficient_of_variation = std_dev / mean_interval

IF coefficient_of_variation < 0.05:
  // Too consistent (human variance expected)
  fraud_score += 25
  FLAG as "ROBOTIC_TIMING"

Example:
  Impressions at: 10:00, 10:05, 10:10, 10:15, 10:20
  Intervals: 5min, 5min, 5min, 5min
  Mean: 5min, StdDev: 0
  CV: 0 / 5 = 0 → Too perfect!

Pattern 2: After-hours activity
IF impression.played_at NOT IN device.operating_hours:
  fraud_score += 40
  FLAG as "AFTER_HOURS"

  IF repeated_after_hours_pattern:
    fraud_score += 60
    HOLD for review

Pattern 3: Weekend anomaly
IF is_weekend(impression.played_at):
  AND store.weekend_closed:
    fraud_score += 50
    FLAG as "WEEKEND_FRAUD"

Business Rules:
- Natural playback has timing variance
- Perfect intervals suggest automation
- After-hours impressions highly suspicious
- Weekend activity checked against store hours
- Patterns contribute to fraud score (not auto-reject)
```

#### 5.4 Content Hash Validation

```
Rule: Screenshot must match approved content

Process:
1. Extract dominant features from screenshot:
   screenshot_features = extract_perceptual_hash(
     impression.proof_screenshot_url
   )

2. Compare against approved content:
   content = ContentAsset.find(impression.content_asset_id)
   content_features = content.perceptual_hash

   similarity = compare_perceptual_hashes(
     screenshot_features,
     content_features
   )

   // Similarity: 0-100 (100 = identical)

3. Threshold validation:
   IF similarity < 60:
     fraud_score += 40
     FLAG as "CONTENT_MISMATCH"
     HOLD for manual review

   IF similarity < 30:
     fraud_score += 80
     REJECT with "INVALID_CONTENT"

Example:
  Approved content: Product X advertisement
  Screenshot shows: Product Y advertisement
  Similarity: 25%
  → REJECT (wrong content played)

Edge cases:
- Video: Compare against random frames (not just thumbnail)
- Blank screen: Similarity = 0 → REJECT
- Partial obstruction: Similarity 50-70% → FLAG but allow

Business Rules:
- Perceptual hashing (not pixel-perfect comparison)
- Accounts for compression artifacts
- Threshold: 60% similarity minimum
- Manual review for borderline cases (50-70%)
- Blank screens always rejected
```

#### 5.5 Device Reputation Scoring

```
Rule: Track device historical fraud patterns

Reputation score: 0-100 (100 = excellent, 0 = fraudulent)

Starting score: 80 (new devices)

Score adjustments:

Positive factors:
+ Verified impressions: +0.1 per impression (up to 100)
+ Clean operation: +5 per week with no flags
+ High quality scores: +2 per premium impression
+ Long uptime: +5 per month >95% uptime

Negative factors:
- Flagged impression: -2 per flag
- Held impression: -5 per hold
- Rejected impression: -10 per rejection
- Disputed impression: -15 per dispute
- Upheld dispute (chargeback): -30 per chargeback
- Suspended: -50 (immediate)

Current fraud decision:
device_reputation = Device.find(impression.device_id).reputation_score

IF device_reputation < 30:
  // Very low reputation
  fraud_score += 40
  HOLD all impressions for manual review

IF device_reputation < 10:
  // Nearly banned
  fraud_score = 100
  REJECT with "LOW_REPUTATION"
  Suggest device replacement

IF device_reputation >= 90:
  // Excellent reputation
  fraud_score -= 10 (bonus)
  Fast-track verification

Reputation recovery:
// Devices can recover reputation over time
FOR EACH clean week:
  device.reputation_score += 2 (max 100)

Business Rules:
- Reputation tracked per device
- Starts at 80 (benefit of doubt)
- Improves with clean operation
- Degrades with fraud indicators
- Very low reputation = auto-hold/reject
- High reputation = expedited processing
- Reputation can recover (not permanent ban)
```

---

## Quality Scoring

### Rule 6: Quality Score Calculation

```
Purpose: Assess impression value/reliability beyond fraud detection

Quality Score: 0-100 (higher = better quality impression)

Formula:
quality_score = (
  technical_quality × 0.30 +
  proof_quality × 0.25 +
  viewability_quality × 0.20 +
  location_quality × 0.15 +
  timing_quality × 0.10
)

Component Calculations:

1. Technical Quality (30%):
   technical_quality = 100
   IF duration_actual < duration_expected × 0.90:
     technical_quality -= 20 // Not fully played
   IF time_drift > 300 seconds:
     technical_quality -= 15 // Clock skew
   IF network_quality = POOR:
     technical_quality -= 10
   IF device.health_score < 70:
     technical_quality -= 15 // Unreliable device

2. Proof Quality (25%):
   proof_quality = 100
   IF NOT has_screenshot:
     proof_quality -= 30
   IF screenshot_quality < 0.7:
     proof_quality -= 20
   IF NOT has_valid_signature:
     proof_quality = 0 // Critical
   IF NOT has_gps:
     proof_quality -= 15

3. Viewability Quality (20%):
   viewability_quality = 100
   IF screen_brightness < 30%:
     viewability_quality -= 20 // Too dim
   IF environment_brightness < 100 lux:
     viewability_quality -= 15 // Dark environment
   IF audio_enabled = false:
     viewability_quality -= 10 // No audio
   IF device_orientation_incorrect:
     viewability_quality -= 25 // Wrong aspect ratio

4. Location Quality (15%):
   location_quality = 100
   IF NOT has_gps:
     location_quality = 70 // Penalty for missing
   ELSE:
     distance_km = distance_from_store
     IF distance_km > 1:
       location_quality -= (distance_km × 5) // Max -100

5. Timing Quality (10%):
   timing_quality = 100
   IF played_outside_peak_hours:
     timing_quality -= 20 // Less valuable
   IF played_outside_operating_hours:
     timing_quality -= 50 // Suspicious
   IF is_weekend AND store.weekend_traffic_low:
     timing_quality -= 15

Final Score:
quality_score = CLAMP(computed_score, 0, 100)

Quality Tiers:
- PREMIUM: 90-100 (excellent)
- STANDARD: 70-89 (good)
- BASIC: 50-69 (acceptable)
- POOR: 0-49 (questionable)

Impact on Impression:
IF quality_score < 30:
  HOLD for manual review
IF quality_score >= 90:
  impression.quality_tier = PREMIUM
  Fast-track verification
IF quality_score < 50:
  FLAG as "LOW_QUALITY"
  Notify supplier

Business Rules:
- Quality score computed for every impression
- Poor quality impressions held for review
- High quality impressions fast-tracked
- Quality impacts supplier reputation
- Advertisers can filter by quality tier
- Premium impressions may justify higher CPM
```

---

## Dispute & Chargeback

### Rule 7: Dispute Process

#### 7.1 Dispute Filing

```
Actor: Advertiser
Window: 30 days from impression date

Eligibility:
- Impression must be VERIFIED status
- Within 30-day dispute window
- Advertiser must provide reason and evidence

Process:
1. Advertiser files dispute:
   POST /impressions/:id/dispute
   {
     "dispute_type": "INVALID_PROOF",
     "reason": "Screenshot shows different content than campaign",
     "evidence": [
       {"type": "screenshot_comparison", "url": "..."},
       {"type": "description", "text": "..."}
     ]
   }

2. Validation:
   impression = Impression.find(id)

   ✓ impression.verification_status = VERIFIED
   ✓ impression.created_at > NOW() - 30 days
   ✓ impression.campaign.advertiser_id = current_user.id
   ✓ NOT already disputed

3. Create dispute:
   dispute = ImpressionDispute.create(
     impression_id: impression.id,
     campaign_id: impression.campaign_id,
     advertiser_id: current_user.id,
     dispute_type: params[:dispute_type],
     reason: params[:reason],
     evidence: params[:evidence],
     status: PENDING,
     priority: calculate_priority(dispute_type),
     filed_at: NOW()
   )

4. Update impression:
   impression.update(
     verification_status: DISPUTED,
     dispute_id: dispute.id
   )

5. Hold billing:
   // Reverse billing temporarily
   campaign.spent -= impression.cost
   campaign.remaining_budget += impression.cost

   supplier.pending_revenue -= impression.supplier_revenue
   supplier.held_revenue += impression.supplier_revenue

6. Notify parties:
   - Advertiser: "Dispute filed, investigation started"
   - Supplier: "Impression disputed by advertiser"
   - Admin: Create investigation task

Business Rules:
- 30-day dispute window (strict)
- Evidence required (not just complaint)
- Billing held during investigation
- Both parties notified
- Admin assigned to investigate
```

#### 7.2 Investigation Process

```
Actor: Admin
SLA: Resolve within 72 hours (3 days)

Process:
1. Admin assigned to dispute:
   dispute.update(
     assigned_to: admin.id,
     status: INVESTIGATING
   )

2. Evidence review:
   Review advertiser evidence:
   - Screenshot comparisons
   - Device logs
   - Store operating hours
   - GPS data
   - Timestamps

   Review system evidence:
   - Impression verification logs
   - Proof-of-play data
   - Device heartbeat history
   - Recent impressions pattern

3. Decision matrix:

   Dispute Type: INVALID_PROOF
   Check: Does screenshot match approved content?
   IF screenshot clearly different:
     Decision: CHARGEBACK_APPROVED
   ELSE IF screenshot similar but unclear:
     Decision: PARTIAL_REFUND (50%)
   ELSE:
     Decision: CHARGEBACK_DENIED

   Dispute Type: DEVICE_OFFLINE
   Check: Was device online at reported time?
   IF last_heartbeat > played_at + 10 minutes:
     Decision: CHARGEBACK_APPROVED
   ELSE:
     Decision: CHARGEBACK_DENIED

   Dispute Type: WRONG_LOCATION
   Check: GPS distance from store
   IF distance > 10 km:
     Decision: CHARGEBACK_APPROVED
   ELSE IF distance 1-10 km:
     Decision: PARTIAL_REFUND (50%)
   ELSE:
     Decision: CHARGEBACK_DENIED

4. Document findings:
   dispute.update(
     investigation_notes: admin_notes,
     resolution: decision,
     resolved_at: NOW()
   )

5. Apply resolution (see Rule 7.3)

Business Rules:
- Admin review required for all disputes
- 72-hour SLA (most resolved in 24h)
- Evidence-based decisions
- Partial refunds allowed (50%)
- Findings documented for transparency
```

#### 7.3 Chargeback Execution

```
Resolution: CHARGEBACK_APPROVED

Process:
1. Update impression:
   impression.update(
     verification_status: REJECTED,
     rejected_reason: "Dispute upheld: #{dispute.resolution}",
     chargeback_at: NOW(),
     chargeback_reason: dispute.reason
   )

2. Refund advertiser:
   refund_amount = impression.cost

   campaign.spent -= refund_amount
   campaign.remaining_budget += refund_amount

   BudgetTransaction.create(
     campaign_id: campaign.id,
     type: CREDIT,
     amount: refund_amount,
     reference_id: dispute.id,
     description: "Chargeback for disputed impression"
   )

3. Penalize supplier:
   supplier_penalty = impression.supplier_revenue

   supplier.held_revenue -= supplier_penalty
   // Not credited back (supplier loses revenue)

   SupplierTransaction.create(
     supplier_id: supplier.id,
     type: DEBIT,
     amount: supplier_penalty,
     reference_id: dispute.id,
     description: "Chargeback penalty for impression #{impression.id}"
   )

4. Update device reputation:
   device.reputation_score -= 30
   device.chargeback_count += 1

   IF device.chargeback_count >= 5:
     device.status = MAINTENANCE
     FLAG device for "EXCESSIVE_CHARGEBACKS"

5. Update dispute:
   dispute.update(
     status: RESOLVED,
     refund_amount: refund_amount,
     supplier_penalty: supplier_penalty,
     resolved_at: NOW()
   )

6. Notify parties:
   - Advertiser: "Dispute resolved in your favor. Refund: ${refund_amount}"
   - Supplier: "Dispute resolved against you. Penalty: ${supplier_penalty}"
   - Include: Reason, evidence, appeal instructions

Business Rules:
- Full refund to advertiser
- Supplier loses revenue (penalty)
- Device reputation impacted
- Excessive chargebacks flag device
- Both parties notified with reason
- Appeal allowed within 7 days
```

#### 7.4 Dispute Resolution: CHARGEBACK_DENIED

```
Resolution: Dispute not upheld, impression valid

Process:
1. Update dispute:
   dispute.update(
     status: RESOLVED,
     resolution: CHARGEBACK_DENIED,
     resolved_at: NOW()
   )

2. Restore impression:
   impression.update(
     verification_status: VERIFIED
     // Back to verified status
   )

3. Release held billing:
   // Already deducted, just release hold
   supplier.held_revenue -= impression.supplier_revenue
   supplier.available_revenue += impression.supplier_revenue

4. No refund to advertiser:
   // Billing remains as-is

5. Notify parties:
   - Advertiser: "Dispute resolved against you. No refund issued. Reason: #{admin_notes}"
   - Supplier: "Dispute resolved in your favor. Revenue released."

Business Rules:
- Impression remains valid
- No financial changes (status quo)
- Supplier revenue released from hold
- Advertiser can appeal within 7 days
- Frivolous disputes may be penalized
```

---

## Edge Cases & Error Handling

### Edge Case 1: Impression During Network Outage

```
Scenario: Device records impression locally, submits later when network restored

Behavior:
1. Device caches impression data locally:
   - Timestamp
   - Content ID
   - Proof-of-play data
   - Queue for submission

2. When network restored:
   - Submit backfill impressions with original timestamps
   - Include network_outage flag

3. Server validation:
   IF impression.played_at < NOW() - 4 hours:
     REJECT with "TOO_STALE"
     // Beyond acceptable backfill window

   IF device_was_offline_during(impression.played_at):
     // Check device heartbeat history
     ACCEPT with lower quality_score

   IF no_evidence_of_outage:
     FLAG as "SUSPICIOUS_BACKFILL"
     HOLD for review

Business Rule:
- Backfill window: 4 hours maximum
- Device must have been offline during period
- Quality score reduced for backfilled impressions
- Suspiciously timed backfills held for review
```

### Edge Case 2: Screenshot Upload Failed

```
Scenario: Device computed screenshot hash but S3 upload failed

Behavior:
1. Impression includes screenshot_hash but no screenshot_url
2. Server accepts impression (hash is proof)
3. If later flagged for review:
   - Request device re-upload screenshot
   - Device may no longer have file (deleted)
   - Decision: Trust hash or reject?

Resolution:
IF impression.flagged_for_review:
  AND NOT impression.proof_screenshot_url:
    request_screenshot_reupload(device, impression)

    IF device_responds_with_screenshot:
      verify_hash_matches(screenshot, impression.proof_screenshot_hash)
      IF match:
        PROCEED with review
      ELSE:
        REJECT with "HASH_MISMATCH"
    ELSE:
      // Device no longer has screenshot
      decision_based_on_other_evidence()

Business Rule:
- Screenshot hash sufficient for normal impressions
- Manual review requires actual screenshot
- Device may not have file after 24 hours (deleted)
- Hash mismatch = clear evidence of tampering
```

### Edge Case 3: Campaign Budget Exhausted Mid-Impression

```
Scenario: Campaign budget runs out while impression is being verified

Timeline:
- T+0s: Impression submitted, remaining_budget = $0.05
- T+1s: Verification starts, cost calculated = $0.08
- T+2s: Insufficient budget detected

Behavior:
budget_check_result = check_budget(campaign, impression.cost)

IF budget_check_result = INSUFFICIENT:
  // Race condition: budget exhausted during verification

  // Option 1: Reject impression
  REJECT with "BUDGET_EXHAUSTED"
  Trigger campaign auto-pause

  // Option 2: Honor impression (allow negative balance)
  IF impression.played_at < campaign.paused_at:
    // Impression started before pause
    ACCEPT impression
    Allow negative balance (up to -$1.00)
    campaign.remaining_budget = -$0.03

  // Option 3: Partial credit
  IF campaign.remaining_budget > 0:
    partial_cost = campaign.remaining_budget
    Record impression with partial_cost
    Note: "Partial billing due to budget limit"

Recommended: Option 2 (honor in-flight impressions)

Business Rule:
- In-flight impressions honored
- Grace allowance: negative balance up to $1.00
- Campaign paused immediately after
- Advertiser notified of overdraft
- Next top-up must cover overdraft
```

---

## Validation Rules

### Impression Validation Matrix

| Field | Rule | Error Message |
|-------|------|---------------|
| campaign_id | Must be active campaign | "Campaign not found or inactive" |
| device_id | Must be active device | "Device not found or inactive" |
| content_asset_id | Must be approved content | "Content not found or not approved" |
| played_at | Within ±10 min of server time | "Timestamp out of acceptable range" |
| duration_actual | >= 80% of expected | "Insufficient playback duration" |
| duration_actual | <= 150% of expected | "Duration exceeds content length" |
| proof_screenshot_hash | SHA256 format (64 chars) | "Invalid screenshot hash format" |
| proof_device_signature | Valid RSA signature | "Invalid or missing device signature" |
| proof_gps_lat | Range: -90 to 90 | "Invalid latitude" |
| proof_gps_lng | Range: -180 to 180 | "Invalid longitude" |
| cost | > 0 | "Impression cost must be positive" |
| cpm_rate | Matches current rate table | "CPM rate mismatch" |

---

## Calculations & Formulas

### Formula Summary

#### 1. Quality Score
```
quality_score = (
  technical_quality × 0.30 +
  proof_quality × 0.25 +
  viewability_quality × 0.20 +
  location_quality × 0.15 +
  timing_quality × 0.10
)

Range: 0-100
Target: ≥ 70
Premium: ≥ 90
```

#### 2. Fraud Score
```
fraud_score = BASE_SCORE(0) +
  velocity_penalty +
  location_penalty +
  pattern_penalty +
  reputation_penalty -
  device_reputation_bonus

Range: 0-100 (higher = more likely fraud)
Thresholds:
- < 30: Clean (no action)
- 30-50: Suspicious (flag)
- 50-80: Very suspicious (hold)
- > 80: Likely fraud (reject or suspend)
```

#### 3. Verification Success Rate (Device Metric)
```
verification_rate = (
  verified_impressions /
  (verified_impressions + rejected_impressions)
) × 100

Target: ≥ 95%
Good: 90-95%
Poor: < 90%
```

#### 4. Dispute Rate (System Metric)
```
dispute_rate = (
  disputed_impressions /
  total_verified_impressions
) × 100

Target: < 1%
Acceptable: 1-3%
High: > 3% (investigate)
```

#### 5. Chargeback Rate (Supplier/Device Metric)
```
chargeback_rate = (
  chargebacks_approved /
  total_verified_impressions
) × 100

Excellent: < 0.5%
Acceptable: 0.5-2%
Poor: > 2%
Critical: > 5% (suspend device)
```

---

## Appendix: Verification Logs Example

```
ImpressionVerificationLog records for impression_id: "abc-123"

1. {
     step: "SIGNATURE_VERIFICATION",
     status: "PASS",
     check_type: "SIGNATURE",
     result_message: "Device signature valid",
     processing_time_ms: 12
   }

2. {
     step: "TIMESTAMP_VALIDATION",
     status: "WARN",
     check_type: "TIMESTAMP",
     expected_value: "< 600s drift",
     actual_value: "420s drift",
     result_message: "Clock skew detected but within tolerance",
     severity: "WARNING",
     processing_time_ms: 5
   }

3. {
     step: "CAMPAIGN_STATUS_CHECK",
     status: "PASS",
     check_type: "CAMPAIGN",
     result_message: "Campaign active with sufficient budget",
     processing_time_ms: 18
   }

4. {
     step: "DUPLICATE_CHECK",
     status: "PASS",
     check_type: "DUPLICATE",
     result_message: "No duplicate found in 5-minute window",
     processing_time_ms: 25
   }

5. {
     step: "LOCATION_VALIDATION",
     status: "WARN",
     check_type: "LOCATION",
     expected_value: "< 1000m from store",
     actual_value: "1250m from store",
     result_message: "Device slightly far from store (flagged)",
     severity: "WARNING",
     processing_time_ms: 8
   }

6. {
     step: "QUALITY_SCORE_CALCULATION",
     status: "PASS",
     check_type: "QUALITY",
     actual_value: "78",
     result_message: "Quality score: 78 (STANDARD tier)",
     processing_time_ms: 22
   }

7. {
     step: "FRAUD_DETECTION",
     status: "PASS",
     check_type: "FRAUD",
     actual_value: "fraud_score: 15",
     result_message: "No fraud indicators detected",
     processing_time_ms: 95
   }

8. {
     step: "FINAL_DECISION",
     status: "PASS",
     result_message: "Impression VERIFIED with warnings",
     processing_time_ms: 2
   }

Total processing time: 187ms
Final status: VERIFIED (with 2 warnings)
Quality score: 78
Fraud score: 15
```

---

## Appendix: Glossary

**Impression**: Single verified playback of ad content
**Proof-of-Play**: Evidence package (screenshot + signature + GPS)
**Verification**: Automated validation process
**Quality Score**: 0-100 metric indicating impression value
**Fraud Score**: 0-100 metric indicating fraud likelihood
**Dispute**: Advertiser challenge to impression validity
**Chargeback**: Refund issued to advertiser for invalid impression
**Hold**: Temporary state pending manual review
**Backfill**: Impression submitted after network outage

---

**Document Status**: Ready for review
**Next Steps**:
1. Review with stakeholders
2. Technical review (fraud team, billing team)
3. QA test case creation
4. Implementation planning

---

**Related Documents**:
- `business-rules-campaign.md` - Campaign & billing basics
- `business-rules-device.md` - Device management & heartbeat
- `business-rules-supplier.md` - Supplier payout & disputes
