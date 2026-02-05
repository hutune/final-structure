# 💰 Financial Domain - Billing & Wallet Business Rules

**Version**: 1.0  
**Date**: 2026-02-05  
**Status**: Consolidated  
**Domain**: 08-Financial (Billing Models + Wallet & Payment)

---

## 📖 Table of Contents

1. [Overview](#-overview)
2. [Types of Billing Models](#-types-of-billing-models)
3. [Billing Process](#-billing-process)
4. [Comparison Table](#-comparison-table)
5. [Calculation Examples](#-calculation-examples)

---

## 🎯 Overview

### Why do we need a separate billing model?

In-store digital signage advertising (offline digital signage) is **different** from online advertising:

| Difference | Online | Offline (RMN) |
|-----------|--------|---------------|
| **Measurement** | Click, scroll, time-on-page | Number of plays, viewing time |
| **User data** | Cookie, tracking pixel | Sensor, camera (anonymous) |
| **Interaction** | Click, form submission | View only (passive viewing) |
| **Location** | Anywhere with internet | Specific stores |

> 💡 **Conclusion**: We need a billing model based on **device playback logs**, **sensor data**, **estimated customer traffic**, and **time-slot value**.

---

## 📋 Types of Billing Models

### Model 1: Fixed CPM (Cost Per Impression) ⭐ MAIN MODEL

> **Most popular** in the real RMN industry

**How it works:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    FIXED CPM (Fixed CPM)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📺 1 play on screen = 1 IMPRESSION                            │
│                                                                 │
│  ✅ Verified by:                                                │
│     • Heartbeat from device                                    │
│     • Playback log                                             │
│     • Digital signature from device                            │
│                                                                 │
│  ⚖️ Can be adjusted by:                                        │
│     • Video duration (30s vs 60s)                              │
│     • Screen size                                              │
│     • Slot duration                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Formula:**
```
Cost = (Number of impressions × CPM Price) ÷ 1000

Example:
• CPM = $5
• Number of impressions = 10,000
• Cost = (10,000 × $5) ÷ 1000 = $50
```

**Advantages:**
- ✅ Simple, easy to understand
- ✅ Easy to calculate and forecast budget
- ✅ Transparent for both Advertiser and Supplier

**Disadvantages:**
- ❌ Does not differentiate impression quality
- ❌ Empty stores are charged the same as busy stores

---

### Model 2: Dwell Time-based Billing

> Uses **camera sensor** (anonymous AI, no personal identification)

**How it works:**

```
┌─────────────────────────────────────────────────────────────────┐
│                 DWELL TIME-BASED BILLING                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📷 Camera counts:                                              │
│     • Number of people standing in front of screen             │
│     • Average time they look at the screen                     │
│                                                                 │
│  🔒 Privacy-first:                                              │
│     • NO storage of facial images                              │
│     • ONLY counts quantity + time                              │
│     • 100% anonymous data                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Formula:**
```
Cost = Base Price × (Number of viewers × Dwell time coefficient)

Example:
• Base price = $0.01
• Number of viewers = 50
• Time coefficient = 1.5 (longer than average viewing time)
• Cost = $0.01 × (50 × 1.5) = $0.75 per play
```

**Advantages:**
- ✅ More realistic measurement
- ✅ Rewards engaging ads (people watch longer)

**Disadvantages:**
- ❌ Requires investment in cameras/sensors
- ❌ More complex to implement

---

### Model 3: Time-slot Premium Pricing

> Like TV: Prime time is more expensive, late night is cheaper

**How it works:**

```
┌─────────────────────────────────────────────────────────────────┐
│                  TIME-SLOT PRICING                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ⏰ Instead of CPC/CPO (online), offline calculates based on   │
│     busy time slots at stores                                  │
│                                                                 │
│  📊 Coefficient by time slot:                                  │
│                                                                 │
│     Time slot              │ Coefficient │ Explanation         │
│     ─────────────────────────────────────────────────────────  │
│     18:00 - 21:00 (evening)│ +70%        │ Prime time, busiest │
│     11:00 - 13:00 (lunch)  │ +30%        │ Lunch break         │
│     09:00 - 11:00 (morning)│ +0%         │ Regular time        │
│     06:00 - 09:00 (early)  │ -50%        │ Few customers       │
│     21:00 - 06:00 (night)  │ -70%        │ Very few customers  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Formula:**
```
Cost = Base CPM × Time slot coefficient

Example (Base CPM = $5):
• Play at 19:00 (prime time): $5 × 1.7 = $8.50 / 1000 impressions
• Play at 07:00 (early morning): $5 × 0.5 = $2.50 / 1000 impressions
```

**Advantages:**
- ✅ Reflects real value of each time slot
- ✅ Advertisers can choose time slots that fit their budget

**Disadvantages:**
- ❌ More complex when planning budget
- ❌ Requires accurate foot traffic data

---

### Model 4: Foot Traffic-based Billing

> Combined with sensors or POS/entrance gate data

**How it works:**

```
┌─────────────────────────────────────────────────────────────────┐
│               FOOT TRAFFIC-BASED BILLING                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📊 Data sources:                                              │
│     • People counting sensor at entrance                       │
│     • Data from POS system                                     │
│     • Counting camera (anonymous)                              │
│                                                                 │
│  🎯 Concept:                                                   │
│     • More traffic → Higher CPM                                │
│     • Busy location (near checkout) → Premium                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Formula:**
```
Cost = Base Price × (Traffic Index ÷ Average Traffic)

Example:
• Base price = $5 CPM
• Today's traffic = 2000 people
• Average traffic = 1000 people
• Cost = $5 × (2000 ÷ 1000) = $10 CPM
```

**Premium Locations:**
```
┌────────────────────────────────────────────────────────────┐
│                    STORE LAYOUT                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│   [Entrance]                                               │
│       │                                                    │
│       ▼                                                    │
│   ┌─────────┐                                             │
│   │ Screen  │  ← CPM +50% (great location, everyone sees) │
│   │ at entry│                                             │
│   └─────────┘                                             │
│                                                            │
│   ┌─────────────────────────────────────┐                 │
│   │        Shopping area                │                 │
│   │   ┌─────────┐  ┌─────────┐          │                 │
│   │   │ Screen  │  │ Screen  │          │  ← Base CPM     │
│   │   │ on aisle│  │ on aisle│          │                 │
│   │   └─────────┘  └─────────┘          │                 │
│   └─────────────────────────────────────┘                 │
│                                                            │
│   ┌─────────┐                                             │
│   │ Screen  │  ← CPM +100% (everyone waits at checkout,  │
│   │ checkout│     views longest)                          │
│   └─────────┘                                             │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

### Model 5: Playtime Guarantee

> Similar to "guaranteed impressions" in online advertising

**How it works:**

```
┌─────────────────────────────────────────────────────────────────┐
│                  PLAYTIME GUARANTEE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📜 COMMITMENT:                                                │
│     "Guaranteed 10,000 plays within 1 month"                   │
│                                                                 │
│  🔄 IF NOT MET:                                                │
│     • System automatically plays more (compensation)           │
│     • Or refund the shortfall                                  │
│                                                                 │
│  💡 SOLVES ISSUES:                                             │
│     • Device offline (power outage, malfunction)               │
│     • Playback errors                                          │
│     • Maintenance                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Example:**
```
Ad package: 10,000 impressions / month - Price $500

Actual results:
• Played: 8,500 impressions
• Shortfall: 1,500 impressions

Resolution:
• Option A: Extend campaign until reaching 10,000
• Option B: Refund $75 (1,500/10,000 × $500)
```

---

### Model 6: Venue-type Premium

> Large stores = higher prices

**Classification table:**

```
┌─────────────────────────────────────────────────────────────────┐
│                  VENUE-TYPE PRICING                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Store type             │ Coefficient │ CPM (if base = $5)      │
│  ─────────────────────────────────────────────────────────────  │
│  🏆 Flagship Store       │ +200%       │ $15.00                  │
│  🏢 Large shopping mall  │ +100%       │ $10.00                  │
│  🛒 Large supermarket    │ +50%        │ $7.50                   │
│  🏪 Convenience store    │ 0%          │ $5.00 (base)            │
│  🏠 Small grocery        │ -30%        │ $3.50                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Advantages:**
- ✅ Reflects brand placement value
- ✅ Flagship store = more VIP customers = higher value

---

## 🔄 Billing Process

### Flow from Playback → Charging

```
┌─────────────────────────────────────────────────────────────────┐
│                    BILLING PROCESS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Step 1         Step 2         Step 3         Step 4          │
│  ┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐       │
│  │Playback│     │ Filter │     │ Aggre- │     │ Calcu- │       │
│  │  Log   │ ──► │ Valid  │ ──► │ gate   │ ──► │ late   │       │
│  │        │     │ Events │     │ data   │     │ Price  │       │
│  └────────┘     └────────┘     └────────┘     └────────┘       │
│       │              │              │              │            │
│       ▼              ▼              ▼              ▼            │
│  Device         Remove:         Sensor/         Apply:          │
│  sends event    - Playback      Traffic         - Time slot    │
│  to server      errors          data            - Store type   │
│                 - Offline                       - Location      │
│                 - Fraud                                         │
│                                                                 │
│   Step 5         Step 6                                        │
│  ┌────────┐     ┌────────┐                                     │
│  │ Deduct │     │ Credit │                                     │
│  │ Budget │ ──► │ to     │                                     │
│  │        │     │Supplier│                                     │
│  └────────┘     └────────┘                                     │
│       │              │                                          │
│       ▼              ▼                                          │
│  Advertiser     Supplier                                        │
│  Wallet         receives 80%                                    │
│  deducted                                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Comparison Table

### Comparison of billing models

| Model | Complexity | Fairness | Hardware required | Suitable for |
|---------|-------------|-----------|--------------|-------------|
| Fixed CPM | ⭐ Low | ⭐⭐ Medium | Screen only | MVP, start-up |
| Dwell Time | ⭐⭐⭐ High | ⭐⭐⭐⭐ High | Camera + AI | Enterprise |
| Time-slot | ⭐⭐ Medium | ⭐⭐⭐ Good | No additional | All |
| Foot Traffic | ⭐⭐⭐ High | ⭐⭐⭐⭐ High | Counting sensor | Large supermarkets |
| Playtime Guarantee | ⭐⭐ Medium | ⭐⭐⭐⭐ High | No additional | Long-term contracts |
| Venue type | ⭐ Low | ⭐⭐⭐ Good | No additional | All |

### Recommendation for RMN-Arms

```
┌─────────────────────────────────────────────────────────────────┐
│                    IMPLEMENTATION RECOMMENDATION                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PHASE 1 (MVP):                                                │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ ✅ Fixed CPM                                           │    │
│  │ ✅ Venue-type coefficient                             │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  PHASE 2 (Enhancement):                                        │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ ✅ Add Time-slot coefficient                          │    │
│  │ ✅ Playtime guarantee                                 │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  PHASE 3 (Premium):                                            │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ ✅ Integrate Foot Traffic (if sensor available)       │    │
│  │ ✅ Dwell Time for Enterprise customers                │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💵 Calculation Examples

### Case Study: Coca-Cola Advertising Campaign

**Campaign information:**
- Budget: $5,000
- Duration: 2 weeks
- Number of stores: 50
- Store type: Large supermarket (coefficient +50%)

**Calculation:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    DETAILED CALCULATION                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Base CPM: $5.00                                            │
│                                                                 │
│  2. Store type coefficient (Large supermarket): +50%           │
│     → CPM after coefficient: $5.00 × 1.5 = $7.50              │
│                                                                 │
│  3. Estimated impressions:                                     │
│     → $5,000 ÷ ($7.50 / 1000) = 666,667 impressions           │
│                                                                 │
│  4. Average per store:                                         │
│     → 666,667 ÷ 50 = 13,333 impressions / store               │
│                                                                 │
│  5. Average per day (14 days):                                 │
│     → 13,333 ÷ 14 = 952 impressions / day / store             │
│                                                                 │
│  6. Revenue distribution:                                      │
│     • Supplier receives: $5,000 × 80% = $4,000                │
│     • Platform keeps: $5,000 × 20% = $1,000                   │
│                                                                 │
│     → Each Supplier (50 stores): $4,000 ÷ 50 = $80 / store   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### With additional Time-slot coefficient

```
┌─────────────────────────────────────────────────────────────────┐
│              WITH TIME-SLOT COEFFICIENT                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Impression allocation by time slot:                           │
│                                                                 │
│  Time slot      │ % Alloc  │ Coeff │ Actual CPM │ Impressions  │
│  ───────────────────────────────────────────────────────────── │
│  Morning (9-12) │ 20%      │ 1.0   │ $7.50      │ 133,333      │
│  Lunch (12-14)  │ 15%      │ 1.3   │ $9.75      │ 100,000      │
│  Afternoon (14-18)│ 25%    │ 1.0   │ $7.50      │ 166,667      │
│  Evening (18-21)│ 40%      │ 1.7   │ $12.75     │ 266,667      │
│                                                                 │
│  Actual impressions when applying time-slot coefficient:       │
│  → Less than fixed CPM (because playing more during prime time)│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📎 Related Documents

| Document | Description |
|----------|-------|
| [Terminology Dictionary](./00-tu-dien-thuat-ngu.md) | Explains CPM, Impression, etc. |
| [Campaign Rules](./04-quy-tac-chien-dich.md) | Details on budget, billing |
| [Wallet & Payment Rules](./07-quy-tac-vi-thanh-toan.md) | Details on wallet, top-up, withdrawal |

---

**Version**: 1.0
**Last updated**: 2026-01-23
**Owner**: Product Team


---

# Part 2: Wallet & Payment Module

---

---

## Table of Contents

1. [Overview](#overview)
2. [Domain Entities](#domain-entities)
3. [Wallet Lifecycle](#wallet-lifecycle)
4. [Business Rules](#business-rules)
5. [Top-up & Payment Processing](#top-up--payment-processing)
6. [Transaction Management](#transaction-management)
7. [Refund Processing](#refund-processing)
8. [Supplier Withdrawals](#supplier-withdrawals)
9. [Currency & Exchange](#currency--exchange)
10. [Tax Handling](#tax-handling)
11. [Financial Reconciliation](#financial-reconciliation)
12. [Anti-Money Laundering (AML)](#anti-money-laundering-aml)
13. [Edge Cases & Error Handling](#edge-cases--error-handling)
14. [Validation Rules](#validation-rules)
15. [Calculations & Formulas](#calculations--formulas)

---

## Overview

### Purpose
This document defines ALL business rules for the Wallet & Payment module, covering financial transactions, payment processing, refunds, withdrawals, and compliance requirements.

### Scope
- Wallet management (Advertiser & Supplier)
- Balance types and transitions
- Payment gateway integration
- Top-up and withdrawal processes
- Transaction recording and audit
- Refund processing
- Tax calculation and compliance
- Currency exchange
- Financial reconciliation
- Anti-Money Laundering (AML) compliance

### Out of Scope
- Campaign billing (see Campaign module)
- Impression costs (see Campaign/Impression modules)
- Supplier revenue calculation (see Campaign/Supplier modules)

### Key Concepts
- **Wallet**: Digital account holding funds for user
- **Balance Types**: Available, Held, Pending
- **Transaction**: Immutable record of balance change
- **Top-up**: Adding funds to advertiser wallet
- **Withdrawal**: Transferring funds from supplier wallet to bank
- **Reconciliation**: Daily verification of financial accuracy

---

## Domain Entities

### 1. Wallet

**Definition**: Digital account for managing platform funds.

**Attributes**:

| Field | Type | Required | Default | Business Rule |
|-------|------|----------|---------|---------------|
| `id` | UUID | Yes | Auto-generated | Immutable |
| `user_id` | UUID | Yes | - | One wallet per user |
| `user_type` | Enum | Yes | - | ADVERTISER / SUPPLIER |
| `currency` | String(3) | Yes | "USD" | ISO 4217 code |
| `available_balance` | Decimal(12,2) | Yes | 0.00 | Immediately usable funds |
| `held_balance` | Decimal(12,2) | Yes | 0.00 | Escrowed/locked funds |
| `pending_balance` | Decimal(12,2) | Yes | 0.00 | Processing deposits/withdrawals |
| `lifetime_deposits` | Decimal(12,2) | Yes | 0.00 | Total ever deposited |
| `lifetime_withdrawals` | Decimal(12,2) | Yes | 0.00 | Total ever withdrawn |
| `lifetime_spent` | Decimal(12,2) | Yes | 0.00 | Total campaign spending (advertiser) |
| `lifetime_earned` | Decimal(12,2) | Yes | 0.00 | Total revenue earned (supplier) |
| `min_balance_alert` | Decimal(12,2) | No | null | Alert when balance below |
| `max_balance_limit` | Decimal(12,2) | No | null | Maximum allowed balance |
| `status` | Enum | Yes | ACTIVE | ACTIVE / FROZEN / SUSPENDED |
| `frozen_reason` | String(200) | No | null | Why wallet is frozen |
| `frozen_at` | DateTime | No | null | When frozen |
| `last_topup_at` | DateTime | No | null | Most recent deposit |
| `last_withdrawal_at` | DateTime | No | null | Most recent withdrawal |
| `created_at` | DateTime | Yes | NOW() | Immutable |
| `updated_at` | DateTime | Yes | NOW() | Auto-updated |

**Balance Invariant**:
```
total_balance = available_balance + held_balance + pending_balance

// This should always equal the sum of all transaction amounts
total_balance == SUM(transactions.amount WHERE type IN [CREDIT, DEBIT])
```

---

### 2. WalletTransaction

**Definition**: Immutable record of balance change event.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `wallet_id` | UUID | Yes | Source wallet |
| `transaction_type` | Enum | Yes | See [Transaction Types](#transaction-types) |
| `amount` | Decimal(12,2) | Yes | Always positive (type indicates direction) |
| `currency` | String(3) | Yes | ISO 4217 code |
| `balance_before` | Decimal(12,2) | Yes | Snapshot before transaction |
| `balance_after` | Decimal(12,2) | Yes | Snapshot after transaction |
| `balance_type_affected` | Enum | Yes | AVAILABLE / HELD / PENDING |
| `status` | Enum | Yes | PENDING / COMPLETED / FAILED / REVERSED |
| `reference_type` | String(50) | No | Campaign, Impression, Withdrawal, etc. |
| `reference_id` | UUID | No | Link to related entity |
| `payment_method` | Enum | No | CARD / BANK_TRANSFER / WALLET / OTHER |
| `payment_gateway` | Enum | No | STRIPE / PAYPAL / BANK / MANUAL |
| `gateway_transaction_id` | String(100) | No | External payment ID |
| `description` | Text | Yes | Human-readable description |
| `metadata` | JSON | No | Additional data |
| `fee_amount` | Decimal(12,2) | Yes | Transaction fee (default: 0.00) |
| `tax_amount` | Decimal(12,2) | Yes | Tax withheld (default: 0.00) |
| `net_amount` | Decimal(12,2) | Yes | amount - fee - tax |
| `processed_by` | UUID | No | User/Admin who initiated |
| `processed_at` | DateTime | Yes | When transaction executed |
| `reversed_at` | DateTime | No | When reversed (if applicable) |
| `reversal_reason` | String(200) | No | Why reversed |
| `created_at` | DateTime | Yes | Immutable |

#### Transaction Types
```
Credit (increase balance):
- DEPOSIT: User adds funds
- REFUND: Campaign budget refund
- REVENUE: Supplier earnings
- ADJUSTMENT_CREDIT: Manual correction (admin)
- BONUS: Platform incentive

Debit (decrease balance):
- CAMPAIGN_HOLD: Budget escrowed for campaign
- CAMPAIGN_CHARGE: Impression billed
- WITHDRAWAL: Supplier payout
- FEE: Platform/transaction fee
- TAX_WITHHOLDING: Tax deduction
- ADJUSTMENT_DEBIT: Manual correction (admin)
- CHARGEBACK: Disputed impression

Hold/Release (no balance change):
- HOLD: Move available → held
- RELEASE: Move held → available

Pending (in-flight):
- PENDING_DEPOSIT: Deposit processing
- PENDING_WITHDRAWAL: Withdrawal processing
```

---

### 3. PaymentMethod

**Definition**: Saved payment method for user.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `user_id` | UUID | Yes | Owner |
| `type` | Enum | Yes | CREDIT_CARD / DEBIT_CARD / BANK_ACCOUNT |
| `provider` | Enum | Yes | STRIPE / PAYPAL |
| `provider_payment_method_id` | String(100) | Yes | Gateway's PM ID |
| `is_default` | Boolean | Yes | Default for top-ups |
| `card_last4` | String(4) | No | Last 4 digits (if card) |
| `card_brand` | String(20) | No | Visa, Mastercard, etc. |
| `card_exp_month` | Integer | No | Expiry month (1-12) |
| `card_exp_year` | Integer | No | Expiry year |
| `bank_name` | String(100) | No | Bank name (if bank account) |
| `bank_account_last4` | String(4) | No | Last 4 of account |
| `billing_address` | JSON | No | Address details |
| `status` | Enum | Yes | ACTIVE / EXPIRED / FAILED |
| `verified_at` | DateTime | No | When verified |
| `last_used_at` | DateTime | No | Most recent use |
| `created_at` | DateTime | Yes | Immutable |

---

### 4. WithdrawalRequest

**Definition**: Supplier request to transfer funds to bank account.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `wallet_id` | UUID | Yes | Supplier wallet |
| `supplier_id` | UUID | Yes | Requester |
| `amount` | Decimal(12,2) | Yes | Amount to withdraw |
| `currency` | String(3) | Yes | ISO 4217 code |
| `fee_amount` | Decimal(12,2) | Yes | Withdrawal fee |
| `tax_amount` | Decimal(12,2) | Yes | Tax withheld |
| `net_amount` | Decimal(12,2) | Yes | amount - fee - tax |
| `bank_account_name` | String(100) | Yes | Recipient name |
| `bank_account_number` | String(50) | Yes | Account number (encrypted) |
| `bank_routing_number` | String(20) | Yes | Routing/SWIFT code |
| `bank_name` | String(100) | Yes | Bank name |
| `bank_country` | String(2) | Yes | ISO country code |
| `status` | Enum | Yes | See [Withdrawal Status](#withdrawal-status) |
| `requested_at` | DateTime | Yes | When submitted |
| `approved_at` | DateTime | No | When admin approved |
| `approved_by` | UUID | No | Admin who approved |
| `processed_at` | DateTime | No | When payment sent |
| `completed_at` | DateTime | No | When confirmed received |
| `failed_at` | DateTime | No | When failed |
| `failure_reason` | String(200) | No | Why failed |
| `reference_number` | String(50) | No | Bank reference |
| `retry_count` | Integer | Yes | Failed attempt count (default: 0) |

#### Withdrawal Status
```
PENDING → APPROVED → PROCESSING → COMPLETED
                                       ↓
                                    FAILED → RETRY → PROCESSING
                                       ↓
                                  CANCELLED
```

---

### 5. RefundRequest

**Definition**: Advertiser request for refund.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `wallet_id` | UUID | Yes | Advertiser wallet |
| `advertiser_id` | UUID | Yes | Requester |
| `campaign_id` | UUID | No | Related campaign (if applicable) |
| `amount` | Decimal(12,2) | Yes | Refund amount |
| `refund_type` | Enum | Yes | CAMPAIGN_CANCELLED / UNUSED_BUDGET / DISPUTE / OTHER |
| `reason` | Text | Yes | Why requesting refund |
| `status` | Enum | Yes | PENDING / APPROVED / REJECTED / COMPLETED |
| `requested_at` | DateTime | Yes | When submitted |
| `approved_at` | DateTime | No | When approved |
| `approved_by` | UUID | No | Admin who approved |
| `processed_at` | DateTime | No | When refund issued |
| `rejection_reason` | String(200) | No | Why rejected |

---

### 6. DailyReconciliation

**Definition**: Daily financial accuracy check.

**Attributes**:

| Field | Type | Required | Business Rule |
|-------|------|----------|---------------|
| `id` | UUID | Yes | Auto-generated |
| `reconciliation_date` | Date | Yes | Business day being reconciled |
| `total_deposits` | Decimal(12,2) | Yes | Sum of all deposits |
| `total_withdrawals` | Decimal(12,2) | Yes | Sum of all withdrawals |
| `total_campaign_spending` | Decimal(12,2) | Yes | Sum of campaign charges |
| `total_supplier_revenue` | Decimal(12,2) | Yes | Sum of supplier earnings |
| `platform_revenue` | Decimal(12,2) | Yes | Platform's 20% share |
| `expected_balance` | Decimal(12,2) | Yes | Calculated total |
| `actual_balance` | Decimal(12,2) | Yes | Sum of all wallet balances |
| `discrepancy` | Decimal(12,2) | Yes | expected - actual |
| `status` | Enum | Yes | PENDING / BALANCED / DISCREPANCY / RESOLVED |
| `discrepancy_reason` | Text | No | Explanation if discrepancy |
| `reconciled_by` | UUID | No | Admin who reconciled |
| `reconciled_at` | DateTime | No | When reconciled |
| `created_at` | DateTime | Yes | Immutable |

---

## Wallet Lifecycle

### 1. Wallet Creation

```
Trigger: User account created (Advertiser or Supplier)

Process:
1. Create wallet automatically:
   Wallet.create(
     user_id: new_user.id,
     user_type: new_user.type, // ADVERTISER or SUPPLIER
     currency: new_user.country.default_currency OR "USD",
     available_balance: 0.00,
     held_balance: 0.00,
     pending_balance: 0.00,
     status: ACTIVE
   )

2. Initialize transaction log:
   WalletTransaction.create(
     wallet_id: wallet.id,
     transaction_type: ADJUSTMENT_CREDIT,
     amount: 0.00,
     balance_before: 0.00,
     balance_after: 0.00,
     description: "Wallet initialized",
     status: COMPLETED
   )

3. Set default limits:
   IF user_type = ADVERTISER:
     wallet.max_balance_limit = 100,000.00 // $100k max
     wallet.min_balance_alert = 100.00    // Alert below $100
   ELSE IF user_type = SUPPLIER:
     wallet.max_balance_limit = null       // No limit
     wallet.min_balance_alert = 1,000.00  // Alert below $1k

Business Rules:
- One wallet per user (strict 1:1 relationship)
- Created automatically at user registration
- Initial balance always 0.00
- Currency based on user's country (default: USD)
- Status = ACTIVE by default
- Immutable after creation (cannot delete wallet)
```

---

## Business Rules

### Rule 1: Balance Management

#### 1.1 Balance Types

**Available Balance**:
```
Definition: Funds immediately usable for campaigns or withdrawals

For Advertisers:
- Can create campaigns using available balance
- Available = deposited funds not escrowed

For Suppliers:
- Can withdraw available balance
- Available = revenue earned and released (not held)

Business Rules:
- Never negative (enforced by database constraint)
- Increased by: deposits, refunds, released holds
- Decreased by: campaign holds, withdrawals, fees
```

**Held Balance**:
```
Definition: Funds temporarily locked for pending operations

For Advertisers:
- Campaign budget escrowed when campaign created
- Released when campaign completes or cancelled

For Suppliers:
- Revenue held during 7-day anti-fraud period
- Disputed impressions held until resolved

Business Rules:
- Never negative
- Increased by: campaign creation, disputes
- Decreased by: campaign completion, dispute resolution
- Automatic release after holding period
```

**Pending Balance**:
```
Definition: Funds in-flight (processing deposits/withdrawals)

For Advertisers:
- Deposit processing (1-3 days for bank transfer)
- Moves to available_balance when cleared

For Suppliers:
- Withdrawal processing (3-5 days)
- Removed from wallet when wire sent

Business Rules:
- Never negative
- Temporary state (max 7 days)
- Alerts if pending > 7 days (investigation needed)
- Refunded if payment fails
```

#### 1.2 Balance Invariants

```
Invariant 1: Non-negative balances
available_balance >= 0
held_balance >= 0
pending_balance >= 0

Invariant 2: Total balance accuracy
total_balance = available_balance + held_balance + pending_balance

Invariant 3: Transaction sum equals balance
total_balance == SUM(all transactions.net_amount)

Invariant 4: Advertiser balance matches campaigns
advertiser.held_balance == SUM(active_campaigns.remaining_budget)

Validation:
IF any invariant violated:
  CRITICAL_ERROR: "Balance integrity violation"
  FREEZE wallet
  ALERT finance team
  TRIGGER manual reconciliation
```

---

### Rule 2: Top-up Processing

#### 2.1 Top-up Limits

```
Per-transaction Limits:
- Minimum top-up: $50.00
- Maximum top-up: $10,000.00 per transaction
- Maximum daily total: $50,000.00

Account-based Limits:
- Unverified account: Max $500/day
- Verified account: Max $10,000/day
- Enterprise account: Custom limits

Frequency Limits:
- Max 10 transactions per day
- Cooldown: 1 minute between transactions

Validation:
IF top_up_amount < 50:
  ERROR: "Minimum top-up is $50"

IF top_up_amount > 10,000:
  ERROR: "Maximum top-up is $10,000 per transaction"

IF daily_total + top_up_amount > daily_limit:
  ERROR: "Daily limit exceeded"

IF transactions_today >= 10:
  ERROR: "Maximum 10 transactions per day"

Business Rules:
- Limits adjustable per account tier
- Enterprise accounts get custom limits
- Suspicious patterns flagged for review
- Repeated limit hits trigger AML review
```

#### 2.2 Top-up Flow

```
Actor: Advertiser
Payment Methods: Credit Card, Debit Card, Bank Transfer

Process:
1. User initiates top-up:
   POST /wallet/topup
   {
     "amount": 500.00,
     "payment_method_id": "pm_xxx",
     "save_payment_method": true
   }

2. Validation:
   ✓ amount >= $50 AND <= $10,000
   ✓ daily_limit not exceeded
   ✓ payment_method valid and active
   ✓ wallet status = ACTIVE (not frozen)

3. Create pending transaction:
   transaction = WalletTransaction.create(
     wallet_id: wallet.id,
     transaction_type: PENDING_DEPOSIT,
     amount: 500.00,
     status: PENDING,
     payment_method: CREDIT_CARD,
     payment_gateway: STRIPE,
     description: "Top-up via Stripe"
   )

   wallet.pending_balance += 500.00

4. Process payment via gateway:
   // Stripe example
   payment_intent = Stripe.PaymentIntent.create(
     amount: 50000, // cents
     currency: "usd",
     payment_method: payment_method_id,
     confirm: true
   )

5. Handle gateway response:

   Success (payment_intent.status = "succeeded"):
     wallet.pending_balance -= 500.00
     wallet.available_balance += 500.00

     transaction.update(
       status: COMPLETED,
       gateway_transaction_id: payment_intent.id,
       processed_at: NOW()
     )

     WalletTransaction.create(
       transaction_type: DEPOSIT,
       amount: 500.00,
       balance_before: previous_available,
       balance_after: wallet.available_balance,
       balance_type_affected: AVAILABLE,
       status: COMPLETED
     )

     Notify user: "Top-up successful: $500"

   Failure (payment_intent.status = "failed"):
     wallet.pending_balance -= 500.00
     // Refund pending amount

     transaction.update(
       status: FAILED,
       processed_at: NOW()
     )

     Notify user: "Top-up failed: {error_message}"

   Requires Action (3D Secure):
     // Return URL for user authentication
     Return {
       status: "requires_action",
       client_secret: payment_intent.client_secret
     }
     // User completes 3DS, webhook processes result

6. AML check (if applicable):
   IF amount >= 1,000 OR suspicious_pattern:
     flag_for_aml_review(transaction)

Business Rules:
- Payment processed via Stripe/PayPal
- 3D Secure required for cards (European regulation)
- Pending → Available when payment clears
- Failed payments refund pending balance
- All transactions logged (immutable)
- User notified of outcome (email + push)
```

---

### Rule 3: Campaign Budget Hold

```
Trigger: Campaign created with budget

Process:
1. Validate available balance:
   IF wallet.available_balance < campaign.budget:
     ERROR: "Insufficient balance"
     Prompt user to top-up

2. Create hold transaction:
   WalletTransaction.create(
     transaction_type: CAMPAIGN_HOLD,
     amount: campaign.budget,
     reference_type: "Campaign",
     reference_id: campaign.id,
     description: "Budget hold for campaign: {campaign.name}",
     status: COMPLETED
   )

3. Move funds: available → held
   wallet.available_balance -= campaign.budget
   wallet.held_balance += campaign.budget

4. Campaign lifecycle impacts:

   On impression recorded:
     // Deduct from held balance
     impression_cost = calculate_cost(impression)

     wallet.held_balance -= impression_cost
     // Not added to available (consumed)

     WalletTransaction.create(
       transaction_type: CAMPAIGN_CHARGE,
       amount: impression_cost,
       reference_type: "Impression",
       reference_id: impression.id,
       description: "Impression cost",
       status: COMPLETED
     )

     campaign.spent += impression_cost
     campaign.remaining_budget -= impression_cost

   On campaign completion:
     // Release unused budget
     unused_budget = campaign.remaining_budget

     IF unused_budget > 0:
       wallet.held_balance -= unused_budget
       wallet.available_balance += unused_budget

       WalletTransaction.create(
         transaction_type: RELEASE,
         amount: unused_budget,
         reference_type: "Campaign",
         reference_id: campaign.id,
         description: "Unused budget released",
         status: COMPLETED
       )

   On campaign cancellation:
     // Full refund
     wallet.held_balance -= campaign.remaining_budget
     wallet.available_balance += campaign.remaining_budget

     WalletTransaction.create(
       transaction_type: REFUND,
       amount: campaign.remaining_budget,
       reference_type: "Campaign",
       reference_id: campaign.id,
       description: "Campaign cancelled - budget refunded",
       status: COMPLETED
     )

Business Rules:
- Budget hold is atomic (all-or-nothing)
- Held balance cannot be used for other campaigns
- Impression costs deducted from held balance
- Unused budget automatically released
- Cancellation = full refund of remaining budget
- Hold/release transactions logged
```

---

### Rule 4: Supplier Revenue & Payout

#### 4.1 Revenue Accrual

```
Trigger: Impression verified

Process:
1. Calculate supplier share:
   impression_cost = 0.08 // Example
   platform_share = impression_cost × 0.20 = 0.016
   supplier_share = impression_cost × 0.80 = 0.064

2. Credit supplier wallet (held):
   supplier_wallet.held_balance += supplier_share

   WalletTransaction.create(
     transaction_type: REVENUE,
     amount: supplier_share,
     balance_type_affected: HELD,
     reference_type: "Impression",
     reference_id: impression.id,
     description: "Revenue from impression",
     status: COMPLETED
   )

3. Hold period: 7 days (anti-fraud)
   scheduled_release_date = impression.created_at + 7 days

4. After 7 days (no disputes):
   supplier_wallet.held_balance -= supplier_share
   supplier_wallet.available_balance += supplier_share

   WalletTransaction.create(
     transaction_type: RELEASE,
     amount: supplier_share,
     description: "Revenue released after hold period",
     status: COMPLETED
   )

5. If disputed within 7 days:
   // Revenue stays in held_balance
   // If dispute upheld (chargeback):
     supplier_wallet.held_balance -= supplier_share
     // Deducted (lost revenue)

     WalletTransaction.create(
       transaction_type: CHARGEBACK,
       amount: supplier_share,
       reference_type: "Dispute",
       reference_id: dispute.id,
       description: "Chargeback for disputed impression",
       status: COMPLETED
     )

Business Rules:
- Revenue credited immediately but held
- 7-day hold period for fraud prevention
- Auto-release after hold period
- Disputed revenue held until resolved
- Chargebacks deducted from held balance
- Supplier can see held vs available clearly
```

#### 4.2 Supplier Withdrawal

```
Actor: Supplier
Frequency: Anytime (with limits)

Requirements:
- Minimum withdrawal: $50.00
- Available balance >= withdrawal amount + fee
- Bank account verified
- No pending disputes

Withdrawal Fee:
- < $500: $5 fee
- $500-$5,000: $10 fee
- > $5,000: $25 fee

Tax Withholding (US suppliers):
- W9 on file: No withholding
- No W9: 24% backup withholding

Process:
1. Supplier requests withdrawal:
   POST /wallet/withdraw
   {
     "amount": 1000.00,
     "bank_account_id": "ba_xxx"
   }

2. Validation:
   ✓ amount >= $50
   ✓ wallet.available_balance >= amount + fee
   ✓ bank_account verified
   ✓ no_pending_disputes
   ✓ wallet status = ACTIVE

3. Calculate fees and tax:
   withdrawal_amount = 1000.00
   fee = 10.00 // $500-$5k tier
   tax = has_w9 ? 0.00 : (1000.00 × 0.24) = 240.00
   net_amount = 1000.00 - 10.00 - 240.00 = 750.00

4. Create withdrawal request:
   WithdrawalRequest.create(
     wallet_id: wallet.id,
     supplier_id: supplier.id,
     amount: 1000.00,
     fee_amount: 10.00,
     tax_amount: 240.00,
     net_amount: 750.00,
     bank_account_name: "John Doe",
     bank_account_number: "***1234",
     bank_routing_number: "123456789",
     status: PENDING
   )

5. Lock funds:
   wallet.available_balance -= 1000.00
   wallet.pending_balance += 1000.00

   WalletTransaction.create(
     transaction_type: PENDING_WITHDRAWAL,
     amount: 1000.00,
     balance_type_affected: PENDING,
     status: PENDING,
     description: "Withdrawal requested"
   )

6. Admin approval (auto for < $5k):
   IF withdrawal_amount < 5000:
     auto_approve()
   ELSE:
     require_manual_approval()

7. Process payout:
   // Via Stripe Transfer or Bank API
   transfer = Stripe.Transfer.create(
     amount: 75000, // cents
     currency: "usd",
     destination: supplier.stripe_account_id
   )

   IF transfer.status = "paid":
     withdrawal_request.update(
       status: PROCESSING,
       processed_at: NOW()
     )

8. Confirmation (3-5 business days):
   // Webhook from bank/Stripe
   withdrawal_request.update(
     status: COMPLETED,
     completed_at: NOW(),
     reference_number: bank_reference
   )

   wallet.pending_balance -= 1000.00
   // Removed from wallet

   WalletTransaction.create(
     transaction_type: WITHDRAWAL,
     amount: 1000.00,
     fee_amount: 10.00,
     tax_amount: 240.00,
     net_amount: 750.00,
     status: COMPLETED,
     description: "Withdrawal completed"
   )

   Notify supplier: "Withdrawal completed: ${net_amount} sent to bank"

9. Failure handling:
   IF transfer.status = "failed":
     // Refund to available balance
     wallet.pending_balance -= 1000.00
     wallet.available_balance += 1000.00

     withdrawal_request.update(
       status: FAILED,
       failed_at: NOW(),
       failure_reason: transfer.failure_message
     )

     WalletTransaction.create(
       transaction_type: ADJUSTMENT_CREDIT,
       amount: 1000.00,
       description: "Withdrawal failed - refunded",
       status: COMPLETED
     )

     Notify supplier: "Withdrawal failed: {reason}"

Business Rules:
- Minimum $50 withdrawal
- Withdrawal fee based on amount
- Tax withholding if no W9 form
- Funds locked during processing (pending_balance)
- Auto-approval < $5k, manual >= $5k
- Processing time: 3-5 business days
- Failed withdrawals refunded automatically
- All steps logged and auditable
```

---

### Rule 5: Refund Processing

#### 5.1 Refund Types

**Automatic Refunds**:
```
1. Campaign Cancelled (before start):
   - Refund: 100% of budget
   - Processing: Immediate

2. Unused Budget (campaign completed):
   - Refund: Remaining budget
   - Processing: Automatic at completion

3. Disputed Impression (chargeback approved):
   - Refund: Impression cost
   - Processing: After admin review

4. Failed Payment Reversal:
   - Refund: Full amount
   - Processing: Immediate
```

**Manual Refunds** (requires admin approval):
```
1. Customer Service Request:
   - User requests refund for various reasons
   - Admin reviews and approves/rejects
   - Processing: 1-3 business days

2. Platform Error:
   - Technical issue caused overcharge
   - Admin initiates refund
   - Processing: Immediate

3. Partial Refund:
   - Settlement for disputes
   - Admin specifies amount
   - Processing: 1-3 business days
```

#### 5.2 Refund Process

```
Refund Method Priority:
1. Original payment method (if < 90 days)
2. Wallet balance (if payment method failed)
3. Bank transfer (if payment method unavailable)

Process:
1. Create refund request:
   RefundRequest.create(
     wallet_id: wallet.id,
     advertiser_id: advertiser.id,
     campaign_id: campaign.id,
     amount: refund_amount,
     refund_type: type,
     reason: reason,
     status: PENDING
   )

2. Validation:
   ✓ Amount valid (> 0, <= original charge)
   ✓ Original transaction exists
   ✓ Not already refunded
   ✓ Within refund window (90 days for payment gateway)

3. Approval (auto or manual):
   IF auto_refund_eligible(refund_request):
     approve_automatically()
   ELSE:
     assign_to_admin_for_review()

4. Process refund:

   Option A: Gateway refund (< 90 days)
     gateway_refund = Stripe.Refund.create(
       charge: original_charge_id,
       amount: refund_amount_cents
     )

     IF gateway_refund.status = "succeeded":
       wallet.pending_balance += refund_amount
       // Will be available when cleared (1-3 days)

       WalletTransaction.create(
         transaction_type: REFUND,
         amount: refund_amount,
         payment_gateway: STRIPE,
         gateway_transaction_id: gateway_refund.id,
         status: PENDING,
         description: "Refund to original payment method"
       )

   Option B: Wallet balance refund
     wallet.available_balance += refund_amount

     WalletTransaction.create(
       transaction_type: REFUND,
       amount: refund_amount,
       status: COMPLETED,
       description: "Refund credited to wallet"
     )

5. Confirmation:
   refund_request.update(
     status: COMPLETED,
     processed_at: NOW()
   )

   Notify advertiser: "Refund processed: ${amount}"

Business Rules:
- Refund to original payment method preferred
- Wallet credit if payment method unavailable
- Refunds < $1000: auto-approve
- Refunds >= $1000: require admin approval
- 90-day window for gateway refunds
- After 90 days: wallet credit only
- All refunds logged and auditable
- Refund fees: none (absorbed by platform)
```

---

## Currency & Exchange

### Rule 6: Multi-Currency Support

```
Supported Currencies:
- USD (United States Dollar)
- EUR (Euro)
- GBP (British Pound)
- VND (Vietnamese Dong)
- ... (configurable)

Default Currency:
- Based on user's country
- US users: USD
- Vietnam users: VND
- EU users: EUR

Conversion:
- Real-time exchange rates from provider (e.g., OpenExchangeRates.org)
- Rates cached for 1 hour
- Conversion at transaction time (not display time)

Process:
1. User views balance:
   Display in wallet.currency

2. Top-up in different currency:
   User pays: €100 EUR
   User wallet: USD

   conversion_rate = get_rate("EUR", "USD") // 1.08
   usd_amount = 100 × 1.08 = 108.00

   wallet.available_balance += 108.00 USD

   WalletTransaction.create(
     amount: 108.00,
     currency: "USD",
     metadata: {
       original_amount: 100.00,
       original_currency: "EUR",
       exchange_rate: 1.08
     }
   )

3. Cross-currency campaigns:
   Campaign currency: VND
   Advertiser wallet: USD

   impression_cost_vnd = 100,000 VND
   conversion_rate = get_rate("VND", "USD") // 0.000041
   impression_cost_usd = 100,000 × 0.000041 = 4.10 USD

   Deduct 4.10 USD from wallet

Business Rules:
- Wallet has single currency (no multi-currency wallets)
- Conversions at transaction time
- Exchange rate stored in transaction metadata
- Rates updated hourly
- Conversion fees: none (included in exchange rate)
- User can view estimated conversions in dashboard
```

---

## Tax Handling

### Rule 7: Tax Calculation & Withholding

#### 7.1 Sales Tax (for Advertisers)

```
Applicability:
- US-based advertisers: State sales tax on ad spending
- EU-based advertisers: VAT on services
- Other regions: As per local tax law

Tax Rate Determination:
- Based on advertiser billing address
- Lookup tax rate from TaxJar API or similar
- Updated monthly

Calculation:
campaign_budget = 1000.00
tax_rate = get_tax_rate(advertiser.billing_address) // e.g., 8.25%
tax_amount = 1000.00 × 0.0825 = 82.50
total_charge = 1000.00 + 82.50 = 1082.50

// User pays total_charge
// Campaign budget = 1000.00 (pre-tax)
// Tax remitted to authorities

WalletTransaction.create(
  transaction_type: TAX_WITHHOLDING,
  amount: 82.50,
  description: "Sales tax (8.25%)",
  metadata: {
    tax_type: "SALES_TAX",
    tax_rate: 0.0825,
    jurisdiction: "California"
  }
)

Business Rules:
- Tax calculated at campaign creation
- Tax displayed separately in invoice
- Tax remitted to authorities monthly
- Tax-exempt accounts (with certificate) exempted
```

#### 7.2 Withholding Tax (for Suppliers)

```
Applicability:
- US suppliers without W-9 form: 24% backup withholding
- Non-US suppliers: 30% withholding (unless treaty)

Withholding at Payout:
supplier_revenue = 1000.00

IF supplier.has_w9:
  withholding = 0.00
ELSE IF supplier.country = "US":
  withholding = 1000.00 × 0.24 = 240.00
ELSE IF supplier.country IN tax_treaty_countries:
  withholding = 1000.00 × treaty_rate
ELSE:
  withholding = 1000.00 × 0.30 = 300.00

net_payout = 1000.00 - withholding

WalletTransaction.create(
  transaction_type: TAX_WITHHOLDING,
  amount: withholding,
  description: "Tax withholding (24%)",
  metadata: {
    tax_type: "BACKUP_WITHHOLDING",
    tax_rate: 0.24
  }
)

// Supplier receives net_payout
// Withholding remitted to IRS

Year-end Reporting:
- 1099 forms issued to US suppliers
- 1042-S forms issued to non-US suppliers
- Total withheld + total paid reported

Business Rules:
- Withholding applied at withdrawal
- W-9 submission stops withholding
- Treaty rates respected
- Withheld amounts reported to tax authorities
- Forms issued by January 31
```

---

## Financial Reconciliation

### Rule 8: Daily Reconciliation

```
Schedule: Daily at 00:00 UTC

Purpose: Verify financial accuracy

Process:
1. Calculate expected totals:
   expected_balance = (
     opening_balance +
     total_deposits -
     total_withdrawals -
     total_fees
   )

2. Calculate actual totals:
   actual_balance = SUM(
     wallet.available_balance +
     wallet.held_balance +
     wallet.pending_balance
     FOR ALL wallets
   )

3. Compare:
   discrepancy = expected_balance - actual_balance

4. Validate transactions:
   transaction_sum = SUM(
     transactions.net_amount
     WHERE date = yesterday
   )

   IF transaction_sum != (deposits - withdrawals - fees):
     FLAG discrepancy

5. Record reconciliation:
   DailyReconciliation.create(
     reconciliation_date: yesterday,
     total_deposits: deposits,
     total_withdrawals: withdrawals,
     expected_balance: expected_balance,
     actual_balance: actual_balance,
     discrepancy: discrepancy,
     status: discrepancy == 0 ? BALANCED : DISCREPANCY
   )

6. Alert if discrepancy:
   IF abs(discrepancy) > 0.01: // > 1 cent
     send_alert(finance_team, "Reconciliation discrepancy: ${discrepancy}")
     require_investigation()

7. Investigation:
   - Review all transactions for yesterday
   - Check for failed/pending transactions
   - Verify gateway webhooks received
   - Check for race conditions
   - Manual audit if needed

8. Resolution:
   IF discrepancy_resolved:
     DailyReconciliation.update(
       status: RESOLVED,
       discrepancy_reason: explanation,
       reconciled_by: admin.id,
       reconciled_at: NOW()
     )

Business Rules:
- Reconciliation runs daily automatically
- Discrepancies investigated immediately
- Tolerate ±$0.01 (rounding errors)
- Larger discrepancies halt operations until resolved
- All reconciliations auditable
- Monthly reconciliation aggregates daily results
```

---

## Anti-Money Laundering (AML)

### Rule 9: AML Compliance

#### 9.1 Transaction Monitoring

```
Suspicious Activity Indicators:

1. Large Single Transactions:
   IF deposit >= $10,000:
     flag_for_aml_review("Large deposit")

2. Structuring (Smurfing):
   deposits_today = SUM(deposits WHERE date = today)
   IF deposits_today >= $10,000:
     AND max_single_deposit < $5,000:
       flag_for_aml_review("Possible structuring")

3. Rapid In-and-Out:
   IF deposit_today > $5,000:
     AND withdrawal_within_24h > $4,000:
       flag_for_aml_review("Rapid in-and-out")

4. Unusual Pattern:
   IF typical_monthly_deposit < $1,000:
     AND current_deposit > $10,000:
       flag_for_aml_review("Unusual pattern")

5. High-Risk Jurisdiction:
   IF user.country IN high_risk_countries:
     flag_for_aml_review("High-risk jurisdiction")

Action on Flag:
1. Transaction held (pending_balance)
2. Compliance team notified
3. Request additional documentation:
   - Source of funds
   - Business justification
   - Identity verification
4. Review within 24-48 hours
5. Approve or reject

Approval:
  Release funds to available_balance
  Clear flag

Rejection:
  Refund to payment source
  Close account if repeated violations
```

#### 9.2 Know Your Customer (KYC)

```
Verification Tiers:

Tier 1 (Basic):
- Email verified
- Limits: $500/day
- Required: Email only

Tier 2 (Verified):
- Identity verified (ID document)
- Limits: $10,000/day
- Required: Government ID + Selfie

Tier 3 (Enterprise):
- Business verified
- Limits: Custom
- Required: Business registration + Tax ID

Verification Process:
1. User uploads documents
2. Identity verification service (e.g., Stripe Identity)
3. Automated checks:
   - Document authenticity
   - Face match
   - Database checks (sanctions, PEP lists)
4. Manual review if flagged
5. Approval grants higher limits

Business Rules:
- Unverified accounts limited to $500/day
- Verification required for higher limits
- Re-verification every 2 years
- Enhanced due diligence for >$50k/month
- PEP (Politically Exposed Person) flagged for review
- Sanctions list checked automatically
```

---

## Edge Cases & Error Handling

### Edge Case 1: Concurrent Top-ups

```
Scenario: User submits 2 top-ups simultaneously

Race Condition:
  Transaction A: Top-up $500
  Transaction B: Top-up $500
  Daily limit: $1,000

Without locking:
  Both check daily_total = $0
  Both proceed (total = $1,000) → OK
  But if Transaction C also: total = $1,500 → VIOLATION

Solution: Database-level locking
BEGIN TRANSACTION;
SELECT available_balance FROM wallets
WHERE id = X
FOR UPDATE; // Row-level lock

daily_total = get_daily_total_with_lock(user_id)
IF daily_total + amount > daily_limit:
  ROLLBACK;
  ERROR: "Daily limit exceeded"
ELSE:
  wallet.available_balance += amount
  COMMIT;

Business Rule:
- Use row-level locks for balance updates
- Atomic operations (all-or-nothing)
- Retry failed transactions (exponential backoff)
```

### Edge Case 2: Payment Gateway Webhook Delay

```
Scenario: Payment succeeds but webhook delayed

Timeline:
  T+0s: User submits top-up
  T+1s: Payment successful at Stripe
  T+2s: Pending transaction created
  T+3600s: Webhook arrives (1 hour delay)

Problem: User's balance shows pending for 1 hour

Solution: Webhook + Polling Hybrid
1. Create pending transaction immediately
2. Poll payment status every 30 seconds (timeout: 5 min)
3. If status = succeeded:
     Process immediately (don't wait for webhook)
4. Webhook serves as backup/confirmation

Business Rule:
- Poll for 5 minutes max
- Webhook is source of truth (overrides poll if conflict)
- Alert if webhook not received within 1 hour
```

### Edge Case 3: Withdrawal Bank Account Closed

```
Scenario: Supplier's bank account closed, withdrawal fails

Process:
1. Withdrawal initiated:
   wallet.available_balance -= 1000
   wallet.pending_balance += 1000

2. Bank transfer attempted
3. Bank returns error: "Account closed"

4. Handle failure:
   wallet.pending_balance -= 1000
   wallet.available_balance += 1000

   withdrawal_request.update(
     status: FAILED,
     failure_reason: "Bank account closed"
   )

   Notify supplier: "Withdrawal failed - please update bank account"

5. Supplier updates bank account
6. Retry withdrawal

Business Rule:
- Failed withdrawals refunded automatically
- User notified with specific reason
- Can retry after updating bank info
- Max 3 retry attempts
- After 3 failures: manual intervention required
```

---

## Validation Rules

### Wallet Validation Matrix

| Field | Rule | Error Message |
|-------|------|---------------|
| amount | > 0 | "Amount must be positive" |
| amount | Max 2 decimals | "Amount cannot have more than 2 decimal places" |
| top_up_amount | >= $50 | "Minimum top-up is $50" |
| top_up_amount | <= $10,000 | "Maximum top-up is $10,000 per transaction" |
| withdrawal_amount | >= $50 | "Minimum withdrawal is $50" |
| withdrawal_amount | <= available_balance | "Insufficient balance" |
| currency | ISO 4217 code | "Invalid currency code" |
| balance | >= 0 | "Balance cannot be negative" |

---

## Calculations & Formulas

### Formula Summary

#### 1. Total Balance
```
total_balance = available_balance + held_balance + pending_balance

Must equal: SUM(all transactions.net_amount)
```

#### 2. Net Transaction Amount
```
net_amount = amount - fee_amount - tax_amount

Example:
  Withdrawal: $1,000
  Fee: $10
  Tax: $240
  Net: $1,000 - $10 - $240 = $750
```

#### 3. Supplier Revenue Share
```
supplier_revenue = impression_cost × 0.80
platform_revenue = impression_cost × 0.20

Example:
  Impression cost: $0.10
  Supplier: $0.08
  Platform: $0.02
```

#### 4. Daily Reconciliation
```
expected_balance = (
  opening_balance +
  SUM(deposits) -
  SUM(withdrawals) -
  SUM(fees) -
  SUM(taxes)
)

discrepancy = expected_balance - actual_balance

Acceptable if: abs(discrepancy) <= $0.01
```

#### 5. Withdrawal Fee
```
fee = CASE withdrawal_amount
  WHEN < $500: $5
  WHEN $500-$5,000: $10
  WHEN > $5,000: $25
```

#### 6. Tax Withholding
```
US supplier without W-9:
  withholding = amount × 0.24

Non-US supplier without treaty:
  withholding = amount × 0.30

With treaty:
  withholding = amount × treaty_rate
```

---

## Appendix: Transaction Examples

### Example 1: Complete Top-up Flow
```
Initial state:
  available_balance: $100.00

1. User tops up $500:
   pending_balance += $500 → $500.00
   Transaction: PENDING_DEPOSIT, $500

2. Payment clears:
   pending_balance -= $500 → $0.00
   available_balance += $500 → $600.00
   Transaction: DEPOSIT, $500

Final state:
  available_balance: $600.00
  Transaction count: 2
```

### Example 2: Campaign Budget Flow
```
Initial state:
  available_balance: $600.00

1. Create campaign ($500 budget):
   available_balance -= $500 → $100.00
   held_balance += $500 → $500.00
   Transaction: CAMPAIGN_HOLD, $500

2. Impressions recorded ($300 spent):
   held_balance -= $300 → $200.00
   Transaction: CAMPAIGN_CHARGE × N (totaling $300)

3. Campaign completes ($200 unused):
   held_balance -= $200 → $0.00
   available_balance += $200 → $300.00
   Transaction: RELEASE, $200

Final state:
  available_balance: $300.00
  held_balance: $0.00
  Campaign spent: $300
```

### Example 3: Supplier Payout Flow
```
Initial state:
  available_balance: $1,000.00

1. Request withdrawal $1,000:
   available_balance -= $1,000 → $0.00
   pending_balance += $1,000 → $1,000.00
   Transaction: PENDING_WITHDRAWAL, $1,000

2. Deduct fees and tax:
   Fee: $10
   Tax (no W-9): $240
   Net: $750

3. Wire sent:
   pending_balance -= $1,000 → $0.00
   Transaction: WITHDRAWAL, $1,000
   Transaction: FEE, $10
   Transaction: TAX_WITHHOLDING, $240

Final state:
  available_balance: $0.00
  pending_balance: $0.00
  Bank receives: $750
```

---

**Document Status**: Ready for review
**Next Steps**:
1. Review with stakeholders
2. Finance team review
3. Compliance review (AML/KYC)
4. Payment gateway integration planning

---

**Related Documents**:
- `business-rules-campaign.md` - Campaign budget management
- `business-rules-advertiser.md` - Advertiser account & wallet
- `business-rules-supplier.md` - Supplier revenue & payouts
