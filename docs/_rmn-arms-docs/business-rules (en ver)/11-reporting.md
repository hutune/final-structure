# Business Rules: Reporting & Analytics

**Version**: 1.0  
**Date**: 2026-02-05  
**Status**: Draft  
**Owner**: Product Team  

---

## 1. Overview

### 1.1 Purpose
This document defines the business rules for reporting and analytics capabilities within the RMN platform. It covers what data is available to each user type, how reports are generated, and the metrics that drive business decisions.

### 1.2 Scope
- Campaign performance reports (Advertisers)
- Device and revenue reports (Suppliers)
- Platform-wide analytics (Admins)
- Report scheduling and delivery
- Data retention and access policies

### 1.3 Out of Scope
- Technical implementation details
- Database schemas
- API specifications

---

## 2. Report Categories

### 2.1 Advertiser Reports

| Report Type | Description | Frequency |
|-------------|-------------|-----------|
| **Campaign Performance** | Impressions, spend, CPM by campaign | Real-time + Daily |
| **Content Performance** | Which creatives perform best | Daily |
| **Store Performance** | Performance by store/location | Daily |
| **Time Analysis** | Performance by time of day/week | Weekly |
| **Budget Utilization** | Spend vs budget, pacing | Real-time |

### 2.2 Supplier Reports

| Report Type | Description | Frequency |
|-------------|-------------|-----------|
| **Revenue Summary** | Total earnings, pending payouts | Real-time |
| **Device Performance** | Impressions by device, uptime | Daily |
| **Store Analytics** | Revenue by store | Daily |
| **Payout History** | Withdrawal history, statements | On-demand |
| **Quality Score** | Device health, content sync | Daily |

### 2.3 Admin Reports

| Report Type | Description | Frequency |
|-------------|-------------|-----------|
| **Platform Overview** | Total impressions, revenue, users | Real-time |
| **User Growth** | New advertisers, suppliers | Weekly |
| **Financial Summary** | Platform revenue, payouts | Daily |
| **Quality Metrics** | Fraud rate, verification rate | Daily |
| **SLA Compliance** | Uptime, response times | Monthly |

---

## 3. Business Rules

### Rule 1: Data Access by Role

**Users can only access data they are authorized to see:**

| User Type | Data Access |
|-----------|-------------|
| Advertiser | Own campaigns, own spending, stores where ads run |
| Supplier | Own stores, own devices, own revenue |
| Admin | All platform data |

**Cross-access is NOT allowed:**
- Advertiser A cannot see Advertiser B's campaigns
- Supplier X cannot see Supplier Y's revenue
- Team members see based on their role permissions

---

### Rule 2: Report Generation Timing

**Real-time metrics** (lag ≤ 15 minutes):
- Current balance
- Active campaign count
- Today's impressions
- Today's spend/revenue

**Daily metrics** (updated by 6 AM local time):
- Yesterday's performance summary
- Quality scores
- Device uptime

**Weekly/Monthly metrics** (updated on schedule):
- Trend analysis
- Comparative reports
- Statements

---

### Rule 3: Data Retention

| Data Type | Retention Period |
|-----------|------------------|
| Impression data | 2 years |
| Transaction records | 7 years (legal requirement) |
| Campaign history | 3 years |
| Device logs | 1 year |
| Generated reports | 90 days (then on-demand) |

**After retention period:**
- Data is archived or deleted
- Aggregated summaries may be kept longer
- Legal holds override standard retention

---

### Rule 4: Report Scheduling

**Advertisers and Suppliers can schedule automated reports:**

| Setting | Options |
|---------|---------|
| Frequency | Daily, Weekly, Monthly |
| Delivery | Email with PDF/CSV attachment |
| Recipients | Account owner + added emails |
| Time | User-configured (default 8 AM local) |

**Limits by tier:**
- FREE: No scheduled reports
- BASIC: 2 scheduled reports
- PREMIUM: 10 scheduled reports
- ENTERPRISE: Unlimited

---

### Rule 5: Export Capabilities

**All users can export data in:**
- PDF (formatted reports)
- CSV (raw data)
- Excel (for Premium+)

**Export limits:**
- Maximum 100,000 rows per export
- Maximum 12 months of data per export
- Large exports queued and delivered via email

---

### Rule 6: Dashboard Metrics

#### Advertiser Dashboard

| Metric | Definition |
|--------|------------|
| Total Spend | Sum of all campaign costs |
| Total Impressions | Verified impressions delivered |
| Average CPM | Total Spend / (Impressions / 1000) |
| Active Campaigns | Campaigns with status ACTIVE |
| Top Performing Campaign | Highest impressions this period |

#### Supplier Dashboard

| Metric | Definition |
|--------|------------|
| Total Revenue | Sum of all earnings (including pending) |
| Available Balance | Ready for withdrawal |
| Pending Balance | Within 7-day hold period |
| Total Impressions | All verified impressions on devices |
| Device Uptime | Average uptime across all devices |
| Quality Score | Weighted score 0-100 |

---

### Rule 7: Comparative Analysis

**Users can compare:**
- This period vs previous period
- Campaign A vs Campaign B (same advertiser)
- Store A vs Store B (same supplier)
- Device performance within same store

**Users CANNOT compare:**
- Their data vs other users (privacy)
- Industry benchmarks (not available in MVP)

---

### Rule 8: Alerts and Thresholds

**System generates alerts when thresholds are crossed:**

| Alert | Threshold | Priority |
|-------|-----------|----------|
| Low Balance | < 3 days of avg spend | HIGH |
| Campaign Underperforming | < 50% of expected impressions | MEDIUM |
| Device Offline | > 10 minutes | HIGH |
| Budget Nearly Exhausted | > 90% spent | MEDIUM |
| Unusual Activity | Fraud score > threshold | HIGH |

---

## 4. Report Definitions

### 4.1 Campaign Performance Report

**Includes:**
- Campaign name and status
- Date range
- Total impressions delivered
- Total amount spent
- Average CPM achieved
- Impressions by day/hour
- Top 10 stores by impressions
- Content performance breakdown

---

### 4.2 Revenue Report (Supplier)

**Includes:**
- Period summary (week/month)
- Total impressions served
- Gross revenue
- Platform fee (20%)
- Net revenue
- Breakdown by store
- Breakdown by device
- Pending vs available balance

---

### 4.3 Platform Overview (Admin)

**Includes:**
- Total active advertisers
- Total active suppliers
- Total active devices
- Total impressions (period)
- Total revenue (period)
- Top advertisers by spend
- Top suppliers by revenue
- Quality metrics summary

---

## 5. Privacy and Compliance

### Rule 9: Data Privacy

- Reports do NOT expose individual user identity
- Aggregate data only for platform-level reports
- Personal data (email, phone) never in reports
- Financial data masked in shared reports (if any)

### Rule 10: Audit Trail

- All report access is logged
- Export actions are recorded
- Large data requests flagged for review
- Unusual access patterns trigger alert
