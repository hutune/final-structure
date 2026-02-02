# 📋 Product Requirements Document (PRD)

## RMN-Arms Project
### Retail Advertising Management Platform

**Version**: 1.0  
**Date**: 2026-01-23  
**Status**: Draft  
**Owner**: Product Team

---

## 📖 Table of Contents

1. [Overview](#-overview)
2. [Goals & Core Values](#-goals--core-values)
3. [Target Users](#-target-users)
4. [Functional Requirements](#-functional-requirements)
5. [Campaign Structure & Billing](#-campaign-structure--billing)
6. [CRM/CMS Features](#-crmcms-features)
7. [Competitor Blocking](#-competitor-blocking)
8. [Device Management](#-device-management)
9. [Technical Requirements](#-technical-requirements)
10. [Milestone Plan](#-milestone-plan)
11. [KPI Metrics](#-kpi-metrics)
12. [Risk Mitigation Strategy](#-risk-mitigation-strategy)

---

## 🎯 Overview

### What is this project?

**RMN-Arms** is a SaaS (Software as a Service) platform for managing advertisements based on the **Retail Media Network (RMN)** model.

> 💡 **Simple Explanation**: This system helps brands advertise their products on TV/LED screens in stores, supermarkets, and shopping centers. Store owners earn money by renting out screen space, while brands reach customers right when they're shopping.

### System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        RMN-Arms Platform                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐         ┌──────────────┐                     │
│   │  Advertiser  │         │   Supplier   │                     │
│   │              │         │ (Store Owner)│                     │
│   └──────┬───────┘         └──────┬───────┘                     │
│          │                        │                              │
│          │  Create campaigns      │  Register stores            │
│          │  Add funds             │  Register devices           │
│          │  Upload content        │  Set blocking rules         │
│          │                        │  Receive revenue            │
│          │                        │                              │
│          └────────────┬───────────┘                              │
│                       │                                          │
│                       ▼                                          │
│              ┌────────────────┐                                  │
│              │   Admin Panel  │                                  │
│              │                │                                  │
│              └────────┬───────┘                                  │
│                       │                                          │
│                       ▼                                          │
│    ┌──────────────────────────────────────────┐                 │
│    │           Backend System                 │                 │
│    │  • Campaign management                   │                 │
│    │  • Impression-based billing              │                 │
│    │  • Content distribution                  │                 │
│    │  • Device monitoring                     │                 │
│    └──────────────────────────────────────────┘                 │
│                       │                                          │
│                       ▼                                          │
│    ┌──────────────────────────────────────────┐                 │
│    │         Devices at stores                │                 │
│    │    📺 Screen 1      📺 Screen 2          │                 │
│    │    📺 Screen 3      📺 Screen N          │                 │
│    └──────────────────────────────────────────┘                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Brief Description

| Aspect | Description |
|--------|-------------|
| **Product Type** | SaaS Platform |
| **Domain** | Digital Advertising |
| **Business Model** | Commission-based (% from each transaction) |
| **Target Audience** | Advertisers + Retail Store Owners |

---

## 🏆 Goals & Core Values

### 1.1 Service Goals

#### For Advertisers
- ✅ Easily create advertising campaigns on digital signage
- ✅ Flexible budget funding and payment
- ✅ Choose stores/regions to display ads
- ✅ Track campaign performance in real-time

#### For Suppliers (Store Owners)
- ✅ Register and manage display devices in stores
- ✅ Control advertising time slots
- ✅ Automatically sell ad slots
- ✅ Block competitor advertisements
- ✅ Receive passive revenue from impressions

#### For Admin
- ✅ Manage all accounts, devices, campaigns
- ✅ Monitor payment flows
- ✅ Approve advertising content
- ✅ View platform-wide statistics

### 1.2 Core Values

```
┌────────────────────────────────────────────────────────────┐
│                    CORE VALUES                             │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1️⃣  INTEGRATED MANAGEMENT                                 │
│      Advertisers + Suppliers on the same web platform     │
│                                                            │
│  2️⃣  AUTOMATED BILLING                                     │
│      Charge based on impressions                          │
│      Real-time or daily settlement                        │
│                                                            │
│  3️⃣  TARGETING & COMPETITOR BLOCKING                       │
│      Select display locations by region, store type       │
│      Suppliers set their own competitor blocking rules    │
│                                                            │
│  4️⃣  CENTRALIZED CONTENT MANAGEMENT (CMS)                  │
│      Upload, approve, distribute content from one place   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 👥 Target Users

### 2.1 Advertiser

> **Who are they?** Businesses or individuals who want to promote products/services at retail locations.

**What they can do:**

| Function | Description |
|----------|-------------|
| 📢 Create campaigns | Set up information, schedule, budget |
| 💰 Add funds | Add money to wallet to run campaigns |
| 📊 Track | View impressions, remaining budget, CTR |
| 🎨 Upload content | Upload advertising images, videos |
| 📺 Register own screens | Can register devices if they have their own stores |

**Example users:**
- 🏢 Coca-Cola company promoting new products
- 👕 Canifa fashion chain advertising promotions
- 📱 Phone store introducing new iPhone

---

### 2.2 Supplier (Store Owner)

> **Who are they?** Owners of stores/premises with installed advertising screens.

**What they can do:**

| Function | Description |
|----------|-------------|
| 🏪 Register stores | Add store information, address |
| 📺 Register devices | Add screens, configure parameters |
| ⏰ Set time slots | Configure advertising operating hours |
| 🔍 Monitor devices | View online/offline status, errors |
| 🚫 Block competitors | Set rules to prevent competitor ads |
| 💵 Receive revenue | 80% from each impression |

**Example users:**
- 🛒 VinMart supermarket chain
- 🏢 Office building management
- ☕ Highlands Coffee chain

---

### 2.3 System Administrator (Super Admin)

> **Who are they?** Staff operating the RMN-Arms platform.

**What they can do:**

| Function | Description |
|----------|-------------|
| 👤 Account management | Approve, lock, delete accounts |
| 💳 Payment management | Set policies, handle disputes |
| 📊 View statistics | Platform-wide reports |
| ✅ Approve content | Review and approve/reject ads |
| ⚙️ System configuration | Set prices, fees, policies |

---

## 📋 Functional Requirements

### 3.1 Authentication & Account Management

```
┌────────────────────────────────────────────────────────────┐
│                    ACCOUNT SYSTEM                          │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  📧 Email-based Registration/Login                        │
│     • Send verification email                             │
│     • Password reset                                      │
│                                                            │
│  👤 Single Account Structure                              │
│     • One account can be Advertiser or Supplier          │
│     • Role-based permissions                              │
│                                                            │
│  🔐 Separate Super Admin Account                         │
│     • Not publicly registered                             │
│     • Only created by system                              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### 3.2 Advertiser Dashboard

**Main Interface:**

```
┌─────────────────────────────────────────────────────────────┐
│  🏠 Advertiser Dashboard                       [Username ▼] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Wallet      │  │ Active      │  │ Total       │         │
│  │ Balance     │  │ Campaigns   │  │ Impressions │         │
│  │ $5,000      │  │ Running: 3  │  │ 125,000     │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  📊 This Week's Performance                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │     ▄▄                                              │   │
│  │  ▄▄ ██ ▄▄    ▄▄                                    │   │
│  │  ██ ██ ██ ▄▄ ██ ▄▄ ▄▄                              │   │
│  │  ██ ██ ██ ██ ██ ██ ██                              │   │
│  │  Mo Tu We Th Fr Sa Su                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  📋 Recent Campaigns                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Name            │ Status      │ Budget  │ Spent     │   │
│  │ New Year Sale   │ 🟢 Running   │ $2,000  │ $1,245    │   │
│  │ Product Launch  │ 🟡 Scheduled │ $1,000  │ $0        │   │
│  │ 50% Off Sale    │ ⚫ Completed │ $500    │ $500      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [+ New Campaign]  [💰 Add Funds]  [📁 Library]           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Main Functions:**

| # | Function | Detailed Description |
|---|----------|----------------------|
| 1 | Create & manage campaigns | Create new, edit, pause, cancel campaigns |
| 2 | Add budget | Add money to wallet via card/bank transfer (prepaid) |
| 3 | Track status | View impressions, remaining budget, CTR |
| 4 | Upload ads | Upload images, videos (CMS integration) |
| 5 | Register own screens | If they have stores, register own devices |

---

### 3.3 Supplier Dashboard

**Main Interface:**

```
┌─────────────────────────────────────────────────────────────┐
│  🏪 Supplier Dashboard                         [Username ▼] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Monthly     │  │ Active      │  │ Active      │         │
│  │ Revenue     │  │ Devices     │  │ Stores      │         │
│  │ $3,200      │  │ 45/50       │  │ 12          │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  📺 Device Status                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Device      │ Store        │ Status    │ Revenue    │   │
│  │ DVC-001     │ Le Loi Store │ 🟢 Online  │ $120       │   │
│  │ DVC-002     │ Le Loi Store │ 🟢 Online  │ $95        │   │
│  │ DVC-003     │ Nguyen Hue   │ 🔴 Offline │ $0         │   │
│  │ DVC-004     │ Tran Phu     │ 🟡 Maintenance│ $0      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [+ Add Store]  [+ Add Device]  [💵 Withdraw]             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Main Functions:**

| # | Function | Detailed Description |
|---|----------|----------------------|
| 1 | Register stores & devices | Add stores, assign devices to stores |
| 2 | Monitor devices | View online/offline status, playback errors |
| 3 | Configure ad slots | Set time slots, playback frequency |
| 4 | Block competitors | Set competitor ad blocking rules |
| 5 | View & withdraw revenue | Track earnings, request withdrawals |

---

### 3.4 Super Admin Dashboard

**Main Functions:**

| # | Function | Detailed Description |
|---|----------|----------------------|
| 1 | Account management | User/store/device list, approve/lock |
| 2 | Payment policy settings | Configure CPM pricing, fees, revenue split |
| 3 | Campaign monitoring | View all campaigns, platform statistics |
| 4 | Approve/reject content | Review ads before playback |
| 5 | Dispute resolution | Handle complaints from Advertisers/Suppliers |

---

## 💰 Campaign Structure & Billing

### 4.1 Campaign Creation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                  CAMPAIGN CREATION FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Step 1                Step 2                Step 3            │
│  ┌─────────┐           ┌─────────┐           ┌─────────┐       │
│  │ Click   │    ──►    │ Upload  │    ──►    │ Select  │       │
│  │ "Create │           │ or      │           │ stores/ │       │
│  │ Campaign"│          │ select  │           │ regions │       │
│  │         │           │ content │           │         │       │
│  └─────────┘           └─────────┘           └─────────┘       │
│                                                                 │
│                              │                                  │
│                              ▼                                  │
│                                                                 │
│   Step 6                Step 5                Step 4            │
│  ┌─────────┐           ┌─────────┐           ┌─────────┐       │
│  │ Confirm │    ◄──    │ Review  │    ◄──    │ Set     │       │
│  │ & Submit│           │ summary │           │ schedule│       │
│  │ for     │           │         │           │ &       │       │
│  │ approval│           │         │           │ budget  │       │
│  │         │           │         │           │         │       │
│  └─────────┘           └─────────┘           └─────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Step Details:**

| Step | Action | Details |
|------|--------|---------|
| 1 | Start | Click "Create New Campaign" button |
| 2 | Select content | Upload new or select from library |
| 3 | Choose locations | Select specific stores or by region |
| 4 | Configure | Set start date, end date, budget |
| 5 | Review | Check all information, cost estimate |
| 6 | Confirm | Agree to terms, submit for approval (if needed) |

---

### 4.2 Impression-based Billing Model

```
┌─────────────────────────────────────────────────────────────────┐
│                  BILLING MODEL                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📊 UNIT PRICE BASED ON:                                       │
│     • Screen playback frequency                                │
│     • Duration per play                                        │
│     • Estimated views (based on foot traffic)                  │
│                                                                 │
│  ⏰ SETTLEMENT:                                                 │
│     • Real-time (per impression)                               │
│     • Or daily aggregation                                     │
│                                                                 │
│  ⚠️ AUTO-SUSPEND ON BUDGET DEPLETION                          │
│     Campaign stops immediately when balance = 0                │
│                                                                 │
│  💵 AUTO REVENUE DISTRIBUTION TO SUPPLIER                      │
│     Supplier receives 80% after each valid impression          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Cost Calculation Formula:**

```
Cost per impression = CPM price ÷ 1000

Example:
• CPM price = $5 (5 dollars for 1000 impressions)
• Cost per impression = $5 ÷ 1000 = $0.005

If campaign has 100,000 impressions:
• Total cost = 100,000 × $0.005 = $500
```

**Revenue Split:**

```
┌────────────────────────────────────────────────────────┐
│            100% Cost from Advertiser                   │
│                    ($500)                              │
├───────────────────────────┬────────────────────────────┤
│         80%               │           20%              │
│    Supplier receives      │      Platform keeps        │
│       ($400)              │         ($100)             │
└───────────────────────────┴────────────────────────────┘
```

---

## 📁 CRM/CMS Features

### Advertising Content Management

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTENT MANAGEMENT SYSTEM                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📤 CONTENT UPLOAD                                             │
│     • Supported: Images (JPG, PNG), Video (MP4)               │
│     • Maximum size: 500MB                                      │
│     • Resolution: 1920x1080 or higher                         │
│                                                                 │
│  ⚙️ PLAYBACK RULE SETTINGS                                    │
│     • Display duration per play                                │
│     • Repeat frequency                                         │
│     • Priority time slots                                      │
│                                                                 │
│  ✅ CONTENT APPROVAL WORKFLOW                                  │
│     Upload → Pending → Approve/Reject → Ready to use          │
│                                                                 │
│  📋 PLAYLIST MANAGEMENT                                        │
│     • Create playlists                                         │
│     • Arrange content order                                    │
│     • Assign playlists to devices                              │
│                                                                 │
│  🎯 DISTRIBUTION BY STORE/DEVICE                              │
│     • Send content to specific devices                         │
│     • Sync via CDN                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚫 Competitor Blocking Feature

### 6.1 Blocking Rule Definition

> **Purpose**: Allow Suppliers to prevent competitor advertisements from displaying at their stores.

**How to Set Up:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    BLOCKING RULE SETUP                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Suppliers define "blocking keywords" based on:                │
│                                                                 │
│  📦 STORE TYPE                                                 │
│     Example: Electronics store → Block other electronics brands│
│                                                                 │
│  🏷️ PRODUCT CATEGORY                                          │
│     Example: Selling soft drinks → Block "Beverages" category  │
│                                                                 │
│  🏢 SPECIFIC BRAND NAME                                        │
│     Example: Samsung dealer → Block "Apple", "Oppo", "Xiaomi" │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPETITOR BLOCKING FLOW                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Step 1: Check during campaign distribution                    │
│  ──────────────────────────────────────────                    │
│     • System matches ad metadata                               │
│       with blocking keywords of each store                     │
│                                                                 │
│  Step 2: Handle conflicts when detected                        │
│  ──────────────────────────────────────────                    │
│     • Automatically exclude that store from list               │
│     • Ad will NOT play at this store                           │
│                                                                 │
│  Step 3: Suggest alternatives to Advertiser                    │
│  ──────────────────────────────────────────                    │
│     • Display list of blocked stores                           │
│     • Recommend alternative stores (not blocked)               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Real-world Example:**

```
🏪 Store: "Samsung Dealer Le Loi"
🚫 Blocking rules: ["Apple", "Oppo", "Xiaomi", "Vivo"]

📢 Campaign: "iPhone 15 Advertisement"
🏷️ Brand: "Apple"

Result: ❌ This campaign CANNOT display at "Samsung Dealer Le Loi"
```

---

## 📺 Device Management (Digital Signage)

### Device Management Functions

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVICE MANAGEMENT                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📝 DEVICE REGISTRATION                                        │
│     • By Device ID or QR code scan                             │
│     • Assign to specific store                                 │
│                                                                 │
│  ⏰ OPERATING HOURS SETTINGS                                   │
│     • Based on store opening hours                             │
│     • Customize for holidays/weekends                          │
│                                                                 │
│  💓 STATUS MONITORING (Heartbeat)                              │
│     • Device sends signal every 5 minutes                      │
│     • Alert when disconnected > 10 minutes                     │
│                                                                 │
│  📊 PLAYBACK LOG STORAGE                                       │
│     • Record each content playback                             │
│     • Store proof-of-play evidence                             │
│     • Used for billing & dispute resolution                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Technical Requirements

### 8.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    SYSTEM ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🖥️ FRONTEND                                                   │
│     • Flutter Web (modern, cross-platform)                     │
│     • Role-based UI: Admin / Advertiser / Supplier            │
│                                                                 │
│  ⚙️ BACKEND                                                    │
│     • Golang (high performance)                                │
│     • Microservices architecture                               │
│     • Multi-tenancy support (multiple clients)                │
│     • Campaign scheduling & playback logic                     │
│                                                                 │
│  🗄️ DATABASE                                                   │
│     • PostgreSQL: Primary data (user, campaign, store)         │
│     • NoSQL (MongoDB/ClickHouse): Logs & playback history     │
│                                                                 │
│  🏗️ INFRASTRUCTURE                                             │
│     • Kubernetes + Helm (easy scaling)                         │
│     • Kafka (real-time event processing)                       │
│     • CDN (fast video/image distribution)                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 Architecture Diagram

```
                     ┌───────────────┐
                     │     Users     │
                     │   (Browser)   │
                     └───────┬───────┘
                             │
                             ▼
                     ┌───────────────┐
                     │  Flutter Web  │
                     │  (Frontend)   │
                     └───────┬───────┘
                             │
                             ▼
                     ┌───────────────┐
                     │  API Gateway  │
                     │  (Port 8080)  │
                     └───────┬───────┘
                             │
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
    ┌───────────┐    ┌───────────┐    ┌───────────┐
    │  User     │    │  Campaign │    │  Device   │
    │  Service  │    │  Service  │    │  Service  │
    └─────┬─────┘    └─────┬─────┘    └─────┬─────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │      PostgreSQL        │
              │    + NoSQL (Logs)      │
              └────────────────────────┘
```

---

## 📅 Milestone Plan

### Milestone 1: MVP Core Features

> **Goal**: System operational with basic features

| # | Feature | Description |
|---|---------|-------------|
| 1 | Login/Registration | User/Supplier/Admin login |
| 2 | Create campaigns | Advertiser creates and manages campaigns |
| 3 | Register devices | Supplier registers and checks devices |
| 4 | Simulated billing | Impression-based charging (sandbox) |
| 5 | Basic blocking rules | Block competitors by keyword |

### Milestone 2: Advanced Features

| # | Feature | Description |
|---|---------|-------------|
| 1 | Real payment logic | Connect actual payment gateway |
| 2 | Playlist management | CMS with playlist management |
| 3 | Statistics dashboard | Super Admin analytics |
| 4 | Revenue distribution | Auto payout to Suppliers |

### Milestone 3: Commercial SaaS Service

| # | Feature | Description |
|---|---------|-------------|
| 1 | Multi-tenant | Support multiple large clients |
| 2 | Payment Gateway | Integrate actual Stripe/PayPal |
| 3 | SLA & Monitoring | Service quality assurance |

---

## 📊 KPI Metrics

### Performance Indicators

| KPI | Description | Target |
|-----|-------------|--------|
| 📈 **Monthly active campaigns** | Number of running campaigns | +20%/month growth |
| ✅ **Playback success rate** | % of successfully played ads | ≥ 95% |
| 🏪 **Store/device uptime** | % of devices online | ≥ 95% |
| 💵 **Supplier revenue growth** | Supplier income growth rate | 15%/month |

---

## ⚠️ Risk Mitigation Strategy

### Risks and Solutions

| Risk | Solution |
|------|----------|
| 🏷️ **Inconsistent competitor definition** | Standardize brand/category tagging system |
| 📺 **Unstable devices** | Enhanced Heartbeat + Automatic incident alerts |
| 💰 **Potential payment issues** | Sandbox environment + Simulation before going live |
| 🔒 **Data security** | End-to-end encryption + Comprehensive audit logs |
| 📉 **Impression fraud** | Proof-of-Play + AI fraud detection |

---

## 📎 Related Documents

| Document | Description |
|----------|-------------|
| [Glossary](./00-glossary.md) | Explanation of all technical terms |
| [Billing Model](./02-billing-model.md) | Detailed pricing methods |
| [System Architecture](./03-system-architecture.md) | Technical details |
| [Campaign Rules](./04-business-rules-campaign.md) | Business rules for Campaigns |

---

**Version**: 1.0  
**Last Updated**: 2026-01-23  
**Owner**: Product Team

