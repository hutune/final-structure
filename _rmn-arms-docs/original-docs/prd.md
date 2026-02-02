

Product Requirements Document (PRD)

RMN Project
Product Requirements Document (PRD)

Overview
This project is a SaaS-based advertising management platform based on Retail Media Network (RMN), aiming to provide integrated management of advertisers (users) and suppliers (store/media operators) in a single web-based dashboard. The initial milestone includes campaign setup → billing based on in-store signage impressions → content and display management → safe competitor filtering functionality.

1. Goals and Key Values

1.1 Service Goals
Provide a SaaS platform where advertisers can easily create signage advertising campaigns and operate them by charging budgets.
Support suppliers in registering and managing display devices in their stores and controlling advertising slots.
Admin dashboard comprehensively manages all accounts, media, campaigns, and billing flows.

1.2 Core Value Proposition
Integrated management of advertisers and suppliers on a single web platform.
Automated billing: Real-time/daily settlement based on impression ratio or number of impressions played.
Provide sophisticated targeting and competitor blocking features.
CMS/CRM functionality centralizes content upload, approval, and distribution.

2. Target Users

2.1 Advertiser (User)
Campaign creation, budget charging, media selection, content management.
Device registration if they have their own store screens.

2.2 Supplier (Store Operator)
Register display devices in stores, set operating hours, sell advertising slots.
Block specific competitor advertisements.

2.3 Super Admin
Overall platform operation, account management, payment management, policy settings.

3. Functional Requirements

3.1 Authentication and Account Management
Email-based registration and login.
Single account structure for users/suppliers with role-based permissions.
Separate Super Admin account.

3.2 Dashboard (Advertiser)
Campaign creation and management.
Budget charging (prepaid method).
Monitor campaign status (impressions, remaining budget, CTR, etc.).
Upload advertising materials (CMS integration).
Register their own store screens (display device ID, location, operating hours, etc.).

3.3 Dashboard (Supplier)
Register stores and display devices.
Monitor device status (online/offline, playback errors, etc.).
Set advertising slot operation settings (time slots, play rate).
Set competitor ad blocking rules.

3.4 Dashboard (Super Admin)
Manage entire list of users/stores/devices.
Set billing policies.
Campaign monitoring, platform-level statistics.
Content approval/sanctions.

4. Campaign and Billing Structure

4.1 Campaign Creation Flow
Advertiser clicks campaign creation button.
Upload or select content.
Select target stores/regions.
Set period and budget.
Review and submit.

4.2 Impression-Based Billing
Unit price based on signboard playback frequency, playback time, and expected impressions.
Real-time or daily settlement options.
Automatic suspension when budget is exhausted.
Automatic revenue distribution to suppliers.

5. CRM/CMS Functional Requirements
Content upload: Images, videos, etc.
Digital signboard playback rule settings.
Content approval/rejection workflow.
Playlist management.
Content distribution by store/device.

6. Competitor Blocking Feature

6.1 Rule Definition
Suppliers define "blocking keywords" based on store type, category, or brand.
Automatic matching with ad material metadata or campaign category.

6.2 Operation Method
Conflict detection at campaign distribution stage.
When conflicts occur, exclude ad distribution to that store.
Recommend alternative media to advertisers.

7. Device (Signage) Management
Registration based on device ID or QR code.
Operating hours settings.
Device status monitoring API (Heartbeat).
Playback log storage.

8. Technical Requirements

8.1 Frontend
Flutter-based modern web.
Role-based UI for Admin, User, and Supplier.

8.2 Backend
Golang-based API server.
Consider multi-tenancy structure.
Orchestration of campaign scheduling and playback logic.

8.3 Database
Campaigns/Users/Stores: PostgreSQL.
Logs and playback records: NoSQL.

8.4 Infrastructure
Kubernetes (Helm) based deployment.
Event-based processing (Kafka, etc.).
CDN-based video/image distribution.

9. Initial Milestone Plan

M1: Core Feature MVP
User/Supplier/Admin login.
Advertiser campaign creation.
Device registration and playback testing.
Impression-based billing simulation.
Basic competitor blocking rules.

M2: Enhancement
Actual settlement logic.
CMS playlist management.
Super Admin statistics dashboard.
Supplier revenue distribution.

M3: SaaS Commercial Service
Tenant-based onboarding.
Payment gateway integration.
SLA and monitoring.

10. KPIs
Monthly active campaigns.
Ad playback success rate.
Store/device activity.
Supplier revenue growth rate.

11. Risk Mitigation Strategy (Opinion)
Lack of consistency in competitor definition by market → Standardize brand/category tagging.
Unstable device status → Strengthen Heartbeat and failure alerts.
Potential billing issues → Simulation and Sandbox billing.

