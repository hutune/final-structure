---
id: "STORY-5.1"
epic_id: "EPIC-005"
title: "Advertiser Wallet Management"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "billing", "wallet", "topup"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm6k"
---

# Advertiser Wallet Management

## User Story

**As an** Advertiser,
**I want** to easily add funds to my advertising budget and track my spending,
**So that** my campaigns can start running immediately without delays, and I always know my budget status.

## Business Context

Advertisers operate on a **prepaid wallet model** - they must have sufficient funds before campaigns can run. This ensures:
- Clear budget control for advertisers (no surprise charges)
- Instant campaign activation without payment delays
- Protection against campaign overspending

The wallet serves as the financial foundation for all advertising operations on the platform.

## Business Rules

> Reference: [07-business-rules-wallet.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/07-business-rules-wallet.md)

### Balance Types
| Type | Description | Rules |
|------|-------------|-------|
| **Available** | Funds ready to use for campaigns | Never negative; reduced by campaign holds |
| **Held** | Escrowed for active campaigns | Equal to sum of active campaign budgets |
| **Pending** | Processing deposits/withdrawals | Max 7 days; auto-alert if exceeded |

### Top-up Limits
- **Minimum:** $50.00 per transaction
- **Maximum:** $10,000.00 per transaction
- **Daily limit:** $50,000.00 per account
- **Transaction limit:** 10 per day
- **Cooldown:** 1 minute between transactions

### Account Tier Limits
- Unverified account: Max $500/day
- Verified account: Max $10,000/day
- Enterprise account: Custom limits

### Payment Methods
- Credit Card (instant)
- Debit Card (instant)
- Bank Transfer (1-3 business days)

## Acceptance Criteria

### Wallet Dashboard
- [ ] User can view current **available balance** prominently on dashboard
- [ ] User can see **held balance** (for active campaigns) separately
- [ ] User receives **low balance alert** when balance falls below user-defined threshold
- [ ] Balance types are clearly explained with tooltips

### Top-up Flow
- [ ] User can initiate top-up with **3 clicks or less**
- [ ] Validation errors shown inline: "Minimum $50", "Maximum $10,000", "Daily limit exceeded"
- [ ] 3D Secure authentication handled for card payments
- [ ] User receives **confirmation email** after successful top-up
- [ ] Failed payment shows **clear error message** with retry option

### Transaction History
- [ ] Transaction history shows: type (deposit, charge, refund), amount, date, reference
- [ ] Transactions can be filtered by type and date range
- [ ] Export to CSV available for accounting

### Balance Integrity
- [ ] Balance **never goes negative** (enforced at database level)
- [ ] All balance changes recorded as immutable transactions
- [ ] `total_balance = available + held + pending` invariant enforced

## Technical Notes

<details>
<summary>API & Database Specs (For Dev Only)</summary>

**API Endpoints:**
```
GET  /api/v1/wallet          # Get wallet with balance breakdown
POST /api/v1/wallet/topup    # Initiate top-up
GET  /api/v1/wallet/transactions  # Transaction history with pagination
```

**Database Schema:**
```sql
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id),
    user_type VARCHAR(20) NOT NULL, -- ADVERTISER / SUPPLIER
    currency VARCHAR(3) DEFAULT 'USD',
    available_balance DECIMAL(12,2) DEFAULT 0 CHECK (available_balance >= 0),
    held_balance DECIMAL(12,2) DEFAULT 0 CHECK (held_balance >= 0),
    pending_balance DECIMAL(12,2) DEFAULT 0 CHECK (pending_balance >= 0),
    min_balance_alert DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    balance_before DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    balance_type_affected VARCHAR(20) NOT NULL, -- AVAILABLE/HELD/PENDING
    status VARCHAR(20) NOT NULL, -- PENDING/COMPLETED/FAILED/REVERSED
    reference_type VARCHAR(50),
    reference_id UUID,
    payment_gateway VARCHAR(20),
    gateway_transaction_id VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Transaction Types:**
- Credit: DEPOSIT, REFUND, REVENUE, ADJUSTMENT_CREDIT, BONUS
- Debit: CAMPAIGN_HOLD, CAMPAIGN_CHARGE, WITHDRAWAL, FEE, TAX_WITHHOLDING
- Hold: HOLD (available→held), RELEASE (held→available)

</details>

## Checklist (Subtasks)

- [ ] Create wallets table migration with balance types
- [ ] Create wallet_transactions table migration
- [ ] Implement auto-create wallet on user registration
- [ ] Implement Get Wallet endpoint with balance breakdown
- [ ] Implement Top-up endpoint with Stripe integration
- [ ] Implement 3D Secure flow handling
- [ ] Implement transaction validation (limits, cooldown)
- [ ] Implement low balance alert trigger
- [ ] Implement transaction history with pagination
- [ ] Implement CSV export
- [ ] Unit tests for balance calculations
- [ ] Integration tests for payment flow

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:15** - Rewrote story with business rules from 07-business-rules-wallet.md. Added balance types, top-up limits, and payment methods.
