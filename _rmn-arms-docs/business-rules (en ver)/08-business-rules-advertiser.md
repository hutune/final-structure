# Advertiser Module - Business Rules Document

**Version**: 1.0
**Date**: 2026-01-23
**Status**: Draft for Review
**Owner**: Product Team

---

## Table of Contents

1. [Overview](#overview)
2. [Domain Entities](#domain-entities)
3. [Advertiser Lifecycle](#advertiser-lifecycle)
4. [Business Rules](#business-rules)
5. [Onboarding & Registration](#onboarding--registration)
6. [Account Tiers & Limits](#account-tiers--limits)
7. [Verification & KYC](#verification--kyc)
8. [Team Management](#team-management)
9. [Compliance & Restrictions](#compliance--restrictions)
10. [Account Status Management](#account-status-management)
11. [Edge Cases & Error Handling](#edge-cases--error-handling)
12. [Validation Rules](#validation-rules)

---

## Overview

### Purpose
This document defines ALL business rules for the Advertiser module, covering account management, onboarding, verification, team collaboration, and compliance.

### Scope
- Advertiser account creation and onboarding
- Account verification and KYC
- Account tier system and limits
- Team member management
- Compliance and content restrictions
- Account status lifecycle
- Suspension and ban procedures

### Out of Scope
- Campaign creation (see Campaign module)
- Wallet management (see Wallet module)
- Content upload (see Content module)

### Key Concepts
- **Advertiser**: Business or individual running ad campaigns
- **Account Tier**: Service level (Free, Basic, Premium, Enterprise)
- **Verification**: KYC process for higher limits
- **Team Member**: User with delegated access to advertiser account
- **Compliance**: Content and industry restrictions

---

## Domain Entities

### 1. Advertiser

**Definition**: Business or individual account for running advertising campaigns.

**Attributes**:

| Field | Type | Required | Default | Business Rule |
|-------|------|----------|---------|---------------|
| `id` | UUID | Yes | Auto-generated | Immutable |
| `user_id` | UUID | Yes | - | Owner user account |
| `company_name` | String(100) | No | null | Optional for individuals |
| `business_type` | Enum | Yes | INDIVIDUAL | See [Business Types](#business-types) |
| `industry` | Enum | Yes | - | See [Industries](#industries) |
| `website_url` | String(200) | No | null | Must be valid URL |
| `description` | Text | No | null | Max 500 characters |
| `brand_name` | String(100) | Yes | - | Used for competitor blocking |
| `account_tier` | Enum | Yes | FREE | FREE/BASIC/PREMIUM/ENTERPRISE |
| `verification_status` | Enum | Yes | UNVERIFIED | See [Verification Status](#verification-status) |
| `verified_at` | DateTime | No | null | When KYC completed |
| `tax_id` | String(50) | No | null | EIN/VAT number (encrypted) |
| `billing_address` | JSON | Yes | - | Required for tax |
| `billing_contact_name` | String(100) | Yes | - | Invoice recipient |
| `billing_contact_email` | String(100) | Yes | - | Invoice delivery |
| `billing_contact_phone` | String(20) | No | null | Optional |
| `payment_terms` | Enum | Yes | PREPAID | PREPAID/NET30/NET60 |
| `credit_limit` | Decimal(12,2) | Yes | 0.00 | For NET payment terms |
| `total_spent` | Decimal(12,2) | Yes | 0.00 | Lifetime campaign spending |
| `total_impressions` | BigInt | Yes | 0 | Lifetime impressions |
| `active_campaigns_count` | Integer | Yes | 0 | Current active campaigns |
| `status` | Enum | Yes | ACTIVE | See [Account Status](#account-status) |
| `suspended_at` | DateTime | No | null | When suspended |
| `suspension_reason` | String(200) | No | null | Why suspended |
| `banned_at` | DateTime | No | null | When permanently banned |
| `ban_reason` | String(200) | No | null | Why banned |
| `account_manager_id` | UUID | No | null | Assigned account manager (Enterprise) |
| `referral_code` | String(20) | Yes | Auto-generated | Unique referral code |
| `referred_by` | UUID | No | null | Referrer advertiser ID |
| `created_at` | DateTime | Yes | NOW() | Immutable |
| `updated_at` | DateTime | Yes | NOW() | Auto-updated |

#### Business Types
```
- INDIVIDUAL: Personal account
- SMALL_BUSINESS: < 10 employees
- MEDIUM_BUSINESS: 10-100 employees
- LARGE_BUSINESS: 100-1000 employees
- ENTERPRISE: > 1000 employees
- AGENCY: Marketing agency managing multiple brands
```

#### Industries
```
- RETAIL: Retail stores
- FOOD_BEVERAGE: Restaurants, food brands
- ELECTRONICS: Electronics brands
- FASHION: Fashion & apparel
- HEALTH_BEAUTY: Health & beauty products
- HOME_GARDEN: Home & garden products
- AUTOMOTIVE: Automotive brands
- ENTERTAINMENT: Entertainment & media
- FINANCIAL_SERVICES: Banks, insurance, fintech
- TELECOM: Telecom providers
- REAL_ESTATE: Real estate agencies
- EDUCATION: Educational institutions
- TRAVEL: Travel & hospitality
- OTHER: Other industries
```

#### Verification Status
```
- UNVERIFIED: No KYC submitted
- PENDING: Documents submitted, under review
- VERIFIED: KYC approved
- REJECTED: KYC rejected
- EXPIRED: Verification expired (re-verify required)
```

#### Account Status
```
- ACTIVE: Normal operation
- SUSPENDED: Temporarily disabled
- BANNED: Permanently disabled
- CLOSED: User-initiated closure
```

---

### 2. AdvertiserVerification

**Definition**: KYC verification record for advertiser.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `advertiser_id` | UUID | Yes | Subject of verification |
| `verification_type` | Enum | Yes | INDIVIDUAL/BUSINESS |
| `submitted_at` | DateTime | Yes | When submitted |
| `reviewed_at` | DateTime | No | When admin reviewed |
| `reviewed_by` | UUID | No | Admin reviewer |
| `status` | Enum | Yes | PENDING/APPROVED/REJECTED |
| `rejection_reason` | String(200) | No | Why rejected |
| `documents` | JSON | Yes | Array of document metadata |
| `verification_provider` | Enum | No | STRIPE_IDENTITY/MANUAL |
| `provider_verification_id` | String(100) | No | External verification ID |
| `risk_score` | Integer | No | 0-100 (higher = riskier) |
| `expires_at` | DateTime | No | When re-verification needed |
| `notes` | Text | No | Admin notes |

---

### 3. TeamMember

**Definition**: User granted access to advertiser account.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `advertiser_id` | UUID | Yes | Parent advertiser |
| `user_id` | UUID | Yes | Team member user |
| `role` | Enum | Yes | See [Team Roles](#team-roles) |
| `permissions` | JSON | Yes | Granular permissions |
| `invited_by` | UUID | Yes | Who sent invitation |
| `invited_at` | DateTime | Yes | When invited |
| `accepted_at` | DateTime | No | When invitation accepted |
| `status` | Enum | Yes | PENDING/ACTIVE/REVOKED |
| `last_access_at` | DateTime | No | Last login |

#### Team Roles
```
- OWNER: Full access (account creator)
- ADMIN: Full access except billing
- CAMPAIGN_MANAGER: Create/manage campaigns
- CONTENT_MANAGER: Upload/manage content
- ANALYST: Read-only access to reports
- VIEWER: Read-only access (no modifications)
```

---

### 4. AccountTierConfig

**Definition**: Configuration for account tier limits.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `tier` | Enum | Yes | FREE/BASIC/PREMIUM/ENTERPRISE |
| `max_campaigns_concurrent` | Integer | Yes | Max active campaigns |
| `max_budget_per_campaign` | Decimal(12,2) | Yes | Per-campaign budget limit |
| `max_daily_spend` | Decimal(12,2) | Yes | Daily spending limit |
| `max_monthly_spend` | Decimal(12,2) | Yes | Monthly spending limit |
| `max_content_assets` | Integer | Yes | Max content uploads |
| `max_team_members` | Integer | Yes | Max team size |
| `support_level` | Enum | Yes | COMMUNITY/EMAIL/PRIORITY/DEDICATED |
| `api_access` | Boolean | Yes | API access enabled |
| `advanced_analytics` | Boolean | Yes | Advanced reports |
| `white_label` | Boolean | Yes | White-label option |
| `monthly_fee` | Decimal(10,2) | Yes | Subscription fee (0 for FREE) |

---

## Advertiser Lifecycle

### Registration & Onboarding Flow

```
Step 1: Email Registration
  User enters: Email + Password
  System sends verification email
  Status: UNVERIFIED

Step 2: Email Verification
  User clicks link in email
  Email marked as verified
  Redirect to onboarding

Step 3: Basic Profile Setup
  User provides:
    - Company/Brand name
    - Business type
    - Industry
    - Billing address

  System creates:
    - Advertiser record (tier: FREE)
    - Wallet (balance: 0)
    - Default permissions

  Status: ACTIVE (FREE tier)

Step 4: Optional KYC (for higher limits)
  User submits:
    - Government ID (individual)
    - Business registration (company)
    - Tax ID

  Admin reviews
  If approved: verification_status = VERIFIED
  Unlock: Higher spending limits

Step 5: Payment Method Setup
  User adds credit card or bank account
  Enables top-ups

Step 6: First Campaign
  Guided campaign creation
  Tutorial/tooltips
  Template suggestions

Status: ACTIVE, ready to advertise
```

---

## Business Rules

### Rule 1: Account Tier System

#### 1.1 Tier Limits

**FREE Tier**:
```
Limits:
- Max concurrent campaigns: 2
- Max budget per campaign: $500
- Max daily spend: $100
- Max monthly spend: $1,000
- Max content assets: 10
- Max team members: 1 (owner only)
- Support: Community forum
- API access: No
- Advanced analytics: No

Monthly fee: $0

Target: Small businesses, testing
```

**BASIC Tier**:
```
Limits:
- Max concurrent campaigns: 5
- Max budget per campaign: $2,000
- Max daily spend: $500
- Max monthly spend: $5,000
- Max content assets: 50
- Max team members: 3
- Support: Email (48h response)
- API access: No
- Advanced analytics: Yes

Monthly fee: $99

Target: Growing businesses
```

**PREMIUM Tier**:
```
Limits:
- Max concurrent campaigns: 20
- Max budget per campaign: $10,000
- Max daily spend: $2,000
- Max monthly spend: $50,000
- Max content assets: 200
- Max team members: 10
- Support: Priority email (24h response)
- API access: Yes
- Advanced analytics: Yes

Monthly fee: $499

Target: Established businesses
```

**ENTERPRISE Tier**:
```
Limits:
- Max concurrent campaigns: Unlimited
- Max budget per campaign: Custom
- Max daily spend: Custom
- Max monthly spend: Custom
- Max content assets: Unlimited
- Max team members: Unlimited
- Support: Dedicated account manager
- API access: Yes
- Advanced analytics: Yes
- White-label: Yes

Monthly fee: Custom (starts at $2,000)

Target: Large enterprises, agencies
```

#### 1.2 Tier Upgrade Process

```
Actor: Advertiser
Trigger: User clicks "Upgrade Account"

Process:
1. Display tier comparison:
   - Current tier benefits
   - Target tier benefits
   - Pricing
   - Feature differences

2. User selects target tier:
   POST /account/upgrade
   {
     "target_tier": "PREMIUM",
     "billing_cycle": "MONTHLY" // or ANNUAL (10% discount)
   }

3. Validation:
   ✓ target_tier > current_tier
   ✓ payment_method on file
   ✓ account status = ACTIVE

4. Calculate pricing:
   IF billing_cycle = "ANNUAL":
     annual_price = monthly_fee × 12 × 0.90
     charge_amount = annual_price
   ELSE:
     charge_amount = monthly_fee

5. Process payment:
   charge = process_subscription_payment(
     amount: charge_amount,
     interval: billing_cycle
   )

6. Update account:
   advertiser.account_tier = target_tier
   advertiser.updated_at = NOW()

   // Apply new limits immediately
   apply_tier_limits(advertiser, target_tier)

7. Notify user:
   Email: "Account upgraded to {target_tier}"
   Benefits: List of new features unlocked

Business Rules:
- Upgrade effective immediately
- Prorated billing for mid-cycle upgrades
- Downgrade requires support ticket (prevent abuse)
- Enterprise tier requires sales contact (custom pricing)
- Annual billing gets 10% discount
```

#### 1.3 Tier Limit Enforcement

```
When: User attempts action that may exceed limit

Check: Before allowing action
campaign_count = active_campaigns.count
tier_limit = get_tier_config(advertiser.account_tier).max_campaigns_concurrent

IF campaign_count >= tier_limit:
  ERROR: "Campaign limit reached ({tier_limit} for {tier} tier)"
  Suggest: "Upgrade to {next_tier} for {next_limit} campaigns"

Example Checks:
- Create campaign: Check concurrent campaign limit
- Set campaign budget: Check per-campaign budget limit
- Daily spending: Check daily spend limit (rolling 24h)
- Upload content: Check content asset limit
- Invite team member: Check team member limit

Soft Limits vs Hard Limits:
- Hard limit: Cannot exceed (enforced)
  * Concurrent campaigns
  * Per-campaign budget
  * Team members

- Soft limit: Can exceed with warning
  * Daily spend (alert at 80%, reject at 100%)
  * Monthly spend (same)

Business Rules:
- Limits checked in real-time
- User warned at 80% of limit
- Upgrade prompt at limit reached
- Temporary overages allowed for Enterprise (up to 10%)
```

---

### Rule 2: Verification & KYC

#### 2.1 Verification Requirements

**Individual Advertiser**:
```
Required Documents:
1. Government-issued ID:
   - Passport, OR
   - Driver's license, OR
   - National ID card

2. Selfie (for face match)

3. Proof of address (if > $10k/month):
   - Utility bill
   - Bank statement
   - Government letter
   (Must be < 3 months old)

Process:
- Upload documents via Stripe Identity or manual
- Automated checks (document authenticity, face match)
- Manual review if flagged
- Approval within 24-48 hours

Benefits:
- Increase daily limit: $500 → $10,000
- Increase monthly limit: $1,000 → $100,000
- Access to Premium tier
```

**Business Advertiser**:
```
Required Documents:
1. Business registration certificate

2. Tax ID (EIN/VAT number)

3. Articles of incorporation

4. Beneficial ownership declaration (if applicable)

5. Business bank statement

6. Authorized signatory ID (government ID)

7. Proof of business address

Process:
- Upload documents via secure portal
- Business verification service (e.g., Stripe, LexisNexis)
- Manual review by compliance team
- Approval within 3-5 business days

Benefits:
- All individual benefits
- NET payment terms eligibility
- Higher credit limits
- Enterprise tier eligibility
```

#### 2.2 Verification Process

```
Actor: Advertiser
Trigger: User clicks "Verify Account"

Step 1: Choose verification type
  - Individual: Faster (24-48h)
  - Business: More comprehensive (3-5 days)

Step 2: Upload documents
  POST /account/verify
  {
    "verification_type": "BUSINESS",
    "documents": [
      {
        "type": "BUSINESS_REGISTRATION",
        "file_id": "uploaded_file_id",
        "issue_date": "2020-01-15",
        "expiry_date": null
      },
      {
        "type": "TAX_ID",
        "value": "12-3456789",
        "country": "US"
      }
      // ... more documents
    ],
    "business_info": {
      "legal_name": "Acme Corp Inc.",
      "registration_number": "123456789",
      "registration_country": "US",
      "business_address": {...}
    }
  }

Step 3: Automated checks (Stripe Identity)
  - Document authenticity
  - Expiry date validation
  - Data extraction (OCR)
  - Watchlist screening (sanctions, PEP)

  IF all_checks_pass:
    auto_approve() // For low-risk cases
  ELSE:
    flag_for_manual_review()

Step 4: Manual review (if flagged)
  Compliance team reviews:
  - Document quality
  - Information consistency
  - Risk indicators
  - Business legitimacy

  Decision: APPROVE / REJECT / REQUEST_MORE_INFO

Step 5: Outcome
  Approved:
    advertiser.verification_status = VERIFIED
    advertiser.verified_at = NOW()
    apply_verified_limits()

    Notify: "Verification approved! Higher limits unlocked"

  Rejected:
    advertiser.verification_status = REJECTED

    AdvertiserVerification.update(
      status: REJECTED,
      rejection_reason: reason,
      reviewed_by: admin_id
    )

    Notify: "Verification rejected: {reason}"
    Allow: Re-submit after addressing issues

  More Info Needed:
    Request specific documents/clarifications
    Status remains PENDING

Step 6: Re-verification (every 2 years)
  IF verified_at < NOW() - 2 years:
    advertiser.verification_status = EXPIRED
    Request re-verification
    Revert to unverified limits

Business Rules:
- Verification required for > $10k/month spending
- Documents must be clear, legible, not expired
- Information must match across documents
- PEP/sanctions screening automatic
- Re-verification every 2 years
- Rejection allows re-submission (address issues)
- Enterprise tier requires business verification
```

---

### Rule 3: Team Management

#### 3.1 Team Member Invitation

```
Actor: Advertiser OWNER or ADMIN
Action: Invite team member

Requirements:
✓ Current user has OWNER or ADMIN role
✓ Team size < tier limit
✓ Invitee email not already a team member
✓ Account status = ACTIVE

Process:
1. Send invitation:
   POST /account/team/invite
   {
     "email": "colleague@example.com",
     "role": "CAMPAIGN_MANAGER",
     "message": "Join our advertising team"
   }

2. Validation:
   team_count = advertiser.team_members.active.count
   tier_limit = get_tier_config(advertiser.account_tier).max_team_members

   IF team_count >= tier_limit:
     ERROR: "Team member limit reached"
     Suggest upgrade

3. Create invitation:
   TeamMember.create(
     advertiser_id: advertiser.id,
     user_id: null, // Not yet accepted
     email: "colleague@example.com",
     role: role,
     invited_by: current_user.id,
     invited_at: NOW(),
     status: PENDING
   )

4. Send invitation email:
   To: colleague@example.com
   Subject: "You've been invited to join {company_name}"
   Body:
     - Inviter name
     - Company/brand name
     - Role being offered
     - Accept link (expires in 7 days)

5. Invitee accepts:
   GET /team/invitation/accept?token={token}

   - If user doesn't exist: Redirect to registration
   - If user exists: Confirm acceptance

   TeamMember.update(
     user_id: invitee_user.id,
     accepted_at: NOW(),
     status: ACTIVE
   )

6. Grant access:
   Invitee can now:
   - Log in to advertiser account
   - Perform actions per role permissions
   - Switch between own account and team account

Business Rules:
- Only OWNER and ADMIN can invite
- Invitation expires after 7 days
- One user can be member of multiple advertisers
- Cannot invite existing team member (duplicate email)
- Invitee must accept to gain access
- Owner cannot be removed (transfer ownership first)
```

#### 3.2 Role Permissions Matrix

```
Permissions by Role:

OWNER:
  campaigns: create, read, update, delete, activate, pause
  content: upload, read, update, delete, approve
  wallet: topup, view_balance, view_transactions
  billing: update_payment_method, view_invoices
  reports: view_all, export
  settings: update_profile, update_billing, manage_team
  team: invite, remove, change_roles, transfer_ownership

ADMIN:
  campaigns: create, read, update, delete, activate, pause
  content: upload, read, update, delete, approve
  wallet: view_balance, view_transactions (no topup)
  billing: view_invoices (no update)
  reports: view_all, export
  settings: update_profile (not billing)
  team: invite, remove, change_roles (not owner)

CAMPAIGN_MANAGER:
  campaigns: create, read, update, activate, pause (no delete)
  content: upload, read, update (no delete)
  wallet: view_balance (no transactions)
  billing: none
  reports: view_campaigns, export
  settings: none
  team: none

CONTENT_MANAGER:
  campaigns: read
  content: upload, read, update, delete
  wallet: none
  billing: none
  reports: view_content_performance
  settings: none
  team: none

ANALYST:
  campaigns: read
  content: read
  wallet: none
  billing: none
  reports: view_all, export
  settings: none
  team: none

VIEWER:
  campaigns: read
  content: read
  wallet: none
  billing: none
  reports: view_basic
  settings: none
  team: none

Implementation:
check_permission(user, advertiser, action):
  team_member = TeamMember.find_by(
    user_id: user.id,
    advertiser_id: advertiser.id,
    status: ACTIVE
  )

  IF NOT team_member:
    RETURN false // Not a team member

  permissions = ROLE_PERMISSIONS[team_member.role]
  RETURN action IN permissions[resource]

Example:
  IF NOT check_permission(user, advertiser, "campaigns.delete"):
    ERROR: "Insufficient permissions"
```

#### 3.3 Team Member Removal

```
Actor: OWNER or ADMIN
Action: Remove team member

Requirements:
✓ Current user has OWNER or ADMIN role
✓ Target user is not OWNER (transfer first)
✓ Current user cannot remove self (except OWNER)

Process:
1. Revoke access:
   DELETE /account/team/{member_id}

2. Update record:
   TeamMember.update(
     status: REVOKED,
     revoked_at: NOW(),
     revoked_by: current_user.id
   )

3. Terminate sessions:
   - Invalidate all active sessions for this member
   - Force logout
   - Prevent future logins

4. Audit log:
   AuditLog.create(
     action: "TEAM_MEMBER_REMOVED",
     actor: current_user.id,
     target: member.user_id,
     details: {
       member_name: member.user.name,
       member_role: member.role,
       removal_reason: "Admin action"
     }
   )

5. Notify:
   - Removed member: "Your access to {company} has been revoked"
   - Other team members (optional): "{name} left the team"

Business Rules:
- Owner cannot be removed (must transfer ownership first)
- Removal is immediate (force logout)
- Removed member can be re-invited later
- Audit trail preserved (who removed whom, when)
```

---

### Rule 4: Compliance & Restrictions

#### 4.1 Prohibited Industries

```
Industries NOT allowed to advertise:

1. Adult Content & Services
   - Pornography
   - Adult entertainment
   - Escort services

2. Illegal Goods & Services
   - Drugs & narcotics
   - Weapons & explosives
   - Counterfeit goods
   - Hacking services

3. Gambling (without license)
   - Online casinos
   - Sports betting
   - Lottery services

4. Tobacco Products (strict regulations)
   - Cigarettes
   - Vaping products
   - Tobacco accessories

5. Political Campaigns (separate approval required)
   - Candidate campaigns
   - Political advocacy
   - Issue-based ads

6. Cryptocurrency (without verification)
   - ICOs & token sales
   - Crypto exchanges (unverulated)

7. Healthcare (without credentials)
   - Pharmaceuticals (prescription)
   - Medical services (unlicensed)
   - Miracle cures

8. Financial Services (without license)
   - Unlicensed lending
   - Investment scams
   - Pyramid schemes

Validation:
At registration:
  IF advertiser.industry IN prohibited_industries:
    IF has_special_approval(advertiser):
      ALLOW with restrictions
    ELSE:
      REJECT registration

At campaign creation:
  scan_content_for_prohibited_categories(content)
  IF flagged:
    HOLD for manual review

Business Rules:
- Industry declared at registration
- Cannot change industry without re-verification
- Special categories require additional docs (licenses, permits)
- Content auto-scanned for violations
- Violations result in suspension
```

#### 4.2 Content Restrictions

```
Prohibited Content:

1. Misleading Claims
   - False advertising
   - Unsubstantiated claims
   - Fake testimonials

2. Offensive Content
   - Hate speech
   - Violence
   - Discrimination

3. Copyrighted Material
   - Unlicensed music
   - Stolen images
   - Trademark infringement

4. Sensitive Personal Data
   - Health conditions
   - Financial information
   - Children under 13

5. Before/After Claims (health/beauty)
   - Weight loss
   - Muscle gain
   - Anti-aging
   (Require disclaimers)

Content Review Process:
1. AI scan (automatic):
   - Image recognition (offensive content)
   - Text analysis (prohibited keywords)
   - Audio analysis (copyrighted music)

2. Risk scoring:
   - High risk (>80): Hold for manual review
   - Medium risk (50-80): Approve with flag
   - Low risk (<50): Auto-approve

3. Manual review (if flagged):
   - Compliance team reviews within 24h
   - APPROVE / REJECT / REQUEST_CHANGES

4. Violations:
   - First offense: Warning + content removed
   - Second offense: 7-day suspension
   - Third offense: Permanent ban

Business Rules:
- All content scanned before approval
- High-risk content reviewed manually
- Advertiser notified of violations
- Repeat violations escalate penalties
- Appeal process available
```

---

### Rule 5: Account Status Management

#### 5.1 Suspension

```
Reasons for Suspension:

1. Payment Issues
   - Failed payments (3 consecutive)
   - Chargeback disputes

2. Policy Violations
   - Prohibited content
   - Misleading advertising
   - Excessive user complaints

3. Fraud Indicators
   - Suspicious activity patterns
   - AML flags
   - Identity verification issues

4. Terms of Service Violations
   - Abuse of platform
   - Manipulation attempts
   - Coordinated inauthentic behavior

Suspension Process:
1. Trigger detected:
   - Automated (payment failure, content flag)
   - Manual (admin review)

2. Update account:
   advertiser.status = SUSPENDED
   advertiser.suspended_at = NOW()
   advertiser.suspension_reason = reason

3. Immediate effects:
   - All campaigns paused (stop serving ads)
   - No new campaigns allowed
   - Content upload disabled
   - Wallet withdrawals disabled (if applicable)
   - Login still allowed (read-only)

4. Notify advertiser:
   Email: "Account suspended"
   Reason: Specific violation
   Action: Steps to resolve
   Timeline: Suspension duration

5. Resolution paths:

   Payment Issue:
     - Update payment method
     - Settle outstanding balance
     - Automatic reactivation

   Policy Violation:
     - Remove violating content
     - Acknowledge policy
     - Submit appeal (if applicable)
     - Manual review → reactivation

   Fraud Investigation:
     - Provide additional documentation
     - Compliance review (3-5 days)
     - Reactivate or ban

6. Reactivation:
   IF issue_resolved:
     advertiser.status = ACTIVE
     advertiser.suspended_at = null
     advertiser.suspension_reason = null

     Resume campaigns
     Notify: "Account reactivated"

Business Rules:
- Suspension is reversible
- Advertiser notified with reason
- Clear resolution steps provided
- Campaigns auto-resume on reactivation
- Multiple suspensions → permanent ban
```

#### 5.2 Permanent Ban

```
Reasons for Permanent Ban:

1. Severe Violations
   - Illegal content
   - Severe policy violations
   - Fraud

2. Repeated Violations
   - 3+ suspensions
   - Persistent policy violations
   - No improvement after warnings

3. Legal Reasons
   - Court order
   - Regulatory requirement
   - Law enforcement request

Ban Process:
1. Final review:
   - Compliance team review
   - Senior management approval
   - Legal review (if needed)

2. Execute ban:
   advertiser.status = BANNED
   advertiser.banned_at = NOW()
   advertiser.ban_reason = reason

3. Immediate effects:
   - All campaigns terminated (not paused)
   - All content removed
   - Wallet balance held (pending disputes)
   - Login disabled
   - Team members removed
   - API access revoked

4. Financial settlement:
   - Unused campaign budgets refunded
   - Pending transactions cleared
   - Wallet balance processed per policy:
     * Clean exit: Refund available balance
     * Fraud case: Balance may be forfeited

5. Notify advertiser:
   Email: "Account permanently banned"
   Reason: Violation details
   Appeal: Appeal process (if eligible)
   Data: Data export available (30 days)

6. Appeal process:
   - Window: 30 days from ban
   - Submit: Written appeal with evidence
   - Review: Compliance + legal review
   - Decision: Uphold ban or reinstate

   Appeals rarely approved (< 5%)

Business Rules:
- Ban is permanent (rare exceptions)
- Clear violation documentation required
- Financial settlement per policy
- Data export available (30-day window)
- Appeal process available but strict
- IP/device fingerprinting to prevent re-registration
```

---

## Edge Cases & Error Handling

### Edge Case 1: Team Member Ownership Transfer

```
Scenario: OWNER leaves company, needs to transfer ownership

Process:
1. Current OWNER initiates transfer:
   POST /account/transfer-ownership
   {
     "new_owner_user_id": "uuid"
   }

2. Validation:
   ✓ Current user is OWNER
   ✓ New owner is active team member
   ✓ New owner accepts (requires confirmation)

3. Confirmation from new owner:
   - Email sent: "You've been nominated as new owner"
   - Accept/Decline within 7 days

4. If accepted:
   // Update roles
   old_owner = TeamMember.find_by(role: OWNER)
   old_owner.update(role: ADMIN) // Demoted to ADMIN

   new_owner = TeamMember.find_by(user_id: new_owner_id)
   new_owner.update(role: OWNER) // Promoted to OWNER

   // Transfer billing ownership
   advertiser.user_id = new_owner_user_id
   advertiser.updated_at = NOW()

   // Audit log
   Log ownership transfer

5. Notify all team members:
   "Ownership transferred: {old_owner} → {new_owner}"

Business Rule:
- Only one OWNER at a time
- Transfer requires new owner confirmation
- Old owner becomes ADMIN (not removed)
- Billing responsibility transfers
```

### Edge Case 2: Tier Downgrade Mid-Campaign

```
Scenario: Premium user downgrades to Basic while campaigns running

Current state:
- Tier: PREMIUM (max 20 campaigns)
- Active campaigns: 15
- New tier: BASIC (max 5 campaigns)

Problem: 15 campaigns exceed Basic limit of 5

Resolution:
1. Warn user before downgrade:
   "You have 15 active campaigns. Basic tier allows 5."
   Options:
   - Cancel downgrade
   - Pause 10 campaigns (user selects which)
   - Schedule downgrade for end of campaigns

2. If user proceeds:
   - Campaigns keep running (grandfathered)
   - Cannot create new campaigns until count < 5
   - Next campaign ends, count decreases

Business Rule:
- Existing campaigns grandfathered
- New campaign creation blocked
- User warned before downgrade
```

### Edge Case 3: Verification Expires Mid-Campaign

```
Scenario: Verification expires (2 years), campaigns still running

Process:
1. Detect expiration:
   IF advertiser.verified_at < NOW() - 2 years:
     advertiser.verification_status = EXPIRED

2. Notify user (30 days before):
   "Verification expires soon. Re-verify to maintain limits."

3. On expiration:
   - Status → EXPIRED
   - Limits revert to unverified
   - Existing campaigns continue (grandfathered)
   - New campaigns: Reduced limits apply

4. User re-verifies:
   - Submit new documents
   - Verification process
   - Limits restored

Business Rule:
- Re-verification required every 2 years
- 30-day advance notice
- Existing campaigns unaffected
- New campaigns use lower limits until re-verified
```

---

## Validation Rules

### Advertiser Validation Matrix

| Field | Rule | Error Message |
|-------|------|---------------|
| company_name | Length 2-100 | "Company name must be 2-100 characters" |
| brand_name | Length 2-100, required | "Brand name is required" |
| website_url | Valid URL format | "Invalid website URL" |
| description | Max 500 characters | "Description max 500 characters" |
| industry | Valid enum value | "Invalid industry selection" |
| billing_email | Valid email format | "Invalid email address" |
| billing_address | Required fields | "Complete billing address required" |
| tax_id | Valid format per country | "Invalid tax ID format" |

---

## Appendix: Account Tier Comparison Table

| Feature | FREE | BASIC | PREMIUM | ENTERPRISE |
|---------|------|-------|---------|------------|
| **Price/month** | $0 | $99 | $499 | Custom |
| **Concurrent Campaigns** | 2 | 5 | 20 | Unlimited |
| **Budget/Campaign** | $500 | $2,000 | $10,000 | Custom |
| **Daily Spend** | $100 | $500 | $2,000 | Custom |
| **Monthly Spend** | $1,000 | $5,000 | $50,000 | Custom |
| **Content Assets** | 10 | 50 | 200 | Unlimited |
| **Team Members** | 1 | 3 | 10 | Unlimited |
| **Support** | Community | Email 48h | Priority 24h | Dedicated AM |
| **API Access** | No | No | Yes | Yes |
| **Analytics** | Basic | Advanced | Advanced | Custom |
| **White Label** | No | No | No | Yes |

---

**Document Status**: Ready for review
**Next Steps**:
1. Review with stakeholders
2. Product team validation
3. Sales team input (Enterprise tier)
4. Implementation planning

---

**Related Documents**:
- `business-rules-campaign.md` - Campaign creation by advertisers
- `business-rules-wallet.md` - Advertiser wallet & payments
- `business-rules-content.md` - Content upload by advertisers
