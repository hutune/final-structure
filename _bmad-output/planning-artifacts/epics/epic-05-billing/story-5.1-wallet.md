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
**I want** nạp tiền vào ví để chạy campaigns,
**So that** tôi có ngân sách cho quảng cáo.

## Acceptance Criteria

- [ ] GET `/api/v1/wallet` trả về wallet balance và transactions
- [ ] POST `/api/v1/wallet/topup` tạo topup request
- [ ] Wallet balance được cộng khi payment confirmed
- [ ] Transaction history được ghi lại đầy đủ
- [ ] Support multiple currencies (future)

## Technical Notes

**API Endpoints:**
```
GET  /api/v1/wallet
POST /api/v1/wallet/topup
GET  /api/v1/wallet/transactions
```

**Database Tables:**
```sql
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id),
    balance DECIMAL(12,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    type VARCHAR(50) NOT NULL, -- topup, charge, refund
    amount DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    reference_type VARCHAR(50), -- campaign, withdrawal
    reference_id UUID,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_transactions_wallet ON wallet_transactions(wallet_id);
CREATE INDEX idx_transactions_created ON wallet_transactions(created_at);
```

**Wallet Response:**
```json
{
    "balance": 5000.00,
    "currency": "USD",
    "recent_transactions": [
        {
            "id": "uuid",
            "type": "topup",
            "amount": 1000.00,
            "balance_after": 5000.00,
            "created_at": "2026-02-01T10:00:00Z"
        }
    ]
}
```

**Topup Request:**
```json
{
    "amount": 1000.00,
    "payment_method": "credit_card"
}
```

**Transaction Types:**
- `topup` - Money added to wallet
- `charge` - Money deducted for impressions
- `refund` - Money refunded

## Checklist (Subtasks)

- [ ] Tạo wallets table migration
- [ ] Tạo wallet_transactions table migration
- [ ] Auto-create wallet on user registration
- [ ] Implement Get Wallet endpoint
- [ ] Implement Topup endpoint (mock payment for MVP)
- [ ] Implement Transactions History
- [ ] Transaction logging với balance tracking
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
