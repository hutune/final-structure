# Business Rules: Supplier Management

**Version**: 1.0
**Last Updated**: 2026-01-23
**Owner**: Business Rules Team
**Status**: Draft

---

## Table of Contents

1. [Overview](#overview)
2. [Supplier Entity](#supplier-entity)
3. [Supplier Onboarding & Registration](#supplier-onboarding--registration)
4. [Store Management](#store-management)
5. [Device Management](#device-management)
6. [Revenue Tracking & Payout](#revenue-tracking--payout)
7. [Competitor Blocking Rules](#competitor-blocking-rules)
8. [Supplier Performance Metrics](#supplier-performance-metrics)
9. [Account Tiers & Limits](#account-tiers--limits)
10. [Compliance & Verification](#compliance--verification)
11. [Account Status Management](#account-status-management)
12. [Integration Points](#integration-points)
13. [Edge Cases & Special Scenarios](#edge-cases--special-scenarios)
14. [Business Formulas](#business-formulas)

---

## 1. Overview

### 1.1 Supplier Role in RMN Ecosystem

**Definition**: A Supplier is a retail business owner who provides physical retail locations (stores) and digital signage devices for displaying advertising content, earning revenue from impressions.

**Core Responsibilities**:
- Register and manage retail stores
- Install and maintain digital signage devices
- Define competitor blocking rules
- Receive revenue from impressions
- Maintain device uptime and quality standards

**Revenue Model**: Suppliers earn 80% of the impression cost (CPM × impressions), with the platform retaining 20%.

### 1.2 Supplier Lifecycle

```
PENDING_REGISTRATION → ACTIVE → SUSPENDED → PERMANENTLY_BANNED
                          ↓
                      INACTIVE (voluntary)
```

**State Definitions**:
- **PENDING_REGISTRATION**: Initial registration submitted, awaiting verification
- **ACTIVE**: Fully operational, devices can display ads
- **INACTIVE**: Voluntarily paused by supplier (no ads shown)
- **SUSPENDED**: Temporarily blocked due to policy violation or quality issues
- **PERMANENTLY_BANNED**: Permanent termination (fraud, severe violations)

### 1.3 Key Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Device Uptime | % of time devices are online and operational | ≥95% |
| Revenue per Device | Average monthly revenue per device | $200-$1000 |
| Quality Score | Overall device and content quality | ≥80/100 |
| Payout Reliability | On-time payout success rate | 100% |
| Store Coverage | # of stores with active devices | Growth metric |

---

## 2. Supplier Entity

### 2.1 Core Attributes

```typescript
interface Supplier {
  // Identity
  supplier_id: string                    // UUID, primary key
  user_id: string                        // FK to users table (owner account)
  business_name: string                  // Legal business name
  business_type: BusinessType            // INDIVIDUAL | SOLE_PROPRIETORSHIP | LLC | CORPORATION | PARTNERSHIP
  display_name: string                   // Public-facing name

  // Business Information
  tax_id: string                         // EIN (US) or equivalent
  business_registration_number: string   // State/country registration ID
  registration_country: string           // ISO 3166-1 alpha-2
  registration_state: string             // State/province code
  incorporation_date: Date               // Business founding date

  // Contact Information
  primary_contact_name: string
  primary_contact_email: string
  primary_contact_phone: string
  business_address: Address              // Legal business address
  billing_address: Address               // Billing address (may differ)

  // Account Status
  status: SupplierStatus                 // PENDING_REGISTRATION | ACTIVE | INACTIVE | SUSPENDED | PERMANENTLY_BANNED
  tier: SupplierTier                     // STARTER | PROFESSIONAL | ENTERPRISE
  verification_status: VerificationStatus // UNVERIFIED | PENDING | VERIFIED | REJECTED

  // Financial Information
  wallet_id: string                      // FK to wallets table
  revenue_share_percentage: number       // Default: 80% (supplier's share)
  payment_schedule: PaymentSchedule      // WEEKLY | BIWEEKLY | MONTHLY
  minimum_payout_threshold: number       // Minimum balance to trigger payout (default: $50)

  // Performance Metrics
  total_stores: number                   // Count of registered stores
  total_devices: number                  // Count of active devices
  total_impressions_served: number       // Lifetime impression count
  total_revenue_earned: number           // Lifetime revenue (USD)
  average_device_uptime: number          // % uptime across all devices
  quality_score: number                  // 0-100 score

  // Settings & Preferences
  auto_approve_campaigns: boolean        // Auto-approve campaigns that pass blocking rules
  notification_preferences: NotificationPreferences
  timezone: string                       // IANA timezone
  locale: string                         // Language/region (en-US, etc.)

  // Metadata
  created_at: Date
  updated_at: Date
  verified_at: Date | null
  last_payout_at: Date | null
  suspended_at: Date | null
  suspension_reason: string | null
  banned_at: Date | null
  ban_reason: string | null
}

enum BusinessType {
  INDIVIDUAL = "INDIVIDUAL",                     // Individual/sole trader
  SOLE_PROPRIETORSHIP = "SOLE_PROPRIETORSHIP",   // Sole proprietorship
  LLC = "LLC",                                   // Limited Liability Company
  CORPORATION = "CORPORATION",                   // Corporation (Inc.)
  PARTNERSHIP = "PARTNERSHIP"                    // Partnership
}

enum SupplierStatus {
  PENDING_REGISTRATION = "PENDING_REGISTRATION",
  ACTIVE = "ACTIVE",
  INACTIVE = "INACTIVE",
  SUSPENDED = "SUSPENDED",
  PERMANENTLY_BANNED = "PERMANENTLY_BANNED"
}

enum SupplierTier {
  STARTER = "STARTER",           // 1-5 devices
  PROFESSIONAL = "PROFESSIONAL", // 6-50 devices
  ENTERPRISE = "ENTERPRISE"      // 51+ devices, custom terms
}

enum VerificationStatus {
  UNVERIFIED = "UNVERIFIED",     // No verification submitted
  PENDING = "PENDING",           // Under review
  VERIFIED = "VERIFIED",         // Approved
  REJECTED = "REJECTED"          // Rejected, can resubmit
}

enum PaymentSchedule {
  WEEKLY = "WEEKLY",           // Every Monday
  BIWEEKLY = "BIWEEKLY",       // Every other Monday
  MONTHLY = "MONTHLY"          // 1st of each month
}

interface Address {
  line1: string
  line2: string | null
  city: string
  state: string               // State/province code
  postal_code: string
  country: string             // ISO 3166-1 alpha-2
  latitude: number | null
  longitude: number | null
}

interface NotificationPreferences {
  email_enabled: boolean
  sms_enabled: boolean
  push_enabled: boolean
  notify_on_payout: boolean
  notify_on_device_offline: boolean
  notify_on_campaign_approval_request: boolean
  notify_on_revenue_milestone: boolean
}
```

### 2.2 Related Entities

#### SupplierVerification
```typescript
interface SupplierVerification {
  verification_id: string                // UUID
  supplier_id: string                    // FK
  verification_type: VerificationType    // BUSINESS | TAX | BANK_ACCOUNT
  status: VerificationStatus

  // Submitted Documents
  documents: Document[]                  // Uploaded files

  // Business Verification Fields
  business_registration_document_id: string | null
  tax_document_id: string | null        // W-9, VAT registration, etc.
  proof_of_address_id: string | null
  bank_statement_id: string | null

  // Review Information
  submitted_at: Date
  reviewed_at: Date | null
  reviewed_by_user_id: string | null
  rejection_reason: string | null
  notes: string | null

  // Audit
  created_at: Date
  updated_at: Date
}

enum VerificationType {
  BUSINESS = "BUSINESS",           // Business entity verification
  TAX = "TAX",                     // Tax ID verification
  BANK_ACCOUNT = "BANK_ACCOUNT"    // Bank account ownership
}
```

#### SupplierSettings
```typescript
interface SupplierSettings {
  settings_id: string
  supplier_id: string

  // Campaign Approval
  auto_approve_campaigns: boolean
  require_manual_review_for_sensitive_categories: boolean

  // Revenue & Payout
  payment_schedule: PaymentSchedule
  minimum_payout_threshold: number       // USD
  payout_method: PayoutMethod            // BANK_TRANSFER | PAYPAL | STRIPE

  // Device Management
  require_device_approval: boolean       // Require admin approval for new devices
  max_devices_per_store: number          // Limit devices per store location

  // Performance
  alert_threshold_device_offline_minutes: number  // Alert if device offline > X minutes
  alert_threshold_low_revenue: number    // Alert if daily revenue < $X

  created_at: Date
  updated_at: Date
}

enum PayoutMethod {
  BANK_TRANSFER = "BANK_TRANSFER",       // ACH/Wire transfer
  PAYPAL = "PAYPAL",                     // PayPal payout
  STRIPE = "STRIPE"                      // Stripe Connect payout
}
```

---

## 3. Supplier Onboarding & Registration

### 3.1 Registration Flow

**Steps**:
1. **Account Creation**: Create user account (email + password or OAuth)
2. **Business Profile**: Provide business information
3. **Document Submission**: Upload verification documents
4. **Store Registration**: Add first store location
5. **Device Setup**: Register first device
6. **Verification Review**: Platform reviews submission
7. **Approval & Activation**: Account activated upon approval

### 3.2 Registration Requirements

#### 3.2.1 Required Information

**Basic Information**:
- Business name (legal)
- Business type (Individual, LLC, Corporation, etc.)
- Tax ID (EIN, SSN, or equivalent)
- Business registration number
- Primary contact details (name, email, phone)
- Business address

**Financial Information**:
- Bank account details (for payouts)
- Payment schedule preference
- Tax withholding information (W-9 for US, W-8 for non-US)

#### 3.2.2 Required Documents

| Business Type | Required Documents |
|--------------|-------------------|
| Individual | Government ID, Proof of address, Bank statement |
| Sole Proprietorship | Business license, EIN letter, Bank statement |
| LLC | Articles of Organization, EIN letter, Bank statement, Operating Agreement |
| Corporation | Certificate of Incorporation, EIN letter, Bank statement, Bylaws |
| Partnership | Partnership Agreement, EIN letter, Bank statement |

### 3.3 Verification Process

#### 3.3.1 Automated Checks
- Tax ID validation (if US-based)
- Email verification (confirmation link)
- Phone number verification (SMS OTP)
- Address validation (against postal database)
- Bank account verification (micro-deposits or instant verification)

#### 3.3.2 Manual Review
- Document authenticity check
- Business registration verification (state/country database)
- Background check (fraud, compliance)
- Store location verification (Google Maps, Street View)

**Review SLA**:
- Standard: 3-5 business days
- Express (Enterprise tier): 1 business day
- Expedited (with fee): Same day

#### 3.3.3 Approval Criteria

**Approval Requirements**:
- Valid business registration
- Authentic documents
- Verified tax ID
- Valid bank account
- Physical store location confirmed
- No prior bans or fraud flags
- Compliance with platform policies

**Automatic Rejection Reasons**:
- Invalid or fake documents
- Mismatched information (name, address)
- Prior ban history
- Prohibited business types (adult content, illegal activities)
- No physical store location
- Failed background check

### 3.4 Onboarding Rules

**Rule 3.4.1: Minimum Requirements for Activation**
```
WHEN supplier completes registration
THEN verify:
  - business_name IS NOT NULL
  - tax_id IS VALID AND NOT DUPLICATE
  - primary_contact_email IS VERIFIED
  - business_address IS VALIDATED
  - bank_account IS VERIFIED
  - At least 1 store IS REGISTERED
  - At least 1 device IS REGISTERED

IF all requirements met:
  - SET status = "ACTIVE"
  - CREATE wallet with available_balance = $0
  - SEND welcome email with onboarding checklist
  - ENABLE device for ad serving
```

**Rule 3.4.2: Trial Period for New Suppliers**
```
NEW suppliers start with 30-day trial period:
  - Full platform access
  - Standard revenue share (80/20)
  - No minimum payout threshold (immediate payout)
  - Dedicated onboarding support

AFTER 30 days:
  - Review performance (uptime, quality)
  - If quality_score >= 70: Continue with standard terms
  - If quality_score < 70: Require improvement plan or suspend
```

**Rule 3.4.3: Duplicate Prevention**
```
PREVENT duplicate registrations:
  - Same tax_id cannot be used for multiple suppliers
  - Same bank_account cannot be linked to multiple suppliers
  - Same business_address flagged for manual review if >2 suppliers

EXCEPTION: Franchise businesses may have same business_address
  - Require franchise agreement documentation
  - Each location must have unique store registration
```

---

## 4. Store Management

### 4.1 Store Entity

```typescript
interface Store {
  store_id: string                       // UUID, primary key
  supplier_id: string                    // FK to supplier

  // Store Information
  store_name: string                     // "Whole Foods - Downtown Seattle"
  store_code: string                     // Internal supplier code (optional)
  store_type: StoreType                  // GROCERY | RETAIL | RESTAURANT | GYM | PHARMACY | OTHER

  // Location
  address: Address
  timezone: string                       // IANA timezone
  geofence_radius_meters: number         // For location-based verification (default: 100m)

  // Store Profile
  square_footage: number | null          // Store size (sq ft)
  average_daily_visitors: number | null  // Estimated foot traffic
  operating_hours: OperatingHours[]      // Daily operating hours

  // Store Category (for targeting)
  primary_category: string               // "Grocery", "Fashion", etc.
  subcategories: string[]                // ["Organic", "Premium", "Local"]

  // Device Management
  max_devices_allowed: number            // Based on store size, tier
  total_devices: number                  // Current device count
  active_devices: number                 // Devices currently online

  // Performance
  total_impressions_served: number
  total_revenue_generated: number
  average_device_uptime: number          // % across store devices
  quality_score: number                  // 0-100

  // Status
  status: StoreStatus                    // ACTIVE | INACTIVE | SUSPENDED
  verified: boolean                      // Location verified

  // Metadata
  created_at: Date
  updated_at: Date
  verified_at: Date | null
  last_impression_at: Date | null
}

enum StoreType {
  GROCERY = "GROCERY",
  RETAIL = "RETAIL",
  RESTAURANT = "RESTAURANT",
  GYM = "GYM",
  PHARMACY = "PHARMACY",
  CONVENIENCE = "CONVENIENCE",
  DEPARTMENT_STORE = "DEPARTMENT_STORE",
  SHOPPING_MALL = "SHOPPING_MALL",
  OTHER = "OTHER"
}

enum StoreStatus {
  ACTIVE = "ACTIVE",           // Operational, devices can serve ads
  INACTIVE = "INACTIVE",       // Temporarily paused
  SUSPENDED = "SUSPENDED"      // Suspended due to violation
}

interface OperatingHours {
  day_of_week: number          // 0 (Sunday) to 6 (Saturday)
  open_time: string            // "09:00" (HH:mm format)
  close_time: string           // "21:00"
  is_closed: boolean           // True if store closed this day
}
```

### 4.2 Store Registration Rules

**Rule 4.2.1: Store Validation**
```
WHEN supplier registers a new store:
  - store_name MUST be unique within supplier account
  - address MUST be valid and geocoded
  - store_type MUST be selected
  - operating_hours MUST be provided

VALIDATE:
  - Address exists (geocoding service)
  - Store not duplicate (same address already registered by same supplier)
  - Store location within allowed regions (geo-restrictions)
```

**Rule 4.2.2: Store Verification**
```
NEW stores require verification:

AUTOMATED CHECKS:
  - Geocode address → Get lat/lng
  - Verify address is commercial (not residential)
  - Check Google Maps / Street View for business presence

MANUAL VERIFICATION (if automated fails):
  - Supplier uploads storefront photo
  - Supplier uploads business license for location
  - Manual review within 3 business days

APPROVAL:
  - SET verified = TRUE
  - SET status = "ACTIVE"
  - ALLOW device registration for this store
```

**Rule 4.2.3: Store Device Limits**
```
Maximum devices per store based on square footage:

CALCULATE max_devices_allowed:
  IF square_footage < 1000:         max = 1 device
  IF square_footage 1000-2999:      max = 2 devices
  IF square_footage 3000-4999:      max = 3 devices
  IF square_footage 5000-9999:      max = 5 devices
  IF square_footage >= 10000:       max = 10 devices

EXCEPTION for ENTERPRISE tier:
  - Custom device limits negotiated
  - Can exceed standard limits with approval
```

**Rule 4.2.4: Store Operating Hours**
```
Store operating hours affect ad serving:

RULE:
  - Ads ONLY served during operating hours
  - Devices automatically enter "standby mode" outside hours
  - No impressions counted when store is closed

EXCEPTION:
  - 24/7 stores (like convenience stores): Set all days to 00:00-23:59
  - Holiday hours: Supplier can set special hours for specific dates
```

### 4.3 Store Status Management

**Rule 4.3.1: Inactivation**
```
Supplier can set store to INACTIVE:
  - Temporarily pause ad serving for this store
  - All devices at store enter standby mode
  - No new campaigns matched to this store
  - Existing campaigns continue for other stores

TO REACTIVATE:
  - Change status back to ACTIVE
  - Devices resume normal operation
  - Store re-enters campaign matching pool
```

**Rule 4.3.2: Suspension (Platform-Initiated)**
```
Platform can SUSPEND store:

SUSPENSION TRIGGERS:
  - Quality score < 50 for 7+ consecutive days
  - Multiple fraud/suspicious activity reports
  - Violation of content policies
  - Device tampered or relocated without update

DURING SUSPENSION:
  - No ads served to any device at store
  - Revenue hold (pending in wallet)
  - Supplier notified with reason
  - 14-day window to resolve issues

RESOLUTION:
  - If resolved: Reactivate store, release held revenue
  - If unresolved: Store permanently deactivated
```

---

## 5. Device Management

### 5.1 Device Registration

**Device Entity** is defined in the Device Management business rules document. This section covers supplier-specific device management workflows.

#### 5.1.1 Device Registration Flow

**Steps**:
1. **Store Selection**: Supplier selects which store the device belongs to
2. **Device QR Scan**: Device displays QR code on first boot
3. **Pairing**: Supplier scans QR with mobile app/web
4. **Device Configuration**: Set device name, screen specs, slot config
5. **Location Verification**: Confirm device is at registered store location (GPS)
6. **Approval**: Device approved and goes live

#### 5.1.2 Device Registration Rules

**Rule 5.1.2.1: Device-Store Association**
```
WHEN device is registered:
  - Device MUST be associated with a verified store
  - Device location MUST be within geofence_radius_meters of store address
  - Store MUST have available device slots (current < max_devices_allowed)

IF device outside geofence:
  - REJECT registration
  - NOTIFY supplier: "Device must be at store location"
  - Provide map showing expected vs actual location
```

**Rule 5.1.2.2: Device Naming Convention**
```
Device names MUST follow pattern:
  "{store_name} - {device_location}"

EXAMPLES:
  - "Whole Foods Downtown - Checkout Lane 1"
  - "Nike Store - Window Display"
  - "Starbucks 5th Ave - Menu Board"

VALIDATION:
  - device_name length: 5-100 characters
  - Must be unique within store
```

**Rule 5.1.2.3: Device Approval**
```
NEW devices require approval:

AUTOMATED APPROVAL (if all checks pass):
  - Location within geofence ✓
  - Store has available slots ✓
  - Device specs meet minimum requirements ✓
  - No duplicate device_id ✓

MANUAL APPROVAL (if any fail):
  - Admin reviews device details
  - Supplier may need to provide photos or documentation
  - Approval within 24 hours
```

### 5.2 Device Monitoring

#### 5.2.1 Device Health Monitoring

Suppliers have dashboard to monitor device health:

**Metrics Displayed**:
- Device status (ONLINE, OFFLINE, ERROR)
- Uptime percentage (last 24h, 7d, 30d)
- Last heartbeat timestamp
- Current content playing
- Impressions served today
- Revenue generated today

**Alerts** (configurable):
- Device offline > 30 minutes → Email/SMS alert
- Device error state → Immediate alert
- Low revenue (< $X per day) → Daily digest
- Missed content sync → Alert

#### 5.2.2 Device Maintenance

**Rule 5.2.2.1: Scheduled Maintenance Mode**
```
Supplier can set device to MAINTENANCE mode:
  - No ads served during maintenance window
  - Device displays "Device Under Maintenance" message
  - No impact on uptime score during this period
  - Max maintenance window: 4 hours per session

WHEN maintenance exceeds 4 hours:
  - Counts as downtime
  - Affects device uptime score
```

**Rule 5.2.2.2: Device Relocation**
```
IF device needs to move to different location:
  - Supplier MUST update device location in platform
  - Device must re-verify location (GPS check)
  - If moving to different store: Must un-pair and re-pair

PENALTY for unauthorized relocation:
  - If device detected at wrong location (>500m from registered address):
    - Device suspended immediately
    - All impressions flagged for review
    - Revenue held pending investigation
```

### 5.3 Device Removal

**Rule 5.3.1: Device Decommission**
```
Supplier can decommission a device:
  - SET device status = "DECOMMISSIONED"
  - Device stops serving ads
  - Final revenue calculated and added to wallet
  - Device can be re-registered later (to same or different store)

EFFECTS:
  - Store's total_devices decremented
  - Device no longer counts toward tier limits
  - Historical data retained for reporting
```

---

## 6. Revenue Tracking & Payout

### 6.1 Revenue Model

**Revenue Share**:
- **Supplier**: 80% of impression revenue
- **Platform**: 20% of impression revenue

**Formula**:
```
impression_cost = campaign.cpm × (1 / 1000)
supplier_revenue = impression_cost × 0.80
platform_revenue = impression_cost × 0.20
```

### 6.2 Revenue Calculation

#### 6.2.1 Per-Impression Revenue

**Rule 6.2.1.1: Revenue Recording**
```
WHEN impression is verified (status = VERIFIED):
  1. CALCULATE impression_cost = campaign.cpm / 1000
  2. CALCULATE supplier_revenue = impression_cost × 0.80
  3. CALCULATE platform_revenue = impression_cost × 0.20

  4. UPDATE supplier.wallet:
     - pending_balance += supplier_revenue

  5. UPDATE campaign.wallet:
     - held_balance -= impression_cost
     - (impression cost already deducted during campaign launch)

  6. CREATE WalletTransaction:
     - type = "IMPRESSION_REVENUE"
     - amount = supplier_revenue
     - reference_id = impression_id
     - status = "PENDING"
```

**Rule 6.2.1.2: Revenue Hold Period**
```
Impression revenue is HELD for 7 days:
  - Status: PENDING in wallet
  - Allows for disputes/chargebacks
  - After 7 days (no disputes): Move PENDING → AVAILABLE

FORMULA:
  available_date = impression.verified_at + 7 days

AUTOMATED JOB runs daily:
  SELECT * FROM wallet_transactions
  WHERE type = 'IMPRESSION_REVENUE'
    AND status = 'PENDING'
    AND available_date <= NOW()

  FOR EACH transaction:
    - SET status = 'COMPLETED'
    - MOVE wallet.pending_balance → wallet.available_balance
```

#### 6.2.2 Revenue Aggregation

**Daily Revenue Calculation**:
```sql
-- Calculate supplier daily revenue
SELECT
  supplier_id,
  DATE(verified_at) as revenue_date,
  COUNT(*) as total_impressions,
  SUM(supplier_revenue) as total_revenue,
  AVG(cpm) as average_cpm
FROM impressions
WHERE status = 'VERIFIED'
  AND supplier_id = :supplier_id
  AND verified_at >= :start_date
  AND verified_at < :end_date
GROUP BY supplier_id, DATE(verified_at)
```

**Revenue by Device**:
```sql
SELECT
  device_id,
  device_name,
  store_name,
  COUNT(*) as impressions,
  SUM(supplier_revenue) as revenue,
  AVG(supplier_revenue) as avg_revenue_per_impression
FROM impressions i
JOIN devices d ON i.device_id = d.device_id
JOIN stores s ON d.store_id = s.store_id
WHERE i.supplier_id = :supplier_id
  AND i.status = 'VERIFIED'
  AND i.verified_at >= :start_date
GROUP BY device_id, device_name, store_name
ORDER BY revenue DESC
```

### 6.3 Payout Process

#### 6.3.1 Payout Schedule

**Payment Frequencies**:
- **WEEKLY**: Every Monday (for revenue from previous Mon-Sun)
- **BIWEEKLY**: Every other Monday (2-week cycles)
- **MONTHLY**: 1st of each month (for previous calendar month)

**Payout Eligibility**:
```
Payout occurs IF:
  - wallet.available_balance >= minimum_payout_threshold
  - payment_method is configured and verified
  - supplier.status = "ACTIVE"
  - No pending disputes or compliance issues
```

#### 6.3.2 Payout Execution

**Rule 6.3.2.1: Automatic Payout**
```
ON scheduled payout day (e.g., Monday for WEEKLY):
  FOR EACH supplier WHERE payment_schedule = "WEEKLY":
    IF wallet.available_balance >= minimum_payout_threshold:
      1. CREATE WithdrawalRequest:
         - amount = wallet.available_balance
         - status = "PENDING"
         - scheduled_date = TODAY

      2. DEDUCT from wallet:
         - available_balance -= amount
         - Add to "in_transit" balance

      3. INITIATE payment via payment processor:
         - ACH transfer (3-5 business days)
         - PayPal transfer (instant to 1 day)
         - Stripe Connect payout (2-3 business days)

      4. ON payment success:
         - SET withdrawal_request.status = "COMPLETED"
         - in_transit_balance = 0
         - CREATE WalletTransaction (type = "PAYOUT")

      5. ON payment failure:
         - SET withdrawal_request.status = "FAILED"
         - REFUND to available_balance
         - NOTIFY supplier to update payment method
```

**Rule 6.3.2.2: Minimum Payout Threshold**
```
DEFAULT minimum_payout_threshold = $50

RATIONALE:
  - Reduces transaction fees for small amounts
  - Balances supplier cash flow with platform efficiency

EXCEPTION:
  - Supplier can request manual payout if balance < $50 (once per month)
  - Fee charged: $5 for manual payouts under threshold
```

**Rule 6.3.2.3: Payout Holds**
```
Payout may be HELD if:
  - Active disputes on impressions (total disputed amount > $100)
  - Supplier under investigation for fraud
  - Outstanding balance owed to platform (e.g., chargebacks)
  - Tax forms not submitted (W-9/W-8)

HOLD DURATION:
  - Until issues resolved
  - Max hold: 90 days (after which funds released unless legal hold)

SUPPLIER NOTIFICATION:
  - Email sent immediately when payout held
  - Reason and required actions clearly stated
  - Support contact provided
```

#### 6.3.3 Tax Handling

**Rule 6.3.3.1: Tax Withholding**
```
TAX WITHHOLDING applies:
  - US suppliers: No withholding (1099-K issued if >$20k revenue AND >200 transactions)
  - Non-US suppliers: 30% withholding (unless tax treaty)

FORMULA for non-US suppliers:
  gross_payout = wallet.available_balance
  withholding_amount = gross_payout × 0.30
  net_payout = gross_payout - withholding_amount

  CREATE WalletTransaction:
    - type = "TAX_WITHHOLDING"
    - amount = withholding_amount
    - description = "US tax withholding (30%)"
```

**Rule 6.3.3.2: Tax Form Requirements**
```
US Suppliers:
  - Must submit W-9 form
  - Receive 1099-K if meet thresholds

Non-US Suppliers:
  - Must submit W-8BEN or W-8BEN-E
  - Can claim tax treaty benefits (reduced withholding)

ENFORCEMENT:
  - IF no tax form submitted:
    - After $600 in revenue: Block payouts until form submitted
    - After $1000 in revenue: Suspend account until compliant
```

### 6.4 Revenue Reporting

**Supplier Revenue Dashboard** includes:

**Real-Time Metrics**:
- Today's revenue (live)
- Yesterday's revenue
- This week's revenue
- This month's revenue
- Lifetime revenue

**Revenue Breakdown**:
- Revenue by store
- Revenue by device
- Revenue by hour of day (heatmap)
- Revenue by advertiser
- Revenue by campaign category

**Payout History**:
- All past payouts (date, amount, status)
- Pending payouts
- Next scheduled payout
- Estimated payout amount

**Downloadable Reports**:
- CSV export of impressions
- Monthly revenue summary (PDF)
- Tax documents (1099-K, etc.)

---

## 7. Competitor Blocking Rules

### 7.1 Overview

Suppliers can define **Competitor Blocking Rules** to prevent direct competitors from advertising on their devices.

**Example**: A Nike store can block ads from Adidas, Reebok, and other athletic shoe brands.

### 7.2 Blocking Rule Entity

```typescript
interface CompetitorBlockingRule {
  rule_id: string                        // UUID
  supplier_id: string                    // FK to supplier
  store_id: string | null                // FK to store (null = applies to all stores)

  // Rule Configuration
  rule_name: string                      // "Block Athletic Competitors"
  rule_type: BlockingRuleType            // ADVERTISER | INDUSTRY | KEYWORD | CUSTOM
  is_active: boolean

  // Blocking Criteria
  blocked_advertiser_ids: string[]       // Specific advertiser IDs to block
  blocked_industry_categories: string[]  // ["Athletic Footwear", "Sportswear"]
  blocked_keywords: string[]             // ["Adidas", "Reebok", "Puma"]

  // Scope
  applies_to_all_stores: boolean         // If true, rule applies to all supplier's stores
  specific_store_ids: string[]           // If applies_to_all_stores = false, list of store IDs

  // Metadata
  created_at: Date
  updated_at: Date
  created_by_user_id: string
}

enum BlockingRuleType {
  ADVERTISER = "ADVERTISER",       // Block specific advertisers
  INDUSTRY = "INDUSTRY",           // Block entire industry categories
  KEYWORD = "KEYWORD",             // Block based on keywords in campaign/content
  CUSTOM = "CUSTOM"                // Custom rules (advanced)
}
```

### 7.3 Blocking Rule Application

#### 7.3.1 Campaign Matching

**Rule 7.3.1.1: Pre-Matching Filter**
```
WHEN campaign is being matched to devices:
  FOR EACH device in matching pool:
    1. GET supplier_id from device
    2. FETCH all active blocking rules for supplier

    3. FOR EACH blocking rule:
       - IF rule applies to device's store:
         - CHECK if campaign violates rule:
           - advertiser_id in blocked_advertiser_ids
           - campaign.industry_category in blocked_industry_categories
           - campaign.name or content contains blocked_keywords

       - IF violation detected:
         - EXCLUDE device from campaign matching pool
         - LOG exclusion reason
```

**Rule 7.3.1.2: Keyword Matching**
```
Keyword blocking uses case-insensitive partial matching:

EXAMPLE:
  blocked_keywords = ["Adidas", "Nike"]

  BLOCKED:
    - Campaign name: "Adidas Spring Sale"
    - Campaign name: "New Nike Shoes"
    - Content file name: "adidas_banner.png"
    - Advertiser name: "Nike Inc."

  NOT BLOCKED:
    - Campaign name: "Athletic Shoe Sale" (no keyword match)
```

**Rule 7.3.1.3: Industry Category Blocking**
```
Industry categories follow hierarchical structure:

EXAMPLE:
  blocked_industry_categories = ["Athletic Footwear"]

  BLOCKED:
    - Campaign with industry = "Athletic Footwear"
    - Campaign with subcategory under Athletic Footwear

  NOT BLOCKED:
    - Campaign with industry = "Footwear" (broader category)
    - Campaign with industry = "Sportswear" (sibling category)
```

### 7.4 Default Blocking Rules

**Rule 7.4.1: Automatic Competitor Detection**
```
Platform suggests default blocking rules:

WHEN supplier registers:
  - ANALYZE supplier.business_name and store.primary_category
  - IDENTIFY likely competitors from advertiser database
  - SUGGEST blocking rules (supplier can accept/reject)

EXAMPLE:
  Supplier: "Whole Foods Market"
  Store category: "Grocery - Organic"

  SUGGESTED RULES:
    - Block advertisers: Trader Joe's, Sprouts, Fresh Market
    - Block industry: Grocery Stores (direct competitors)
    - Allow: Food brands (non-competing)
```

**Rule 7.4.2: Same-Brand Protection**
```
AUTOMATIC RULE (cannot be disabled):
  - Supplier's own brand is automatically blocked
  - Prevents advertising own stores to own store visitors

EXAMPLE:
  Supplier: Starbucks
  - All campaigns from advertiser "Starbucks" blocked on Starbucks devices

EXCEPTION:
  - Supplier can allow their own campaigns if explicitly requested
  - Requires "ALLOW_OWN_BRAND" setting to be enabled
```

### 7.5 Rule Management

**Rule 7.5.1: Rule Priority**
```
If multiple rules apply, use MOST RESTRICTIVE:

EXAMPLE:
  Rule 1: Block "Athletic Footwear" industry
  Rule 2: Allow advertiser "Nike" (explicit allowlist)

  RESULT: Nike is BLOCKED (industry rule is more restrictive)

OVERRIDE with ALLOWLIST:
  - Supplier can create explicit allowlist
  - Allowlist rules override blocking rules
```

**Rule 7.5.2: Rule Changes**
```
WHEN supplier creates or updates a blocking rule:
  - Changes take effect IMMEDIATELY
  - Current campaigns being served to devices NOT interrupted
  - Future impression matching uses new rules

NOTIFICATION to affected advertisers:
  - IF campaign was previously matched to supplier's devices
  - AND new rule blocks that campaign
  - NOTIFY advertiser: "Your campaign is no longer eligible for [Store Name]"
```

**Rule 7.5.3: Rule Limits**
```
Tier-based limits on blocking rules:

STARTER tier:
  - Max 5 blocking rules per supplier
  - Max 10 blocked advertisers total
  - Max 20 blocked keywords total

PROFESSIONAL tier:
  - Max 20 blocking rules per supplier
  - Max 50 blocked advertisers total
  - Max 100 blocked keywords total

ENTERPRISE tier:
  - Unlimited blocking rules
  - Unlimited blocked advertisers
  - Unlimited blocked keywords
  - Advanced custom rule logic
```

---

## 8. Supplier Performance Metrics

### 8.1 Performance Score Calculation

**Supplier Quality Score**: 0-100 score reflecting overall performance.

**Formula**:
```
quality_score = (
  device_uptime_score × 0.35 +
  revenue_performance_score × 0.25 +
  compliance_score × 0.20 +
  customer_rating_score × 0.10 +
  growth_score × 0.10
)
```

### 8.2 Component Scores

#### 8.2.1 Device Uptime Score

**Formula**:
```
device_uptime_score = average_device_uptime (%)

WHERE:
  average_device_uptime = (
    SUM(device_uptime_percentage for all devices) / total_devices
  )

  device_uptime_percentage = (
    (total_minutes_online / total_minutes_in_period) × 100
  )

PERIOD: Last 30 days
```

**Scoring**:
- Uptime ≥98%: Score = 100
- Uptime 95-97%: Score = 90
- Uptime 90-94%: Score = 75
- Uptime 85-89%: Score = 60
- Uptime <85%: Score = 40

#### 8.2.2 Revenue Performance Score

**Formula**:
```
revenue_performance_score = (
  (actual_revenue / expected_revenue) × 100
)

WHERE:
  expected_revenue = (
    total_devices ×
    average_daily_visitors ×
    platform_average_cpm ×
    30 days
  )

  actual_revenue = supplier.total_revenue_last_30_days
```

**Scoring**:
- Actual ≥ Expected: Score = 100
- Actual 80-99% of Expected: Score = 80
- Actual 60-79% of Expected: Score = 60
- Actual <60% of Expected: Score = 40

#### 8.2.3 Compliance Score

**Formula**:
```
compliance_score = 100 - (violations × 10)

WHERE:
  violations = COUNT of compliance issues in last 90 days

COMPLIANCE ISSUES:
  - Device relocation without update
  - Tampering with device
  - Fraudulent impression reporting
  - Violation of content policies
  - Late document submission
```

**Scoring**:
- 0 violations: Score = 100
- 1 violation: Score = 90
- 2 violations: Score = 80
- 3+ violations: Score = 70 or less

#### 8.2.4 Customer Rating Score

Advertisers can rate supplier quality (if they run campaigns on supplier devices):

**Rating Categories**:
- Device quality (screen resolution, clarity)
- Store environment (cleanliness, lighting)
- Content display (proper timing, no glitches)
- Location accuracy (device at registered location)

**Formula**:
```
customer_rating_score = (
  AVG(advertiser_ratings for supplier) × 20
)

WHERE:
  advertiser_ratings = 1-5 stars

EXAMPLE:
  Average rating = 4.5 stars
  Score = 4.5 × 20 = 90
```

#### 8.2.5 Growth Score

**Formula**:
```
growth_score = MIN(100, (
  (current_month_revenue / previous_month_revenue - 1) × 200
))

EXAMPLES:
  - 50% growth: Score = 100
  - 25% growth: Score = 50
  - 0% growth: Score = 0
  - Negative growth: Score = 0
```

### 8.3 Performance Tiers

**Tier Assignment** based on quality_score:

| Tier | Score Range | Benefits |
|------|-------------|----------|
| ⭐⭐⭐⭐⭐ Platinum | 90-100 | Priority support, higher revenue share (85%), early access to features |
| ⭐⭐⭐⭐ Gold | 80-89 | Priority support, standard revenue share (80%) |
| ⭐⭐⭐ Silver | 70-79 | Standard support, standard revenue share (80%) |
| ⭐⭐ Bronze | 60-69 | Standard support, standard revenue share (80%), improvement plan required |
| ⭐ Poor | <60 | Account under review, possible suspension |

**Rule 8.3.1: Platinum Tier Bonus**
```
Suppliers with quality_score ≥ 90 for 3 consecutive months:
  - INCREASE revenue_share_percentage to 85%
  - Additional 5% revenue boost

MAINTAIN Platinum status:
  - IF score drops below 90: 30-day grace period
  - IF score < 90 after grace period: Revert to standard 80% share
```

**Rule 8.3.2: Poor Performance Action**
```
IF quality_score < 60 for 2 consecutive months:
  1. SEND warning email to supplier
  2. REQUIRE improvement plan submission within 7 days
  3. Assign dedicated support to help improve

IF no improvement after 30 days:
  4. SUSPEND new device registrations
  5. Reduce priority in campaign matching

IF no improvement after 60 days:
  6. SUSPEND supplier account
  7. Revenue held pending resolution
```

---

## 9. Account Tiers & Limits

### 9.1 Tier Structure

| Feature | STARTER | PROFESSIONAL | ENTERPRISE |
|---------|---------|--------------|------------|
| **Pricing** | Free | $99/month | Custom (starts at $499/month) |
| **Max Devices** | 1-5 | 6-50 | 51+ (unlimited) |
| **Max Stores** | 1-3 | 4-20 | Unlimited |
| **Revenue Share** | 80% | 80% (85% if Platinum) | 85% base (90% if Platinum) |
| **Payment Schedule** | Monthly | Weekly/Biweekly/Monthly | Weekly/Daily (custom) |
| **Minimum Payout** | $100 | $50 | $25 |
| **Blocking Rules** | 5 rules | 20 rules | Unlimited |
| **Support** | Email (48h SLA) | Email + Chat (24h SLA) | Dedicated account manager (4h SLA) |
| **Analytics** | Basic (30-day history) | Advanced (1-year history) | Premium (unlimited history, custom reports) |
| **API Access** | No | Yes (rate limited) | Yes (higher limits) |
| **Custom Integrations** | No | No | Yes |

### 9.2 Tier Limits Enforcement

**Rule 9.2.1: Device Limit**
```
WHEN supplier attempts to register new device:
  IF total_devices >= max_devices_for_tier:
    - REJECT registration
    - PROMPT: "You've reached your device limit for the {tier} tier.
               Upgrade to {next_tier} to add more devices."
    - SHOW upgrade options
```

**Rule 9.2.2: Store Limit**
```
WHEN supplier attempts to register new store:
  IF total_stores >= max_stores_for_tier:
    - REJECT registration
    - PROMPT: "You've reached your store limit for the {tier} tier.
               Upgrade to {next_tier} to add more stores."
```

**Rule 9.2.3: Auto-Upgrade Suggestion**
```
WHEN supplier reaches 80% of tier limit:
  - NOTIFY supplier: "You're approaching your {tier} limits.
                     Consider upgrading to {next_tier}."
  - SHOW ROI calculation:
    - Current revenue
    - Potential revenue with more devices
    - Cost of upgrade
    - Net benefit
```

### 9.3 Tier Transitions

**Rule 9.3.1: Upgrade Process**
```
WHEN supplier upgrades tier:
  1. CHARGE prorated amount for current billing period
  2. UPDATE supplier.tier = new_tier
  3. APPLY new limits immediately
  4. SEND confirmation email with new tier benefits

EXAMPLE (Mid-month upgrade):
  - Current tier: STARTER ($0/month)
  - New tier: PROFESSIONAL ($99/month)
  - Upgrade date: 15th of month
  - Prorated charge: $99 × (15 days / 30 days) = $49.50
```

**Rule 9.3.2: Downgrade Process**
```
WHEN supplier downgrades tier:
  1. SCHEDULE downgrade for end of current billing period
  2. IF supplier exceeds new tier limits:
     - NOTIFY: "You have {X} devices but new tier allows {Y}.
                Please deactivate {X-Y} devices before downgrade."
     - PREVENT downgrade until compliant
  3. ON downgrade date:
     - UPDATE supplier.tier = new_tier
     - APPLY new limits
     - REFUND prorated amount (if applicable)
```

**Rule 9.3.3: Enterprise Tier Onboarding**
```
Enterprise tier requires sales process:
  - Supplier submits inquiry form
  - Sales call scheduled within 2 business days
  - Custom pricing negotiated based on:
    - Number of devices
    - Store count
    - Expected monthly revenue
    - Special requirements (custom integrations, SLAs)
  - Contract signed
  - Account manually upgraded by admin
```

---

## 10. Compliance & Verification

### 10.1 Ongoing Compliance Requirements

**Rule 10.1.1: Annual Re-Verification**
```
ALL suppliers must re-verify annually:
  - Submit updated business documents
  - Confirm bank account still valid
  - Update tax forms (W-9/W-8)
  - Verify store locations still operational

TIMELINE:
  - Notification sent 30 days before verification_anniversary
  - Grace period: 14 days after anniversary
  - IF not completed: Suspend payouts until compliant
```

**Rule 10.1.2: Document Expiration**
```
Some documents have expiration dates:
  - Business license: Expires per state regulations
  - Insurance certificates: Annual or biennial
  - Food service permits (restaurants): Annual

SYSTEM TRACKING:
  - Monitor document expiration dates
  - Send reminder 30 days before expiration
  - Require upload of renewed document
  - IF expired: Flag account for review (may suspend)
```

### 10.2 Fraud Detection

**Rule 10.2.1: Suspicious Activity Monitoring**
```
Platform monitors for fraud indicators:

RED FLAGS:
  - Sudden spike in impressions (>3x normal rate)
  - Devices reporting impressions outside operating hours
  - Abnormal impression patterns (e.g., exactly same count every hour)
  - Device location doesn't match registered store location
  - Multiple devices from same IP address (unless expected)
  - High rate of disputed impressions

AUTOMATED RESPONSE:
  - Flag account for manual review
  - Hold payouts temporarily
  - Request verification (device photos, location proof)
  - If confirmed fraud: Permanent ban + clawback of fraudulent revenue
```

**Rule 10.2.2: Location Verification Spot Checks**
```
RANDOM spot checks on 5% of devices per month:
  - Request GPS location from device
  - Compare to registered store location
  - IF mismatch > 500 meters:
    - Suspend device
    - Request supplier explanation + proof (photos)
    - Review last 30 days of impressions for fraud
```

**Rule 10.2.3: Quality Verification**
```
Random quality checks:
  - Request screenshot of current content being displayed
  - Verify content matches impression records
  - Check screen quality (resolution, brightness)

FAILURE CRITERIA:
  - Screen not displaying ads (showing other content)
  - Screen quality below minimum standards (damaged, dim)
  - Content not matching impression logs

PENALTY:
  - Quality score reduction
  - Payouts held pending investigation
  - Possible device suspension
```

### 10.3 Prohibited Activities

**Suppliers are PROHIBITED from**:
- Tampering with devices or impression reporting
- Relocating devices without updating platform
- Creating artificial impressions (fraud)
- Sharing account access with unauthorized parties
- Displaying inappropriate content on devices
- Interfering with competitor blocking rules (e.g., accepting payments from blocked advertisers to bypass rules)

**Consequences**:
- First violation: Warning + quality score reduction
- Second violation: Suspension (14-30 days) + revenue hold
- Third violation: Permanent ban + revenue forfeiture

---

## 11. Account Status Management

### 11.1 Status Transitions

```
PENDING_REGISTRATION → ACTIVE
                          ↓
                      INACTIVE (voluntary)
                          ↓
                      SUSPENDED (temporary)
                          ↓
                  PERMANENTLY_BANNED
```

### 11.2 Suspension

**Rule 11.2.1: Suspension Triggers**
```
Supplier can be SUSPENDED for:
  - Quality score < 60 for 60+ days (no improvement)
  - Compliance violations (2+ violations in 90 days)
  - Fraudulent activity (suspected or confirmed)
  - Non-payment of platform fees (if applicable)
  - Legal disputes or investigations
  - Failure to submit required documents (annual re-verification)

DURING SUSPENSION:
  - All devices stop serving ads
  - No new impressions recorded
  - Payouts held (available_balance frozen)
  - Supplier cannot login or make changes

NOTIFICATION:
  - Email sent immediately with suspension reason
  - Clear steps to resolve
  - Contact info for support
```

**Rule 11.2.2: Suspension Resolution**
```
TO LIFT suspension:
  1. Supplier resolves issue (submit docs, improve quality, etc.)
  2. Supplier submits reinstatement request
  3. Platform reviews (1-3 business days)
  4. IF approved:
     - Reactivate account
     - Resume ad serving
     - Release held funds (if no outstanding disputes)
  5. IF denied:
     - Provide additional requirements
     - Escalate to permanent ban if unresolvable
```

### 11.3 Voluntary Inactivation

**Rule 11.3.1: Pausing Account**
```
Supplier can voluntarily set account to INACTIVE:
  - All devices stop serving ads
  - No new impressions
  - Payouts continue for existing pending_balance
  - Account data retained

USE CASES:
  - Seasonal closure (e.g., restaurant closed for renovations)
  - Temporary business pause
  - Testing/troubleshooting

REACTIVATION:
  - Supplier clicks "Reactivate" in dashboard
  - Devices resume serving ads immediately
  - No re-verification required (unless >1 year inactive)
```

### 11.4 Permanent Ban

**Rule 11.4.1: Ban Reasons**
```
Supplier PERMANENTLY BANNED for:
  - Confirmed fraud (fake impressions, tampered devices)
  - Severe compliance violations (3+ violations)
  - Legal violations (displaying illegal content, etc.)
  - Repeated quality failures (3+ suspensions with no improvement)
  - Attempted circumvention of platform controls

EFFECTS:
  - Account closed permanently
  - All devices decommissioned
  - Revenue forfeited (if fraud-related)
  - Supplier added to global ban list (cannot re-register)
```

**Rule 11.4.2: Appeal Process**
```
Banned suppliers can appeal ONCE:
  - Submit appeal within 30 days of ban
  - Provide evidence/explanation
  - Platform reviews appeal (5-10 business days)
  - Final decision (no further appeals)

RARELY overturned (only if clear error or extenuating circumstances)
```

---

## 12. Integration Points

### 12.1 Integration with Other Modules

#### 12.1.1 Wallet Module
```
DEPENDENCIES:
  - Each supplier has exactly ONE wallet
  - Wallet created automatically when supplier status = "ACTIVE"

INTERACTIONS:
  - Revenue from impressions → wallet.pending_balance
  - After 7 days → wallet.available_balance
  - Payouts → wallet.available_balance decreases
  - Refunds/chargebacks → wallet deductions
```

#### 12.1.2 Device Module
```
DEPENDENCIES:
  - Devices belong to supplier (via store)
  - Device registration requires active supplier account

INTERACTIONS:
  - Supplier manages device lifecycle (register, configure, decommission)
  - Device health status → affects supplier quality score
  - Device impressions → supplier revenue
```

#### 12.1.3 Impression Module
```
INTERACTIONS:
  - Verified impressions generate supplier revenue
  - Supplier_id associated with each impression
  - Impression disputes may hold supplier payouts
```

#### 12.1.4 Campaign Module
```
INTERACTIONS:
  - Supplier blocking rules filter campaigns from matching
  - Campaign targeting criteria must align with supplier stores
  - Supplier performance affects campaign matching priority
```

### 12.2 External Integrations

#### 12.2.1 Payment Processors
```
INTEGRATIONS:
  - Stripe Connect: Payouts to bank accounts
  - PayPal: Payouts to PayPal accounts
  - ACH: Direct bank transfers (US)
  - Wire Transfer: International payouts

WEBHOOKS:
  - payout.succeeded → Update withdrawal_request status
  - payout.failed → Refund to wallet, notify supplier
  - payout.pending → Track in-transit status
```

#### 12.2.2 Tax Services
```
INTEGRATIONS:
  - TaxJar / Avalara: Sales tax calculation (if applicable)
  - IRS TIN verification: Validate EIN/SSN
  - 1099 generation: Annual tax form for suppliers

DATA SYNC:
  - Total revenue per supplier (for 1099-K thresholds)
  - Tax withholding amounts (non-US suppliers)
```

#### 12.2.3 KYC/Verification Services
```
INTEGRATIONS:
  - Stripe Identity: Identity verification
  - Plaid: Bank account verification
  - Jumio / Onfido: Document verification

WORKFLOWS:
  - Supplier uploads documents → Sent to verification service
  - Service returns verification result
  - Manual review if automated check fails
```

---

## 13. Edge Cases & Special Scenarios

### 13.1 Multi-Location Franchises

**Scenario**: Franchise owner operates multiple locations of same brand.

**Rules**:
```
FRANCHISE HANDLING:
  - Single supplier account for all franchise locations
  - Each location registered as separate store
  - Shared blocking rules across all stores (default)
  - Consolidated payouts (one wallet for all locations)

BENEFITS:
  - Centralized management
  - Volume-based tier (total devices across all locations)
  - Single payout for all locations

EXAMPLE:
  - Supplier: "John's Pizza Franchises Inc."
  - Stores:
    - "John's Pizza - Downtown" (3 devices)
    - "John's Pizza - Westside" (2 devices)
    - "John's Pizza - Airport" (4 devices)
  - Total: 9 devices → PROFESSIONAL tier
```

### 13.2 Seasonal Businesses

**Scenario**: Business operates only part of the year (e.g., ski resort, summer camp).

**Rules**:
```
SEASONAL HANDLING:
  - Supplier can set "seasonal schedule" for stores
  - During off-season:
    - Stores marked INACTIVE
    - Devices stop serving ads
    - No impact on quality score (excluded from uptime calculation)
    - Minimum subscription fee waived (for PROFESSIONAL/ENTERPRISE)

  - During on-season:
    - Stores reactivated
    - Devices resume serving ads
    - Full platform access

CONFIGURATION:
  - Set operating_season:
    - start_month, end_month
    - EXAMPLE: June-August for summer camp
```

### 13.3 Device Ownership Changes

**Scenario**: Supplier sells business or transfers device ownership.

**Rules**:
```
OWNERSHIP TRANSFER:
  1. Current supplier initiates transfer request
  2. New supplier (must have active account) accepts transfer
  3. Device re-paired with new supplier account:
     - Device_id remains same (device identity preserved)
     - supplier_id updated
     - Historical data retained but not accessible to new owner
  4. Revenue settlement:
     - Final payout issued to original supplier
     - New supplier starts earning from transfer date

RESTRICTIONS:
  - Cannot transfer device if active campaigns running (wait for completion)
  - Both parties must have verified accounts
  - Platform charges $25 transfer fee
```

### 13.4 Store Closure or Relocation

**Scenario**: Store permanently closes or moves to new location.

#### 13.4.1 Permanent Closure
```
WHEN store closes permanently:
  1. Supplier marks store as "CLOSED"
  2. All devices at store decommissioned
  3. Final revenue calculated and paid out
  4. Store data archived (cannot be reactivated)

EFFECTS:
  - total_devices decremented
  - May affect tier (if devices drop below threshold)
  - Historical data retained for reporting
```

#### 13.4.2 Relocation
```
WHEN store relocates:
  1. Supplier updates store address
  2. Devices must re-verify location (GPS check)
  3. IF new address significantly different (>5 miles):
     - Blocking rules may need review (different competitor landscape)
     - Campaign matching re-evaluated (targeting criteria)
  4. Devices resume normal operation once verified

NO INTERRUPTION to revenue if properly updated
```

### 13.5 Disputed Impressions

**Scenario**: Advertiser disputes impressions, claims device wasn't displaying ad.

**Rules**:
```
WHEN impression dispute filed:
  1. CREATE ImpressionDispute record
  2. HOLD supplier revenue for disputed impressions (move to held_balance)
  3. REQUEST proof from supplier:
     - Device screenshot at impression timestamp
     - Device location data
     - Heartbeat logs
  4. INVESTIGATE:
     - Compare proof to impression records
     - Check device health status at time of impression
     - Review advertiser's claim evidence
  5. RESOLUTION:
     - IF supplier wins: Release held revenue
     - IF advertiser wins: Refund advertiser, revenue forfeited
     - IF inconclusive: Split 50/50

TIMELINE:
  - Resolution target: 14 days
  - Supplier has 7 days to submit proof
```

### 13.6 Revenue Clawback

**Scenario**: Platform discovers fraudulent impressions after payout.

**Rules**:
```
WHEN fraud confirmed AFTER payout:
  1. CALCULATE total fraudulent revenue
  2. CREATE negative WalletTransaction (CHARGEBACK)
  3. DEDUCT from supplier's available_balance
  4. IF available_balance insufficient:
     - Create negative balance (supplier owes platform)
     - BLOCK future payouts until balance positive
     - SEND invoice for amount owed
  5. IF supplier refuses to pay or disputes:
     - SUSPEND account
     - Legal action may be pursued
     - Permanent ban if unresolved

PREVENTION:
  - Fraud detection during 7-day revenue hold period
  - Clawback reduces but doesn't eliminate risk
```

### 13.7 Multiple Bank Accounts

**Scenario**: Supplier wants to split payouts across multiple bank accounts.

**Rules**:
```
PROFESSIONAL and ENTERPRISE tiers can configure split payouts:
  - Add multiple payout methods
  - Set percentage split:
    - Bank Account A: 70%
    - Bank Account B: 30%
  - Minimum per account: $25

EXAMPLE:
  Total payout: $1,000
  - $700 → Bank A
  - $300 → Bank B

IF one account fails:
  - Redirect full amount to working account
  - Notify supplier to fix failed account
```

### 13.8 International Suppliers

**Scenario**: Supplier operates outside the United States.

**Rules**:
```
INTERNATIONAL SUPPLIERS:
  - All revenue calculated in USD
  - Payouts in USD (supplier's bank handles currency conversion)
  - Tax withholding: 30% (unless tax treaty)
  - Additional verification required:
    - Proof of business registration in home country
    - Translated documents (English) with certified translation
    - W-8BEN or W-8BEN-E form
  - Payout methods:
    - Wire transfer (fees apply)
    - PayPal (higher fees but faster)
    - Stripe Connect (if available in country)

COUNTRY RESTRICTIONS:
  - Platform may restrict operations in certain countries (sanctions, high fraud risk)
  - Current restricted countries: [List maintained by compliance team]
```

---

## 14. Business Formulas

### 14.1 Revenue Calculation

**Per-Impression Revenue** (Supplier's Share):
```
impression_cost = campaign.cpm / 1000
supplier_revenue = impression_cost × 0.80
platform_revenue = impression_cost × 0.20

EXAMPLE:
  campaign.cpm = $5.00
  impression_cost = $5.00 / 1000 = $0.005
  supplier_revenue = $0.005 × 0.80 = $0.004
  platform_revenue = $0.005 × 0.20 = $0.001
```

**Daily Revenue Estimate**:
```
estimated_daily_revenue_per_device = (
  average_hourly_impressions ×
  operating_hours_per_day ×
  average_cpm ×
  0.80
) / 1000

EXAMPLE:
  average_hourly_impressions = 50
  operating_hours_per_day = 12
  average_cpm = $4.00

  estimated_daily_revenue = (50 × 12 × $4.00 × 0.80) / 1000
                          = (2400 × 0.80) / 1000
                          = 1920 / 1000
                          = $1.92 per device per day
```

**Monthly Revenue Projection**:
```
estimated_monthly_revenue = (
  total_devices ×
  estimated_daily_revenue_per_device ×
  30
)

EXAMPLE:
  total_devices = 10
  estimated_daily_revenue_per_device = $1.92

  estimated_monthly_revenue = 10 × $1.92 × 30 = $576
```

### 14.2 Quality Score Formula

```
quality_score = (
  device_uptime_score × 0.35 +
  revenue_performance_score × 0.25 +
  compliance_score × 0.20 +
  customer_rating_score × 0.10 +
  growth_score × 0.10
)

WHERE:
  device_uptime_score = 0-100 (based on % uptime)
  revenue_performance_score = 0-100 (actual vs expected revenue)
  compliance_score = 0-100 (100 - violations × 10)
  customer_rating_score = 0-100 (avg_rating × 20)
  growth_score = 0-100 (revenue growth × 200)
```

### 14.3 Payout Calculation

**Net Payout** (after tax withholding):
```
gross_payout = wallet.available_balance

IF supplier.tax_withholding_required:
  withholding_rate = 0.30  // 30% for non-US
  withholding_amount = gross_payout × withholding_rate
  net_payout = gross_payout - withholding_amount
ELSE:
  net_payout = gross_payout

EXAMPLE (US Supplier):
  gross_payout = $1,000
  withholding = $0
  net_payout = $1,000

EXAMPLE (Non-US Supplier, no treaty):
  gross_payout = $1,000
  withholding = $1,000 × 0.30 = $300
  net_payout = $700
```

**Payout with Fees** (manual payout under threshold):
```
IF manual_payout AND gross_payout < minimum_payout_threshold:
  fee = $5.00
  net_payout = gross_payout - fee

EXAMPLE:
  gross_payout = $40 (under $50 threshold)
  fee = $5
  net_payout = $35
```

### 14.4 Device Limit Based on Store Size

```
max_devices_allowed = CALCULATE based on square_footage:

IF square_footage < 1000:
  max = 1
ELSE IF square_footage < 3000:
  max = 2
ELSE IF square_footage < 5000:
  max = 3
ELSE IF square_footage < 10000:
  max = 5
ELSE:
  max = 10

OVERRIDE for ENTERPRISE tier: Custom negotiated limit
```

### 14.5 Revenue Share Adjustment (Platinum Tier)

```
IF supplier.quality_score >= 90 FOR 3_consecutive_months:
  revenue_share_percentage = 0.85
ELSE:
  revenue_share_percentage = 0.80

RECALCULATION:
  - Checked monthly on 1st of month
  - Takes effect immediately for new impressions
  - Does NOT retroactively adjust past revenue
```

### 14.6 Uptime Score Calculation

```
FOR EACH device:
  uptime_percentage = (
    total_minutes_online / total_minutes_in_period
  ) × 100

average_device_uptime = (
  SUM(uptime_percentage for all devices) / total_devices
)

device_uptime_score = MAP average_device_uptime:
  ≥98%: 100
  95-97%: 90
  90-94%: 75
  85-89%: 60
  <85%: 40

PERIOD: Last 30 days
EXCLUDE: Time in MAINTENANCE mode
EXCLUDE: Seasonal stores during off-season
```

---

## Appendix A: Related Business Rules Documents

This document should be read in conjunction with:
- [Business Rules: Campaign Management](business-rules-campaign.md)
- [Business Rules: Device Management](business-rules-device.md)
- [Business Rules: Impression Recording](business-rules-impression.md)
- [Business Rules: Wallet & Payment](business-rules-wallet.md)
- [Business Rules: Advertiser Management](business-rules-advertiser.md)

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| Supplier | Retail business owner providing store locations and devices for advertising |
| Store | Physical retail location where devices are installed |
| Device | Digital signage hardware displaying advertising content |
| Revenue Share | Percentage split of impression revenue (80% supplier, 20% platform) |
| Quality Score | 0-100 score reflecting supplier performance across multiple dimensions |
| Blocking Rule | Supplier-defined rule to prevent competitor ads from displaying on their devices |
| Payout | Transfer of revenue from supplier's wallet to their bank account |
| Verification | Process of validating supplier business documents and identity |
| Tier | Account level (STARTER/PROFESSIONAL/ENTERPRISE) with different limits and pricing |
| Uptime | Percentage of time devices are online and operational |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-23 | Business Rules Team | Initial draft - comprehensive supplier management rules |

---

**END OF DOCUMENT**
