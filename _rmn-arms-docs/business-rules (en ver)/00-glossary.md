# 📖 RMN-Arms Glossary

**Version**: 1.0
**Last Updated**: 2026-01-23
**Purpose**: Define all technical and business terms used throughout the RMN-Arms project

---

## 📋 Table of Contents

1. [Business Terms](#-business-terms)
2. [Technical Terms](#-technical-terms)
3. [Payment Terms](#-payment-terms)
4. [Status Terms](#-status-terms)
5. [Common Abbreviations](#-common-abbreviations)

---

## 💼 Business Terms

### RMN (Retail Media Network)
**Pronunciation**: /ˌriːteɪl ˈmiːdiə ˈnetwɜːk/

**Definition**: A digital advertising network that allows brands to display ads on digital screens at retail locations (supermarkets, convenience stores, shopping malls, etc.).

**Real-world Examples**:
- LED screens at Big C supermarket entrances
- TV displays in apartment building elevators
- Screens at Circle K checkout counters

**Why It Matters**: Advertising at the point of purchase when customers have buying intent → higher conversion rates.

---

### Advertiser
**Pronunciation**: /ˈædvətaɪzə/

**Definition**: A business or individual who wants to advertise their products/services on digital signage screens.

**Roles in System**:
- Create advertising campaigns
- Top up wallet (prepaid)
- Upload advertising content (images, videos)
- Select stores for display
- Monitor campaign performance

**Examples**:
- Coca-Cola promoting new products
- Fashion stores advertising sales promotions

---

### Supplier (Store Owner)
**Pronunciation**: /səˈplaɪə/

**Definition**: Store or venue owner who provides digital signage screens for advertising.

**Roles in System**:
- Register stores and devices
- Manage screen availability
- Earn revenue from ad displays (80/20 revenue share)
- Set competitor blocking rules

**Examples**:
- 7-Eleven store owner
- Shopping mall management company
- Restaurant chain owner

---

### Campaign
**Pronunciation**: /kæmˈpeɪn/

**Definition**: An advertising project created by an advertiser, including budget, content, target locations, and schedule.

**Campaign Lifecycle**:
```
DRAFT → PENDING_APPROVAL → APPROVED → SCHEDULED → ACTIVE → PAUSED/COMPLETED
```

**Key Properties**:
- Budget (minimum $100)
- CPM rate ($0.10 - $50.00)
- Start and end dates
- Target stores/regions
- Content assignments

---

### Impression
**Pronunciation**: /ɪmˈpreʃn/

**Definition**: One playback of advertising content on a digital signage device.

**Measurement**:
- 1 playback = 1 impression
- Verified through device logs
- Includes proof-of-play validation
- Quality score (0-100) assigned

**Billing**: Charged based on CPM (Cost Per Mille = cost per 1000 impressions)

---

### CPM (Cost Per Mille)
**Pronunciation**: /kɒst pɜː mɪl/

**Definition**: Cost per 1000 impressions. Primary billing model for RMN-Arms.

**Formula**:
```
Cost = (Total Impressions / 1000) × CPM Rate
```

**Example**:
- CPM Rate: $5.00
- Impressions: 10,000
- Cost: (10,000 / 1000) × $5.00 = $50.00

**Rate Range**: $0.10 - $50.00 (configurable per campaign)

---

### Digital Signage
**Pronunciation**: /ˈdɪdʒɪtl ˈsaɪnɪdʒ/

**Definition**: Electronic displays (LED screens, TVs, tablets) that show digital advertising content.

**Types**:
- Wall-mounted LED screens
- Freestanding digital kiosks
- Window displays
- Elevator screens

**Requirements**:
- Internet connectivity
- Device ID registration
- Heartbeat every 5 minutes
- Minimum uptime 95%

---

## 🔧 Technical Terms

### Device (Display Device)
**Definition**: Physical hardware (TV, LED screen, tablet) registered in the system to display advertising content.

**Device States**:
- `ACTIVE` - Operating normally
- `OFFLINE` - No heartbeat for 15+ minutes
- `MAINTENANCE` - Temporarily unavailable
- `DECOMMISSIONED` - Permanently removed

**Key Metrics**:
- Uptime percentage
- Health score (0-100)
- Content sync status
- Last heartbeat timestamp

---

### Heartbeat
**Definition**: Periodic status update sent by devices to prove they are online and operational.

**Frequency**: Every 5 minutes

**Purpose**:
- Confirm device is online
- Report playback logs
- Sync content updates
- Monitor health status

**Timeout**: Device marked OFFLINE if no heartbeat for 15 minutes

---

### Proof-of-Play (PoP)
**Definition**: Cryptographic verification that an impression actually occurred on a device.

**Implementation**:
- RSA 2048-bit signature
- Includes timestamp, device ID, content ID
- Prevents fraud and manipulation
- Verified before billing

---

### Content Asset
**Definition**: A piece of advertising media (image, video) uploaded by advertisers.

**Formats Supported**:
- Images: JPG, PNG (max 10MB)
- Videos: MP4, MOV (max 500MB)
- Durations: 5-60 seconds

**Workflow**:
```
DRAFT → PENDING_MODERATION → APPROVED → PUBLISHED → ARCHIVED
```

---

### Wallet
**Definition**: Prepaid balance account for advertisers to fund campaigns.

**Balance Types**:
- **Available**: Can be allocated to campaigns
- **Held**: Reserved for active campaigns
- **Pending**: Awaiting transaction confirmation

**Operations**:
- Top-up (minimum $50)
- Hold (when campaign activates)
- Spend (per impression)
- Release (when campaign ends)
- Refund (for unused budget)

---

### Quality Score
**Definition**: Numerical rating (0-100) indicating the reliability and quality of an impression.

**Factors**:
- Device reputation (40%)
- Proof-of-play verification (30%)
- Playback duration vs expected (20%)
- Error rate (10%)

**Thresholds**:
- Score ≥ 80: High quality (100% billing)
- Score 60-79: Medium quality (80% billing)
- Score < 60: Low quality (not billed)

---

## 💰 Payment Terms

### Prepaid Model
**Definition**: Advertisers must fund their wallet before campaigns can run.

**Benefits**:
- No credit risk
- Instant campaign activation
- Predictable spending
- Automatic pause when funds depleted

---

### Revenue Share
**Definition**: Distribution of advertising revenue between platform and suppliers.

**Split**: 80/20
- 80% to Supplier (store owner)
- 20% to Platform (RMN-Arms)

**Example**:
- Campaign spends $1000
- Supplier receives $800
- Platform receives $200

---

### Payout
**Definition**: Transfer of earned revenue from supplier balance to bank account.

**Terms**:
- Minimum payout: $50
- Hold period: 7 days (anti-fraud)
- Processing time: 3-5 business days
- Fees: 2.9% + $0.30 (Stripe)

---

### Budget Allocation
**Definition**: Reserving funds from available wallet balance for a campaign.

**Process**:
1. Campaign created with total budget
2. Funds moved from "available" to "held"
3. Spent gradually as impressions occur
4. Remaining balance released when campaign ends

---

## 📊 Status Terms

### Campaign Status

| Status | Description |
|--------|-------------|
| `DRAFT` | Being created, not submitted |
| `PENDING_APPROVAL` | Awaiting admin review |
| `APPROVED` | Approved, waiting for start date |
| `REJECTED` | Rejected by admin |
| `SCHEDULED` | Scheduled for future start |
| `ACTIVE` | Currently running |
| `PAUSED` | Temporarily suspended |
| `COMPLETED` | Finished successfully |

---

### Device Status

| Status | Description |
|--------|-------------|
| `ACTIVE` | Operating normally |
| `OFFLINE` | No heartbeat 15+ minutes |
| `MAINTENANCE` | Temporarily unavailable |
| `DECOMMISSIONED` | Permanently removed |

---

### Content Status

| Status | Description |
|--------|-------------|
| `DRAFT` | Being uploaded |
| `PENDING_MODERATION` | Awaiting approval |
| `APPROVED` | Ready for use |
| `REJECTED` | Failed moderation |
| `PUBLISHED` | Live in campaigns |
| `ARCHIVED` | No longer in use |

---

## 🔤 Common Abbreviations

### Business

| Abbreviation | Full Term | Meaning |
|--------------|-----------|---------|
| RMN | Retail Media Network | Digital advertising network at retail locations |
| CPM | Cost Per Mille | Cost per 1000 impressions |
| CTR | Click-Through Rate | (Not applicable in offline signage) |
| ROI | Return on Investment | Measure of campaign effectiveness |
| KPI | Key Performance Indicator | Metrics to measure success |

---

### Technical

| Abbreviation | Full Term | Meaning |
|--------------|-----------|---------|
| API | Application Programming Interface | System integration endpoints |
| PoP | Proof-of-Play | Verification of impression occurrence |
| CDN | Content Delivery Network | Distributed content hosting |
| JWT | JSON Web Token | Authentication token format |
| RBAC | Role-Based Access Control | Permission management system |
| UUID | Universally Unique Identifier | Unique ID format (128-bit) |
| SQL | Structured Query Language | Database query language |

---

### Units

| Abbreviation | Full Term | Example |
|--------------|-----------|---------|
| KB | Kilobyte | 1024 bytes |
| MB | Megabyte | 1024 KB |
| GB | Gigabyte | 1024 MB |
| ms | Millisecond | 1/1000 second |
| fps | Frames Per Second | Video playback rate |

---

## 📌 Important Concepts

### Impression vs View
- **Impression**: One playback on device (measurable)
- **View**: Person actually seeing the ad (estimated)

**Note**: RMN-Arms bills on impressions, not views, as views are difficult to measure accurately in offline environments.

---

### Campaign Budget Flow
```
Wallet Available Balance
        ↓
   [Allocate to Campaign]
        ↓
    Held Balance
        ↓
 [Impressions Occur]
        ↓
   Spent Balance
        ↓
[Campaign Completes]
        ↓
Remaining → Released back to Available
```

---

### Device Heartbeat Cycle
```
Every 5 minutes:
1. Device sends heartbeat
2. Reports playback logs
3. Receives content updates
4. Updates health status
5. Waits 5 minutes
6. Repeat
```

---

### Revenue Distribution Timeline
```
Impression Occurs → Verified (instant) → Billed (instant) →
Held 7 days → Available for Payout → Request Payout →
Processing 3-5 days → Funds in Bank
```

---

## 🎯 Quick Reference

### Campaign Minimums
- Minimum budget: $100
- Minimum CPM: $0.10
- Minimum duration: 1 day
- Minimum content duration: 5 seconds

### Device Requirements
- Heartbeat interval: 5 minutes
- Minimum uptime: 95%
- Content sync: Every 6 hours
- Health check: Every heartbeat

### Financial Limits
- Minimum wallet top-up: $50
- Minimum payout: $50
- Maximum campaign budget: $1,000,000
- Revenue share: 80/20 (Supplier/Platform)

---

**Last Updated**: 2026-01-23
**Maintained By**: Product Team
**Questions**: Contact product@rmn-arms.com
