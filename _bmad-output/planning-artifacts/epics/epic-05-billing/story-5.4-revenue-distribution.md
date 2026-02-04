---
id: "STORY-5.4"
epic_id: "EPIC-005"
title: "Revenue Distribution to Suppliers"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "billing", "revenue", "supplier"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm68"
---

# Revenue Distribution to Suppliers

## User Story

**As a** System,
**I want** tự động chia doanh thu cho suppliers sau mỗi impression,
**So that** suppliers nhận 80% revenue từ quảng cáo tại cửa hàng họ.

## Acceptance Criteria

- [ ] Revenue split: 80% supplier, 20% platform
- [ ] Supplier wallet được cộng sau mỗi impression
- [ ] Revenue distribution record được tạo
- [ ] Daily settlement aggregates và reports

## Technical Notes

**Revenue Split Configuration:**
```yaml
revenue:
  supplier_share: 0.80
  platform_share: 0.20
```

**Database Table:**
```sql
CREATE TABLE revenue_distributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    billing_record_id UUID NOT NULL REFERENCES billing_records(id),
    supplier_id UUID NOT NULL REFERENCES users(id),
    store_id UUID NOT NULL,
    gross_amount DECIMAL(12,4) NOT NULL,
    supplier_amount DECIMAL(12,4) NOT NULL,
    platform_amount DECIMAL(12,4) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, settled
    settled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_revenue_supplier ON revenue_distributions(supplier_id);
CREATE INDEX idx_revenue_status ON revenue_distributions(status);
```

**Distribution Flow:**
```
Billing Record Created
       ↓
Revenue Distribution Service
       ↓
Calculate Split (80/20)
       ↓
Create Revenue Distribution Record
       ↓
Update Supplier Wallet (pending_balance)
       ↓
Daily Settlement Job
       ↓
Move pending_balance to balance
       ↓
Mark distributions as settled
```

**Implementation:**
```go
func (s *RevenueService) Distribute(billingRecord *BillingRecord) error {
    supplierAmount := billingRecord.Cost.Mul(decimal.NewFromFloat(0.80))
    platformAmount := billingRecord.Cost.Mul(decimal.NewFromFloat(0.20))

    distribution := &RevenueDistribution{
        BillingRecordID: billingRecord.ID,
        SupplierID: billingRecord.SupplierID,
        StoreID: billingRecord.StoreID,
        GrossAmount: billingRecord.Cost,
        SupplierAmount: supplierAmount,
        PlatformAmount: platformAmount,
        Status: "pending",
    }
    s.repo.Create(distribution)

    // Add to pending balance
    s.walletService.AddPendingBalance(billingRecord.SupplierID, supplierAmount)

    return nil
}
```

## Checklist (Subtasks)

- [ ] Tạo revenue_distributions table migration
- [ ] Implement Revenue Distribution Service
- [ ] Calculate split based on config
- [ ] Update supplier pending_balance
- [ ] Implement daily settlement job
- [ ] Move pending to available balance
- [ ] Mark distributions as settled
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
