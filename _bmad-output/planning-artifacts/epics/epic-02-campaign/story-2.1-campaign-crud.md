---
id: "STORY-2.1"
epic_id: "EPIC-002"
title: "Campaign Creation & Management"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "campaign", "crud", "api"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmh9"
---

# Campaign Creation & Management

## User Story

**As an** Advertiser,
**I want** to easily create and manage advertising campaigns,
**So that** I can promote my products at retail locations and reach customers when they're ready to buy.

## Business Context

Campaigns are the core product advertisers pay for. A well-designed campaign workflow:
- Guides advertisers through all required steps
- Prevents common mistakes with validation
- Maximizes the number of eligible stores for each campaign
- Provides accurate estimates before spending money

## Business Rules

> Reference: [04-business-rules-campaign.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/04-business-rules-campaign.md)

### Campaign Lifecycle
```
DRAFT → PENDING_APPROVAL → SCHEDULED → ACTIVE → PAUSED → COMPLETED
                 ↓                                   ↓
              REJECTED                           CANCELLED
```

### Validation Rules
| Field | Rule | Error Message |
|-------|------|---------------|
| `name` | 3-100 chars, unique per advertiser | "Campaign name already exists" |
| `budget` | $100 - $1,000,000 | "Minimum budget is $100" |
| `start_date` | ≥ NOW + 24 hours | "Start date must be at least 24 hours in future" |
| `end_date` | ≤ start_date + 365 days | "Campaign duration cannot exceed 1 year" |
| `daily_cap` | If set, ≥ $10 AND ≤ budget | "Daily cap invalid" |
| `content_assets` | 1-10 approved assets | "At least 1 content asset required" |
| `target_stores` | 1-1000 active stores | "No stores match your targeting criteria" |

### Edit Restrictions
| Status | Can Edit |
|--------|----------|
| DRAFT | All fields |
| PENDING_APPROVAL | None (awaiting review) |
| SCHEDULED | Budget (increase only), end_date (extend) |
| ACTIVE | Budget (increase), end_date (extend), pause |
| PAUSED | Resume, budget, end_date |
| COMPLETED | None |
| CANCELLED | None |

### Delete Rules
- Only DRAFT campaigns can be deleted
- Soft delete (set deleted_at timestamp)
- Hard delete after 30 days

## Acceptance Criteria

### Campaign Creation Wizard
- [ ] Step 1: Basic info (name, description, brand, category, budget, dates)
- [ ] Step 2: Content selection (from approved assets library)
- [ ] Step 3: Store targeting (manual or criteria-based)
- [ ] Step 4: Review with estimates (impressions, cost, CPM)
- [ ] Progress saved automatically (can return later)

### For Advertisers
- [ ] Campaign created in DRAFT status initially
- [ ] Clear validation messages for each field
- [ ] Budget held from wallet on submission
- [ ] Email confirmation when campaign submitted
- [ ] Edit allowed only in permitted states per table above

### For Accuracy
- [ ] Impression estimates shown before submission
- [ ] Blocked stores clearly listed with reasons
- [ ] Cannot access other advertisers' campaigns

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
POST   /api/v1/campaigns              # Create draft
GET    /api/v1/campaigns/{id}         # Get details
PUT    /api/v1/campaigns/{id}         # Update (state-restricted)
DELETE /api/v1/campaigns/{id}         # Soft delete (DRAFT only)
POST   /api/v1/campaigns/{id}/submit  # Submit for approval/scheduling
```

**Database Schema:**
```sql
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    brand_name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    budget DECIMAL(10,2) NOT NULL CHECK (budget >= 100),
    spent DECIMAL(10,2) DEFAULT 0,
    remaining_budget DECIMAL(10,2) GENERATED ALWAYS AS (budget - spent) STORED,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'DRAFT',
    daily_cap DECIMAL(10,2),
    target_stores UUID[] NOT NULL,
    blocked_stores UUID[] DEFAULT '{}',
    content_assets UUID[] NOT NULL,
    priority INTEGER DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    activated_at TIMESTAMP,
    completed_at TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE(advertiser_id, name)
);
```

**Category Enum:**
FOOD_BEVERAGE, ELECTRONICS, FASHION_APPAREL, HEALTH_BEAUTY, HOME_GARDEN, AUTOMOTIVE, ENTERTAINMENT, FINANCIAL_SERVICES, TELECOM, OTHER

</details>

## Checklist (Subtasks)

- [ ] Create Campaign Service structure
- [ ] Create campaigns table migration with all fields
- [ ] Implement multi-step creation wizard
- [ ] Implement validation per business rules
- [ ] Implement edit restrictions by status
- [ ] Implement soft delete for DRAFT campaigns
- [ ] Implement authorization (owner check)
- [ ] Implement budget hold on submission
- [ ] Unit tests for all validation rules
- [ ] Integration tests for full workflow

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-04 19:30** - Rewrote with business rules from 04-business-rules-campaign.md. Added creation wizard, edit restrictions, and validation rules.
