---
id: "STORY-1.4"
epic_id: "EPIC-001"
title: "User & Account Rules"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["business-rules", "user", "advertiser", "supplier", "verification"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# User & Account Rules

## Purpose

Define all rules governing user registration, verification, and account management.

## Business Rules Overview

> Reference: [08-business-rules-advertiser.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/08-business-rules-advertiser.md)
> Reference: [09-business-rules-supplier.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/09-business-rules-supplier.md)

### User Types
| Type | Role | Requirements |
|------|------|--------------|
| Advertiser | Buy ad space | Business license, payment method |
| Supplier | Sell ad space | Business license, store verification |
| Admin | Platform operator | Internal approval |

### Registration Flow
```
REGISTERED → EMAIL_VERIFIED → KYC_PENDING → ACTIVE
                                    ↓
                               KYC_REJECTED
```

### Advertiser Tiers
| Tier | Requirement | Benefits |
|------|-------------|----------|
| Basic | $0-999 spent | Standard support, 24h approval |
| Professional | $1000-9999 spent | Priority support, 8h approval |
| Enterprise | $10,000+ spent | Dedicated manager, instant approval |

### Supplier Tiers
| Tier | Devices | Benefits |
|------|---------|----------|
| Starter | 1-10 | Standard payouts |
| Growth | 11-50 | Faster payouts, analytics |
| Enterprise | 50+ | Custom terms, dedicated support |

### Store Verification
| Method | Criteria |
|--------|----------|
| Automated | Address geocoding (commercial zone) |
| Manual | Storefront photo + business license |
| SLA | 3 business days |

### Device Limits per Store
| Square Footage | Max Devices |
|----------------|-------------|
| < 1,000 | 1 |
| 1,000 - 2,999 | 2 |
| 3,000 - 4,999 | 3 |
| 5,000 - 9,999 | 5 |
| ≥ 10,000 | 10 |

### Account Suspension Grounds
- Terms of service violation
- Fraudulent activity
- Non-payment (advertisers)
- Device tampering (suppliers)
- Copyright violations

## Acceptance Criteria

- [ ] All user types have clear verification paths
- [ ] Tiers automatically calculated
- [ ] Suspension rules enforced consistently
- [ ] Store/device limits enforced

## Checklist (Subtasks)

- [ ] Document user type requirements
- [ ] Document tier thresholds
- [ ] Document verification process
- [ ] Document suspension procedures
- [ ] Review with legal/compliance

## Updates

**2026-02-05 09:37** - Created as business rules story for user and account domain.
