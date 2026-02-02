---
id: "STORY-3.4"
epic_id: "EPIC-003"
title: "Supplier Revenue Dashboard APIs"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "supplier", "revenue", "wallet"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Supplier Revenue Dashboard APIs

## User Story

**As a** Supplier,
**I want** xem doanh thu và yêu cầu rút tiền,
**So that** tôi có thể theo dõi thu nhập từ quảng cáo.

## Acceptance Criteria

- [ ] GET `/api/v1/supplier/revenue` trả về revenue summary
- [ ] Revenue breakdown theo store và device
- [ ] POST `/api/v1/supplier/withdrawals` tạo withdrawal request
- [ ] GET `/api/v1/supplier/withdrawals` trả về withdrawal history
- [ ] Withdrawal có status: pending, processing, completed, rejected

## Technical Notes

**API Endpoints:**
```
GET  /api/v1/supplier/revenue?period=month
GET  /api/v1/supplier/revenue/history?from={date}&to={date}
POST /api/v1/supplier/withdrawals
GET  /api/v1/supplier/withdrawals
GET  /api/v1/supplier/withdrawals/{id}
```

**Database Tables:**
```sql
CREATE TABLE supplier_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID UNIQUE NOT NULL REFERENCES users(id),
    balance DECIMAL(12,2) DEFAULT 0,
    pending_balance DECIMAL(12,2) DEFAULT 0,
    total_earned DECIMAL(12,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    bank_name VARCHAR(255),
    account_number VARCHAR(100),
    account_holder VARCHAR(255),
    notes TEXT,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_withdrawals_supplier ON withdrawal_requests(supplier_id);
CREATE INDEX idx_withdrawals_status ON withdrawal_requests(status);
```

**Revenue Summary Response:**
```json
{
    "period": "2026-02",
    "total_revenue": 3200.00,
    "total_impressions": 640000,
    "by_store": [
        {
            "store_id": "uuid",
            "store_name": "Store A",
            "revenue": 1800.00,
            "impressions": 360000
        }
    ],
    "by_device": [
        {
            "device_id": "uuid",
            "device_name": "Screen 1",
            "revenue": 500.00
        }
    ],
    "wallet": {
        "balance": 2500.00,
        "pending": 700.00
    }
}
```

**Withdrawal Request:**
```json
{
    "amount": 1000.00,
    "bank_name": "Vietcombank",
    "account_number": "1234567890",
    "account_holder": "Nguyen Van A"
}
```

## Checklist (Subtasks)

- [ ] Tạo supplier_wallets table migration
- [ ] Tạo withdrawal_requests table migration
- [ ] Implement Get Revenue Summary
- [ ] Implement Revenue History
- [ ] Implement Create Withdrawal Request
- [ ] Implement List Withdrawals
- [ ] Validate withdrawal amount <= balance
- [ ] Admin endpoints cho withdrawal processing
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
