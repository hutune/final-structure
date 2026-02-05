# Business Rules: Content Management System (CMS)

**Version**: 1.0
**Last Updated**: 2026-01-23
**Owner**: Business Rules Team
**Status**: Draft

---

## Table of Contents

1. [Overview](#overview)
2. [Content Asset Entity](#content-asset-entity)
3. [Content Upload & Validation](#content-upload--validation)
4. [Content Moderation & Approval](#content-moderation--approval)
5. [Content Library & Organization](#content-library--organization)
6. [Content Licensing & Rights Management](#content-licensing--rights-management)
7. [Content Delivery & CDN](#content-delivery--cdn)
8. [Content Assignment to Campaigns](#content-assignment-to-campaigns)
9. [Content Performance Analytics](#content-performance-analytics)
10. [Content Versioning & History](#content-versioning--history)
11. [Content Archival & Deletion](#content-archival--deletion)
12. [Integration Points](#integration-points)
13. [Edge Cases & Special Scenarios](#edge-cases--special-scenarios)
14. [Business Formulas](#business-formulas)

---

## 1. Overview

### 1.1 Purpose

The Content Management System (CMS) manages all advertising creative assets displayed on digital signage devices. It handles:
- Content upload, validation, and storage
- Content moderation and approval workflows
- Content library organization and search
- Content delivery via CDN
- Content performance tracking

### 1.2 Content Lifecycle

```
UPLOADED → PROCESSING → PENDING_APPROVAL → APPROVED → ACTIVE → ARCHIVED
                             ↓
                          REJECTED
```

**State Definitions**:
- **UPLOADED**: File successfully uploaded, awaiting processing
- **PROCESSING**: System is processing file (transcoding, thumbnail generation, validation)
- **PENDING_APPROVAL**: Awaiting moderator review
- **APPROVED**: Passed moderation, ready for use in campaigns
- **REJECTED**: Failed moderation or validation
- **ACTIVE**: Currently being used in active campaigns
- **ARCHIVED**: No longer in use, moved to archive storage

### 1.3 Supported Content Types

| Type | Formats | Max Size | Use Case |
|------|---------|----------|----------|
| **Image** | JPG, PNG, GIF, WebP, SVG | 10 MB | Static display ads, banners |
| **Video** | MP4 (H.264), WebM, MOV | 500 MB | Video ads, motion graphics |
| **Audio** | MP3, AAC, WAV | 50 MB | Audio-only ads (for audio-enabled displays) |
| **Document** | PDF | 20 MB | Menu boards, informational displays |
| **HTML5** | ZIP (HTML/CSS/JS) | 50 MB | Interactive ads, rich media |

---

## 2. Content Asset Entity

### 2.1 Core Attributes

#### Identity & File Information

| Attribute | Description |
|-----------|-------------|
| Asset ID | Unique identifier |
| Advertiser | Owner of the asset |
| Uploader | User who uploaded |
| File Name | Original filename |
| File Type | IMAGE, VIDEO, AUDIO, DOCUMENT, HTML5 |
| File Size | Size in bytes |
| File Hash | SHA-256 for deduplication |

#### Media Properties

| Property | Description |
|----------|-------------|
| Width/Height | Pixel dimensions |
| Aspect Ratio | "16:9", "9:16", "1:1", etc. |
| Duration | For videos/audio (seconds) |
| Frame Rate | FPS for videos |
| Bitrate | Quality metric (kbps) |
| Codec | "H.264", "VP9", etc. |

#### Metadata

| Attribute | Description |
|-----------|-------------|
| Title | Display name |
| Description | Optional description |
| Tags | User-defined search tags |
| Category | "Food", "Fashion", "Electronics", etc. |
| Brand | Brand name if applicable |

#### Lifecycle Status

| Status | Description |
|--------|-------------|
| UPLOADED | File uploaded, awaiting processing |
| PROCESSING | System validating file |
| PENDING_APPROVAL | Awaiting moderation |
| APPROVED | Passed moderation |
| REJECTED | Failed moderation |
| ACTIVE | In use by campaigns |
| ARCHIVED | Soft-deleted |

#### Moderation

| Attribute | Description |
|-----------|-------------|
| Moderation Status | PENDING, APPROVED, REJECTED, FLAGGED |
| Moderation Score | AI confidence score (0-100) |
| Moderation Flags | "adult_content", "violence", etc. |
| Reviewed By | Manual reviewer |
| Notes | Reviewer comments |

#### Licensing & Rights

| Type | Description |
|------|-------------|
| OWNED | Advertiser owns content |
| LICENSED | Licensed from third party |
| STOCK | Stock photo/video |
| USER_GENERATED | UGC with permissions |

### 2.2 Related Entities

#### ContentFolder

| Attribute | Description |
|-----------|-------------|
| Folder Name | e.g., "Summer Campaign 2026" |
| Parent Folder | For nested organization |
| Description | Optional description |
| Asset Count | Number of assets in folder |

#### ContentVersion

| Attribute | Description |
|-----------|-------------|
| Version Number | 1, 2, 3, ... |
| File URL | URL to this version |
| Change Description | e.g., "Updated logo size" |
| Created By | User who created version |

#### ContentTag

| Attribute | Description |
|-----------|-------------|
| Tag Name | "sale", "holiday", "new-product" |
| Usage Count | Number of assets with this tag |

---

## 3. Content Upload & Validation

### 3.1 Upload Process

**Upload Flow**:
1. **Pre-Upload Validation**: Check file size, type, user permissions
2. **Upload to Storage**: Direct upload to S3/GCS with presigned URL
3. **Processing**: Validate file, extract metadata, generate thumbnails
4. **Moderation**: AI moderation + optional manual review
5. **Approval**: Asset marked as APPROVED and ready for use

### 3.2 Pre-Upload Validation

**Rule 3.2.1: File Type Validation**
```
ALLOWED file types by tier:

ALL TIERS:
  - Images: JPG, PNG, GIF, WebP
  - Videos: MP4 (H.264 codec)

PROFESSIONAL & ENTERPRISE:
  - Images: + SVG
  - Videos: + WebM, MOV
  - Audio: MP3, AAC, WAV
  - HTML5: ZIP packages

IF uploaded file type not allowed for tier:
  - REJECT upload
  - SHOW: "Upgrade to {tier} to upload {file_type} files"
```

**Rule 3.2.2: File Size Validation**
```
Maximum file sizes:

- Images: 10 MB
- Videos: 500 MB
- Audio: 50 MB
- Documents: 20 MB
- HTML5: 50 MB (unzipped size limit: 100 MB)

IF file exceeds limit:
  - REJECT upload
  - SUGGEST: "Compress your file to under {limit}"
  - PROVIDE: Link to compression tools
```

**Rule 3.2.3: File Name Validation**
```
File names MUST:
  - Be 1-255 characters
  - Not contain special characters: < > : " / \ | ? *
  - Not be executable file extensions (.exe, .sh, .bat, etc.)

SANITIZATION:
  - Remove special characters
  - Replace spaces with underscores
  - Convert to lowercase (optional, for consistency)

EXAMPLE:
  Original: "My Ad Campaign #1 (Final).jpg"
  Sanitized: "my_ad_campaign_1_final.jpg"
```

**Rule 3.2.4: Quota Enforcement**
```
Tier-based storage quotas:

FREE:         1 GB total storage, 100 assets max
BASIC:        10 GB total storage, 500 assets max
PREMIUM:      50 GB total storage, 2000 assets max
ENTERPRISE:   500 GB+ (custom), unlimited assets

IF advertiser exceeds quota:
  - REJECT upload
  - NOTIFY: "You've reached your storage limit. Upgrade or delete unused assets."
  - SHOW: Current usage stats and upgrade options
```

### 3.3 Upload Processing

**Rule 3.3.1: File Hash & Deduplication**
```
WHEN file is uploaded:
  1. CALCULATE SHA-256 hash of file
  2. CHECK if hash exists in advertiser's library
  3. IF duplicate found:
     - OPTION A (default): Skip upload, reuse existing asset
     - OPTION B: Create new asset referencing same file (saves storage)
     - NOTIFY user: "This file already exists as '{existing_asset_name}'"

BENEFITS:
  - Save storage costs
  - Prevent duplicate uploads
  - Link all campaigns to single source file
```

**Rule 3.3.2: Media Processing**
```
AFTER upload, automatically process:

FOR IMAGES:
  1. Validate image format (ensure not corrupted)
  2. Extract dimensions (width x height)
  3. Calculate aspect ratio
  4. Generate thumbnail (300x300px)
  5. Optimize for web (if needed)

FOR VIDEOS:
  1. Validate video codec (H.264 required for compatibility)
  2. Extract metadata (duration, dimensions, frame rate, bitrate)
  3. Generate thumbnail (first frame or middle frame)
  4. Generate preview GIF (3 seconds, optional)
  5. Transcode to multiple resolutions (480p, 720p, 1080p) for adaptive streaming

FOR AUDIO:
  1. Validate audio format
  2. Extract duration, bitrate, codec
  3. Generate waveform visualization (thumbnail)

FOR HTML5:
  1. Unzip package
  2. Validate structure (index.html present)
  3. Scan for malicious code (XSS, external scripts)
  4. Check file size limits
  5. Generate screenshot of rendered HTML

PROCESSING TIME:
  - Images: < 5 seconds
  - Videos: 1-10 minutes (depending on length)
  - HTML5: < 30 seconds
```

**Rule 3.3.3: Metadata Extraction**
```
Automatically extract metadata from files:

FROM IMAGE EXIF DATA:
  - Camera model, location (GPS), date taken
  - NOTE: Strip sensitive metadata before public use (privacy)

FROM VIDEO METADATA:
  - Creation date, device, location
  - Editing software used

STORE metadata for:
  - Debugging (quality issues)
  - Content verification
  - NOT displayed publicly (privacy)
```

### 3.4 Upload Error Handling

**Rule 3.4.1: Failed Upload Recovery**
```
IF upload fails mid-transfer:
  - RETRY automatically (up to 3 times)
  - Support resumable uploads (chunked upload)
  - Provide clear error message to user

COMMON ERRORS:
  - Network timeout: "Upload interrupted. Click to retry."
  - Invalid file: "File is corrupted or invalid format."
  - Quota exceeded: "Storage quota exceeded. Upgrade or delete assets."
```

**Rule 3.4.2: Processing Failure**
```
IF processing fails:
  - SET status = "PROCESSING_FAILED"
  - NOTIFY user with reason
  - PROVIDE option to re-upload or contact support

COMMON FAILURES:
  - Corrupted file: "File could not be processed. Try re-exporting."
  - Unsupported codec: "Video codec not supported. Use H.264."
  - Timeout: "File too large to process. Compress and retry."
```

---

## 4. Content Moderation & Approval

### 4.1 Moderation Process

**Two-Tier Moderation**:
1. **Automated AI Moderation**: All uploads scanned by AI
2. **Manual Review**: Flagged content or random sampling

### 4.2 AI Moderation

**Rule 4.2.1: Automated Content Scanning**
```
EVERY uploaded asset scanned by AI for:
  - Adult/sexual content
  - Violence/gore
  - Hate symbols/speech
  - Copyrighted content (image similarity search)
  - Inappropriate text (OCR + NLP)
  - Weapons, drugs, alcohol (for restricted categories)

AI RETURNS:
  - moderation_score: 0-100 (100 = safe, 0 = unsafe)
  - moderation_flags: List of detected issues

SCORING THRESHOLDS:
  - Score 90-100: AUTO-APPROVE
  - Score 70-89: FLAG for manual review
  - Score < 70: AUTO-REJECT
```

**Rule 4.2.2: Auto-Approval**
```
IF moderation_score >= 90:
  - SET moderation_status = "APPROVED"
  - SET status = "APPROVED"
  - NOTIFY advertiser: "Your content has been approved"
  - Asset ready for use in campaigns

SKIP manual review (saves time and cost)
```

**Rule 4.2.3: Auto-Rejection**
```
IF moderation_score < 70:
  - SET moderation_status = "REJECTED"
  - SET status = "REJECTED"
  - NOTIFY advertiser with reason:
    - "Content violates policy: {policy_name}"
    - Specific flags: "Adult content detected"
  - PROVIDE: Link to content policies

ASSET CANNOT be used in campaigns
ADVERTISER can appeal or upload corrected version
```

**Rule 4.2.4: Flagged for Manual Review**
```
IF moderation_score 70-89:
  - SET moderation_status = "FLAGGED"
  - SET status = "PENDING_APPROVAL"
  - ADD to manual review queue
  - NOTIFY advertiser: "Your content is under review"

MANUAL REVIEW SLA:
  - Standard: 24 hours
  - Enterprise: 4 hours
```

### 4.3 Manual Review

**Rule 4.3.1: Review Queue**
```
Manual reviewers see queue of flagged content:
  - Ordered by priority (Enterprise customers first)
  - Show asset thumbnail, AI flags, metadata
  - Reviewer options:
    - APPROVE: Content is acceptable
    - REJECT: Content violates policy
    - REQUEST_CHANGES: Needs minor edits

REVIEWER MUST:
  - Provide reason for rejection
  - Cite specific policy violation
```

**Rule 4.3.2: Approval**
```
WHEN reviewer approves:
  - SET moderation_status = "APPROVED"
  - SET status = "APPROVED"
  - SET moderated_by_user_id = reviewer ID
  - ADD moderation_notes (optional)
  - NOTIFY advertiser: "Your content has been approved"
```

**Rule 4.3.3: Rejection**
```
WHEN reviewer rejects:
  - SET moderation_status = "REJECTED"
  - SET status = "REJECTED"
  - SET moderated_by_user_id = reviewer ID
  - REQUIRE rejection_reason (from predefined list + custom)
  - NOTIFY advertiser with detailed reason

ADVERTISER OPTIONS:
  - Appeal decision (request re-review)
  - Upload corrected version
  - Delete asset
```

### 4.4 Content Policies

**Prohibited Content**:
- Adult/sexual content
- Violence, gore, or graphic imagery
- Hate speech, discrimination
- Misleading/deceptive claims
- Illegal products or services
- Weapons, explosives
- Copyright/trademark infringement

**Restricted Content** (requires approval):
- Alcohol advertising (age-gating)
- Gambling (licensed advertisers only)
- Political campaigns (special approval)
- Healthcare/pharmaceutical (regulatory compliance)
- Financial services (disclosure requirements)

**Rule 4.4.1: Category-Specific Rules**
```
ALCOHOL ADS:
  - REQUIRE: Advertiser license to sell alcohol
  - REQUIRE: Age-gating (21+ in US)
  - MUST show: "Drink Responsibly" message
  - NO targeting near schools

GAMBLING ADS:
  - REQUIRE: Gambling license
  - REQUIRE: Age-gating (21+ or 18+ depending on jurisdiction)
  - MUST show: Responsible gaming hotline

PHARMACEUTICAL ADS:
  - REQUIRE: FDA approval documentation
  - MUST show: Full disclosure of side effects
  - CANNOT make unapproved health claims
```

### 4.5 Appeal Process

**Rule 4.5.1: Content Rejection Appeal**
```
WHEN advertiser appeals rejection:
  1. CREATE appeal request
  2. REQUIRE: Explanation of why content should be approved
  3. OPTIONAL: Upload revised version
  4. ESCALATE to senior reviewer

APPEAL REVIEW SLA:
  - Standard: 48 hours
  - Enterprise: 8 hours

OUTCOMES:
  - Approve: Original decision overturned
  - Reject: Original decision upheld (final)
  - Request Changes: Specific edits required

LIMIT: 1 appeal per asset
```

---

## 5. Content Library & Organization

### 5.1 Library Structure

**Folder Hierarchy**:
```
Advertiser Content Library
├── Summer 2026 Campaign
│   ├── Images
│   ├── Videos
│   └── Archived
├── Holiday Campaign
└── Evergreen Content
    ├── Logos
    └── Product Images
```

**Rule 5.1.1: Folder Creation**
```
Advertisers can create folders to organize assets:
  - Unlimited folders (all tiers)
  - Nested folders (up to 5 levels deep)
  - Folder names: 1-100 characters

DEFAULT FOLDERS (auto-created):
  - "Uncategorized" (default upload location)
  - "Favorites"
  - "Recently Uploaded"
```

**Rule 5.1.2: Moving Assets**
```
Assets can be moved between folders:
  - Drag-and-drop in UI
  - Bulk move (select multiple assets)
  - Move does NOT affect campaigns using the asset

NO IMPACT on asset URL (URL remains same)
```

### 5.2 Search & Filtering

**Rule 5.2.1: Search Functionality**
```
SEARCH across:
  - Asset title
  - Description
  - Tags
  - File name
  - Metadata (brand, category)

SEARCH FEATURES:
  - Full-text search
  - Autocomplete suggestions
  - Search within folder
  - Save search queries (for reuse)

EXAMPLE QUERIES:
  - "summer sale" → Matches title, description, tags
  - "type:video tag:fashion" → Advanced filtering
```

**Rule 5.2.2: Filtering**
```
FILTER by:
  - Content type (image, video, etc.)
  - Status (approved, pending, rejected)
  - Date uploaded (last 7 days, last 30 days, custom range)
  - File size (< 1MB, 1-10MB, > 10MB)
  - Dimensions (portrait, landscape, square)
  - Duration (videos/audio)
  - Tags
  - Usage (used in campaigns vs unused)

COMBINE multiple filters with AND logic
```

**Rule 5.2.3: Sorting**
```
SORT by:
  - Upload date (newest/oldest)
  - File name (A-Z, Z-A)
  - File size (largest/smallest)
  - Usage count (most/least used)
  - Total impressions (most/least)

DEFAULT: Sort by upload date (newest first)
```

### 5.3 Bulk Operations

**Rule 5.3.1: Bulk Actions**
```
SELECT multiple assets and perform actions:
  - Move to folder
  - Add tags
  - Delete
  - Archive
  - Download (as ZIP)
  - Update metadata

LIMIT: 100 assets per bulk operation
```

**Rule 5.3.2: Bulk Upload**
```
Upload multiple files at once:
  - Drag-and-drop multiple files
  - Upload folder (preserves structure)
  - Queue processing (process in background)

LIMIT: 50 files per upload session
PROGRESS: Show upload progress for each file
```

### 5.4 Favorites & Collections

**Rule 5.4.1: Favorites**
```
Users can mark assets as favorites:
  - Quick access to frequently used assets
  - "Favorites" smart folder (auto-populated)
  - Favorite state is per-user (not shared across team)
```

**Rule 5.4.2: Smart Collections** (ENTERPRISE only)
```
Auto-updating collections based on rules:
  - "High-performing ads" (CTR > 2%)
  - "Unused assets" (not used in any campaign)
  - "Expiring licenses" (license expires < 30 days)

REFRESH: Collections update daily
```

---

## 6. Content Licensing & Rights Management

### 6.1 Rights Confirmation

**Rule 6.1.1: Usage Rights Declaration**
```
WHEN uploading content, advertiser MUST confirm:
  - "I own this content OR have permission to use it"
  - License type: OWNED | LICENSED | STOCK | USER_GENERATED

LEGAL DISCLAIMER displayed during upload:
  - "You are responsible for ensuring you have rights to use this content"
  - "Violation of copyright may result in account suspension"
```

**Rule 6.1.2: License Type Selection**
```
OWNED:
  - Advertiser created content in-house
  - No expiration

LICENSED:
  - Content licensed from third party
  - REQUIRE: License expiry date
  - ALERT when license expires

STOCK:
  - Stock photo/video from provider (Shutterstock, Getty, etc.)
  - REQUIRE: License details
  - Platform does NOT verify stock license validity

USER_GENERATED:
  - Content from customers/users
  - REQUIRE: Proof of permission (signed release form)
```

### 6.2 License Expiration

**Rule 6.2.1: Expiration Tracking**
```
FOR licensed content with expiry date:
  - ALERT advertiser 30 days before expiration:
    "License for '{asset_name}' expires on {date}"
  - ALERT again 7 days before expiration
  - ON expiration date:
    - SET status = "EXPIRED"
    - PAUSE campaigns using this asset
    - NOTIFY advertiser: "Renew license or replace content"

CAMPAIGNS AFFECTED:
  - Show warning: "This campaign uses expired content"
  - Prevent launching new campaigns with expired content
```

**Rule 6.2.2: License Renewal**
```
Advertiser can update license expiry date:
  - Edit asset details
  - Update expiry date
  - REQUIRE: Re-confirmation of rights

RESUME campaigns automatically after renewal
```

### 6.3 Copyright Claims

**Rule 6.3.1: DMCA Takedown Process**
```
IF platform receives DMCA takedown notice:
  1. SUSPEND asset immediately (set status = "SUSPENDED")
  2. PAUSE all campaigns using asset
  3. NOTIFY advertiser:
     - "Your content has been flagged for copyright violation"
     - Provide claimant details (per DMCA)
     - Options: Submit counter-notice OR delete content
  4. INVESTIGATE claim

OUTCOMES:
  - Valid claim: Permanently delete asset, warn advertiser
  - Invalid claim: Restore asset, resume campaigns
  - Repeat violations: Suspend advertiser account
```

---

## 7. Content Delivery & CDN

### 7.1 Storage Architecture

**Three-Tier Storage**:
1. **Origin Storage**: S3/GCS (master files)
2. **CDN Edge Cache**: CloudFront/Cloudflare (fast delivery)
3. **Device Cache**: Local storage on devices (offline capability)

### 7.2 CDN Configuration

**Rule 7.2.1: CDN Upload Flow**
```
WHEN asset is uploaded and approved:
  1. STORE original file in origin storage (S3/GCS)
  2. GENERATE CDN URL (CloudFront distribution)
  3. CACHE at edge locations worldwide
  4. RETURN cdn_url to advertiser

CDN BENEFITS:
  - Fast delivery (low latency)
  - High availability (99.9% uptime)
  - Reduced origin load
```

**Rule 7.2.2: Cache Invalidation**
```
IF asset is updated (new version):
  - INVALIDATE CDN cache
  - PROPAGATE new version to edge locations
  - TAKES: 5-15 minutes globally

DURING propagation:
  - Some devices may serve old version (brief inconsistency)
  - NOT an issue for campaigns (use versioned URLs)
```

**Rule 7.2.3: Adaptive Bitrate Streaming** (for videos)
```
VIDEOS transcoded to multiple resolutions:
  - 480p (1 Mbps)
  - 720p (2.5 Mbps)
  - 1080p (5 Mbps)

DEVICE selects resolution based on:
  - Screen resolution
  - Network bandwidth
  - Current CPU load

STREAMING PROTOCOL:
  - HLS (HTTP Live Streaming) for compatibility
```

### 7.3 Device Content Sync

**Rule 7.3.1: Content Download**
```
WHEN campaign assigned to device:
  1. DEVICE receives content manifest (list of assets)
  2. CHECK local cache for assets
  3. DOWNLOAD missing assets from CDN
  4. VERIFY file integrity (hash check)
  5. MARK content as ready

DOWNLOAD OPTIMIZATION:
  - Download during low-traffic hours (if scheduled)
  - Resume interrupted downloads
  - Prioritize upcoming scheduled content
```

**Rule 7.3.2: Local Caching**
```
DEVICES cache content locally:
  - Store on device storage (SSD/HDD)
  - Max cache size: 10 GB (configurable)
  - LRU (Least Recently Used) eviction policy

BENEFITS:
  - Play content without network dependency
  - Reduce bandwidth usage
  - Instant content switching
```

**Rule 7.3.3: Content Update Push**
```
WHEN content is updated in campaign:
  - PUSH notification to affected devices
  - DEVICES download updated content in background
  - SWITCH to new content at next scheduled playback

NO INTERRUPTION to current playback
```

---

## 8. Content Assignment to Campaigns

### 8.1 Campaign Content Selection

**Rule 8.1.1: Adding Content to Campaign**
```
WHEN creating campaign, advertiser selects content:
  - Single asset (static campaign)
  - Multiple assets (playlist/rotation)
  - Dynamic rules (content based on time, location, etc.)

VALIDATION:
  - Content MUST be APPROVED status
  - Content license MUST be valid (not expired)
  - Content dimensions MUST match device aspect ratios (or allow cropping)
```

**Rule 8.1.2: Content Rotation**
```
IF multiple assets in campaign:
  - ROTATE assets based on schedule:
    - Equal distribution (default)
    - Weighted distribution (e.g., 70% asset A, 30% asset B)
    - Time-based (asset A mornings, asset B afternoons)

ROTATION TRACKING:
  - Each impression records which asset was displayed
  - Performance compared across assets
```

### 8.2 Content Compatibility

**Rule 8.2.1: Aspect Ratio Matching**
```
DEVICES have specific screen aspect ratios:
  - 16:9 (landscape)
  - 9:16 (portrait)
  - 1:1 (square)

WHEN assigning content to campaign:
  - CHECK if content aspect ratio matches target devices
  - IF mismatch:
    - OPTION A: Crop/fit content (letterbox/pillarbox)
    - OPTION B: Warn advertiser and require different asset

RECOMMENDATION: Upload multiple versions for different aspect ratios
```

**Rule 8.2.2: Resolution Validation**
```
RECOMMEND content resolution >= device resolution:
  - 1920x1080 content for 1080p displays
  - 3840x2160 content for 4K displays

IF lower resolution:
  - WARN advertiser: "Content may appear pixelated on high-res displays"
  - ALLOW usage (advertiser choice)
```

**Rule 8.2.3: File Size Optimization**
```
LARGE files may cause issues:
  - Slow download to devices
  - Storage limitations

RECOMMENDATIONS:
  - Images: Optimize to < 2 MB per image
  - Videos: Use efficient codec (H.264), bitrate < 5 Mbps
  - HTML5: Minify code, compress assets

PLATFORM can auto-optimize (with advertiser permission)
```

### 8.3 Content Scheduling

**Rule 8.3.1: Time-Based Content**
```
Advertiser can schedule different content for different times:
  - Breakfast menu (6am-11am)
  - Lunch menu (11am-2pm)
  - Dinner menu (5pm-10pm)

DEVICE automatically switches content based on schedule
```

**Rule 8.3.2: Dynamic Content**
```
ENTERPRISE tier supports dynamic content:
  - Weather-based (show umbrella ad when raining)
  - Inventory-based (show ad only if product in stock)
  - Real-time data (display current prices, countdowns)

REQUIRES: API integration with external data sources
```

---

## 9. Content Performance Analytics

### 9.1 Asset-Level Analytics

**Tracked Metrics**:
- **Impressions**: Total times asset displayed
- **Unique Devices**: # of unique devices showing asset
- **Campaigns**: # of campaigns using asset
- **CTR**: Click-through rate (if interactive)
- **Engagement**: View duration, interaction events
- **Conversions**: Attributed sales/actions (if tracked)

**Rule 9.1.1: Performance Dashboard**
```
FOR each asset, show:
  - Total impressions (lifetime)
  - Impressions trend (last 30 days)
  - Top-performing campaigns using asset
  - Device types showing asset (screen sizes, locations)
  - Comparison to advertiser's average
```

**Rule 9.1.2: Performance Scoring**
```
CALCULATE asset performance score (0-100):
  - Impression volume: 30%
  - CTR (if applicable): 30%
  - Campaign usage: 20%
  - Recency (recently used): 20%

HIGH-PERFORMING assets (score > 80):
  - Badge: "Top Performer"
  - Suggested for new campaigns
```

### 9.2 A/B Testing

**Rule 9.2.1: Content Variants**
```
ADVERTISERS can test multiple versions:
  - Create 2+ variants of same asset (different CTA, colors, etc.)
  - Split traffic 50/50 (or custom split)
  - Track performance for each variant

AFTER 1000 impressions (minimum):
  - SHOW statistical significance of results
  - RECOMMEND best-performing variant
```

**Rule 9.2.2: Automated Optimization** (ENTERPRISE)
```
PLATFORM can auto-optimize:
  - Start with equal distribution across variants
  - Gradually shift traffic to best performer (multi-armed bandit)
  - Maximize overall campaign performance

EXAMPLE:
  - Variant A: 1.5% CTR
  - Variant B: 2.8% CTR
  - After 500 impressions each, shift to 80% Variant B, 20% Variant A
```

### 9.3 Heatmaps & Engagement

**Rule 9.3.1: Interactive Content Tracking** (for HTML5 ads)
```
TRACK user interactions:
  - Clicks on buttons/links
  - Scroll depth
  - Time spent on each section
  - Form submissions

GENERATE heatmap showing:
  - Most clicked areas
  - Attention zones (where users look)

USE for optimization: Adjust layout, CTA placement
```

### 9.4 Content Recommendations

**Rule 9.4.1: Asset Suggestions**
```
BASED on performance data, RECOMMEND:
  - "Your top 5 performing assets" (for reuse)
  - "Unused assets" (uploaded but not used in campaigns)
  - "Similar high-performing assets" (from other advertisers, if public)

HELP advertisers optimize content strategy
```

---

## 10. Content Versioning & History

### 10.1 Version Control

**Rule 10.1.1: Version Creation**
```
WHEN advertiser updates an asset:
  - CREATE new version (version_number increments)
  - STORE old version in history
  - UPDATE cdn_url to new version

CAMPAIGNS using asset:
  - OPTION A: Auto-update to new version (default)
  - OPTION B: Pin to specific version (manual update required)
```

**Rule 10.1.2: Version Rollback**
```
Advertiser can revert to previous version:
  - VIEW all versions (with previews)
  - SELECT version to restore
  - ROLLBACK: Set selected version as current

USE CASE: New version has error, quickly revert to stable version
```

**Rule 10.1.3: Version Limit**
```
STORE up to 10 versions per asset (all tiers)
ENTERPRISE: Unlimited versions

OLDEST versions auto-deleted if limit exceeded
EXCEPTION: Versions currently used in active campaigns are retained
```

### 10.2 Change History

**Rule 10.2.1: Audit Log**
```
TRACK all changes to asset:
  - Upload
  - Metadata edits (title, tags, etc.)
  - Version updates
  - Status changes (approved, rejected)
  - Assignment to campaigns
  - Deletion

FOR EACH change:
  - Timestamp
  - User who made change
  - Description of change

ACCESS: Viewable by advertiser account team
```

---

## 11. Content Archival & Deletion

### 11.1 Archiving

**Rule 11.1.1: Manual Archive**
```
Advertiser can ARCHIVE assets:
  - Move to "Archived" folder
  - No longer shown in main library
  - Cannot be used in NEW campaigns
  - EXISTING campaigns using asset continue (no interruption)

USE CASE: Seasonal content, outdated designs (keep for reference)
```

**Rule 11.1.2: Auto-Archive**
```
PLATFORM can auto-archive:
  - Assets not used in 365 days
  - Notification sent 30 days before archival
  - Advertiser can opt out of auto-archive

BENEFIT: Keep library clean, reduce clutter
```

**Rule 11.1.3: Restore from Archive**
```
Advertiser can restore archived assets:
  - Move back to active library
  - Available for use in campaigns immediately
```

### 11.2 Deletion

**Rule 11.2.1: Soft Delete**
```
WHEN advertiser deletes asset:
  - SET deleted_at = NOW()
  - Hide from library
  - Retain in database for 30 days (recovery period)

IF asset used in active campaigns:
  - WARN: "This asset is used in X active campaigns"
  - REQUIRE confirmation
  - CAMPAIGNS continue using asset (URL still accessible)
```

**Rule 11.2.2: Permanent Deletion**
```
AFTER 30 days (soft delete grace period):
  - PERMANENTLY delete file from storage
  - Remove from database
  - CANNOT be recovered

EXCEPTION: Assets with active campaigns retained until campaign ends
```

**Rule 11.2.3: Bulk Deletion**
```
Advertiser can delete multiple assets:
  - Select assets
  - Confirm deletion
  - PROCESS in background (if large batch)

SAFETY: Require double confirmation for >10 assets
```

---

## 12. Integration Points

### 12.1 Integration with Campaign Module

```
DEPENDENCIES:
  - Campaigns reference content_assets via asset_id
  - Campaign status affects content usage (active campaigns use content)
  - Content performance tracked per campaign

INTERACTIONS:
  - Campaign creation: Select content from library
  - Campaign reports: Show content performance within campaign
  - Content updates: Notify affected campaigns
```

### 12.2 Integration with Device Module

```
INTERACTIONS:
  - Devices download content for assigned campaigns
  - Device capabilities (screen size, resolution) affect content selection
  - Device cache stores content locally
  - Device reports which content is playing
```

### 12.3 Integration with Advertiser Module

```
DEPENDENCIES:
  - Content owned by advertiser (advertiser_id FK)
  - Advertiser tier affects storage quota and features
  - Advertiser team members have different permissions (upload, approve, delete)

QUOTAS enforced at advertiser level
```

### 12.4 External Integrations

#### CDN Providers
```
INTEGRATIONS:
  - AWS CloudFront: Content delivery
  - Cloudflare: CDN + DDoS protection
  - Google Cloud CDN: Alternative CDN

WEBHOOKS:
  - cdn.cache_invalidated → Notify system
  - cdn.file_deleted → Clean up references
```

#### Moderation Services
```
INTEGRATIONS:
  - AWS Rekognition: Image/video moderation
  - Google Vision AI: Content detection
  - Clarifai: Custom moderation models

API CALLS:
  - Upload → Send to moderation API
  - Receive confidence scores
  - Store results in moderation_flags
```

#### Storage Providers
```
INTEGRATIONS:
  - AWS S3: Primary storage
  - Google Cloud Storage: Alternative
  - Azure Blob Storage: Multi-cloud option

OPERATIONS:
  - Upload: Presigned URLs (direct upload)
  - Download: Presigned URLs (secure access)
  - Lifecycle policies: Auto-archive old files
```

---

## 13. Edge Cases & Special Scenarios

### 13.1 Duplicate Content Handling

**Scenario**: Advertiser uploads same file multiple times.

**Rules**:
```
DETECTION:
  - Calculate file hash (SHA-256)
  - Check if hash exists in advertiser's library

OPTIONS:
  A) SKIP UPLOAD (default):
     - Show existing asset
     - "This file already exists as '{name}'"

  B) CREATE NEW ASSET:
     - Allow duplicate with different metadata
     - Useful if same image used for different purposes

  C) UPDATE EXISTING:
     - Replace existing asset with new upload
     - Create new version
```

### 13.2 Very Large Files

**Scenario**: Advertiser uploads 500 MB video (at tier limit).

**Rules**:
```
OPTIMIZATION:
  - Offer compression during upload
  - "Your file is 500 MB. Compress to 250 MB? (recommended)"
  - Use efficient codec (H.264, smaller size)

UPLOAD:
  - Use resumable/chunked upload
  - Show detailed progress (MB uploaded / total)
  - Allow pause/resume

PROCESSING:
  - Process in background (takes 10+ minutes)
  - Notify advertiser when complete
```

### 13.3 Broken/Corrupted Files

**Scenario**: Uploaded file is corrupted and cannot be processed.

**Rules**:
```
DETECTION:
  - Processing fails (cannot read file)
  - SET status = "PROCESSING_FAILED"

NOTIFICATION:
  - "Your file could not be processed. It may be corrupted."
  - SUGGEST: Re-export from source application and re-upload

RECOVERY:
  - Allow retry (reprocess same file)
  - Allow replacement (upload new file)

IF persistent failures:
  - Flag for manual support review
```

### 13.4 License Disputes

**Scenario**: Two advertisers claim ownership of same content.

**Rules**:
```
IF DMCA claim filed OR both advertisers use same content:
  1. INVESTIGATE:
     - Request proof of ownership from both parties
     - Check upload timestamps (who uploaded first)
     - Review license documentation

  2. RESOLUTION:
     - Valid owner: Retain asset
     - Invalid owner: Remove asset, warn account

  3. LEGAL ESCALATION:
     - If unresolved, may require legal involvement
     - Suspend asset until resolved
```

### 13.5 Content Used Across Multiple Campaigns

**Scenario**: Asset used in 50+ campaigns, advertiser wants to update it.

**Rules**:
```
UPDATE OPTIONS:
  A) UPDATE ALL CAMPAIGNS:
     - New version used everywhere
     - Immediate effect

  B) PIN EXISTING CAMPAIGNS:
     - Existing campaigns use old version
     - New campaigns use new version

  C) SELECTIVE UPDATE:
     - Choose which campaigns to update
     - Manual control

NOTIFICATION:
  - "This asset is used in 50 campaigns. Update all?"
  - Show list of affected campaigns
```

### 13.6 Seasonal Content Automation

**Scenario**: Advertiser has holiday content that should only show during December.

**Rules**:
```
SCHEDULING:
  - Set active_date_range for asset
  - Auto-activate asset on start date
  - Auto-archive asset on end date

CAMPAIGNS:
  - Campaigns using seasonal assets auto-pause outside date range
  - Auto-resume when back in range

BENEFIT: "Set and forget" seasonal campaigns
```

### 13.7 User-Generated Content (UGC)

**Scenario**: Advertiser runs UGC campaign, uploads customer-submitted content.

**Rules**:
```
EXTRA MODERATION:
  - REQUIRE: Proof of permission (signed release forms)
  - STRICTER moderation (manual review mandatory)
  - LABEL: "User-Generated Content" (for transparency)

LEGAL PROTECTION:
  - Advertiser responsible for permissions
  - Platform not liable for UGC disputes (per ToS)

RECOMMENDATION:
  - Upload release forms as separate documents
  - Link to assets for audit trail
```

---

## 14. Business Formulas

### 14.1 Storage Cost Calculation

```
storage_cost_per_gb_per_month = $0.023 (S3 standard tier)

total_storage_gb = SUM(file_size_bytes for all assets) / (1024^3)

monthly_storage_cost = total_storage_gb × storage_cost_per_gb_per_month

EXAMPLE:
  Advertiser uses 50 GB storage
  Cost = 50 × $0.023 = $1.15/month

NOTE: Advertisers don't pay storage fees directly (included in tier subscription)
```

### 14.2 CDN Bandwidth Cost

```
cdn_cost_per_gb = $0.085 (CloudFront average)

total_bandwidth_gb = SUM(file_size_bytes × impressions) / (1024^3)

monthly_cdn_cost = total_bandwidth_gb × cdn_cost_per_gb

EXAMPLE:
  - Asset: 2 MB video
  - Impressions: 100,000
  - Bandwidth = (2 MB × 100,000) / 1024 = 195 GB
  - Cost = 195 × $0.085 = $16.58

NOTE: Platform absorbs CDN costs (not billed to advertiser)
```

### 14.3 Content Performance Score

```
performance_score = (
  impression_volume_score × 0.30 +
  ctr_score × 0.30 +
  campaign_usage_score × 0.20 +
  recency_score × 0.20
)

WHERE:
  impression_volume_score = MIN(100, (total_impressions / 10000) × 100)
  ctr_score = ctr_percentage × 20  // Assumes 5% CTR = 100 score
  campaign_usage_score = MIN(100, used_in_campaigns_count × 10)
  recency_score = 100 if last_used < 30_days_ago ELSE (100 - days_since_last_use)

EXAMPLE:
  - Impressions: 50,000 → volume_score = 100 (capped)
  - CTR: 3% → ctr_score = 60
  - Used in 8 campaigns → usage_score = 80
  - Last used 10 days ago → recency_score = 90

  performance_score = (100 × 0.30) + (60 × 0.30) + (80 × 0.20) + (90 × 0.20)
                    = 30 + 18 + 16 + 18
                    = 82 (Good performer)
```

### 14.4 Storage Quota Usage

```
current_usage_percentage = (
  (total_storage_bytes / storage_quota_bytes) × 100
)

IF current_usage_percentage >= 80:
  ALERT: "You're using 80% of your storage quota"
  SUGGEST: Upgrade or delete unused assets

IF current_usage_percentage >= 100:
  BLOCK new uploads until space freed
```

### 14.5 Processing Time Estimate

```
IMAGES:
  processing_time_seconds = 5 (constant)

VIDEOS:
  processing_time_seconds = duration_seconds × 0.5  // Real-time encoding

  EXAMPLE:
    60-second video → 30 seconds processing

HTML5:
  processing_time_seconds = 10 + (total_files × 2)

  EXAMPLE:
    Package with 20 files → 10 + (20 × 2) = 50 seconds
```

### 14.6 Recommended Asset Dimensions

```
FOR device with resolution (device_width × device_height):

  recommended_content_width = device_width × 1.5
  recommended_content_height = device_height × 1.5

EXAMPLE:
  Device: 1920×1080
  Recommended: 2880×1620 (allows for scaling without quality loss)

IF content_width < device_width:
  quality_warning = "Content may appear pixelated"
```

---

## Appendix A: Related Business Rules Documents

This document should be read in conjunction with:
- [Business Rules: Campaign Management](business-rules-campaign.md)
- [Business Rules: Device Management](business-rules-device.md)
- [Business Rules: Advertiser Management](business-rules-advertiser.md)
- [Business Rules: Supplier Management](business-rules-supplier.md)

---

## Appendix B: Content Policy Examples

### Acceptable Content
- Product photos and videos
- Brand logos and graphics
- Promotional messaging
- Educational content
- Entertainment content (appropriate)

### Prohibited Content
- Nudity or sexual content
- Violence or gore
- Hate symbols or speech
- Illegal products (drugs, weapons)
- Misleading health claims
- Malicious code (malware, scripts)

### Restricted Content (Requires Special Approval)
- Alcohol advertising (with disclaimers)
- Gambling (licensed only)
- Political ads (transparency requirements)
- Financial services (disclosure requirements)
- Healthcare/pharma (regulatory compliance)

---

## Appendix C: Supported File Formats

### Images
- JPEG/JPG (recommended for photos)
- PNG (recommended for graphics with transparency)
- GIF (animated supported)
- WebP (modern format, smaller file size)
- SVG (Professional/Enterprise only, vector graphics)

### Videos
- MP4 (H.264 codec) - **Recommended**
- WebM (VP9 codec) - Professional/Enterprise
- MOV (H.264) - Professional/Enterprise

### Audio
- MP3 (widely compatible)
- AAC (higher quality)
- WAV (uncompressed, large files)

### Documents
- PDF (for menu boards, informational displays)

### Rich Media
- HTML5 (ZIP package with HTML/CSS/JS)

---

## Appendix D: Glossary

| Term | Definition |
|------|------------|
| Asset | A single piece of content (image, video, etc.) in the library |
| CDN | Content Delivery Network - distributed system for fast content delivery |
| Moderation | Process of reviewing content for policy compliance |
| Aspect Ratio | Proportional relationship between width and height (e.g., 16:9) |
| Transcoding | Converting video from one format/resolution to another |
| Cache | Temporary storage of content for faster access |
| License | Legal permission to use content |
| DMCA | Digital Millennium Copyright Act - US copyright law |
| UGC | User-Generated Content - content created by customers/users |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-23 | Business Rules Team | Initial draft - comprehensive content management rules |

---

**END OF DOCUMENT**
