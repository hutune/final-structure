---
id: "STORY-6.1"
epic_id: "EPIC-006"
title: "Content Upload & Storage"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "cms", "upload", "s3"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdm9g"
---

# Content Upload & Storage

## User Story

**As an** Advertiser,
**I want** to easily upload my advertising content (images and videos),
**So that** I can use them in my campaigns.

## Business Context

Content is the heart of any ad campaign. A smooth upload experience:
- Reduces time-to-launch for campaigns
- Ensures content meets technical requirements for devices
- Automatically processes content for optimal playback
- Enables content reuse across multiple campaigns

## Business Rules

> Reference: [10-business-rules-content.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/10-business-rules-content.md)

### Supported Formats
| Type | Formats | Max Size | Resolution |
|------|---------|----------|------------|
| Image | JPG, PNG, GIF, WebP | 10 MB | Min 1920x1080 |
| Video | MP4 (H.264) | 500 MB | Min 1920x1080 |
| Audio | MP3, AAC | 50 MB | - |

### File Validation
- Valid file format (not corrupted)
- File size within limits
- Resolution meets minimum
- File name sanitized (no special chars)

### Deduplication
- SHA-256 hash calculated on upload
- Duplicate detected → reuse existing file
- Storage optimized, saves cost

### Content Processing
| Type | Processing Steps |
|------|-----------------|
| Image | Validate, extract dimensions, generate thumbnail |
| Video | Validate codec, extract metadata, generate thumbnail, transcode |
| Audio | Validate format, extract duration, generate waveform |

## Acceptance Criteria

### For Advertisers
- [ ] Drag-and-drop upload in web interface
- [ ] Progress indicator during upload
- [ ] Clear error messages if upload fails
- [ ] Preview thumbnail after upload
- [ ] Auto-generated filename (editable)

### For File Processing
- [ ] Validate file format and size on upload
- [ ] Extract metadata (duration, resolution)
- [ ] Generate thumbnail for preview
- [ ] Store in S3 with unique key
- [ ] Generate CDN URL for fast delivery

### For Content Management
- [ ] View all uploaded content in library
- [ ] Search and filter by type, date, status
- [ ] Delete unused content

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**Upload Flow:**
1. Pre-signed URL from server
2. Direct upload to S3
3. Server-side processing (async)
4. Webhook on complete

**API Endpoints:**
```
POST /api/v1/content/presign      # Get presigned URL
POST /api/v1/content/complete     # Mark upload complete
GET  /api/v1/content              # List content
GET  /api/v1/content/{id}         # Get content details
DELETE /api/v1/content/{id}       # Delete content
```

</details>

## Checklist (Subtasks)

- [ ] Implement presigned URL generation
- [ ] Implement upload completion webhook
- [ ] Validate file format and size
- [ ] Extract metadata (resolution, duration)
- [ ] Generate thumbnails (images + video frames)
- [ ] Implement deduplication (SHA-256)
- [ ] Generate CDN URLs
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:20** - Rewrote with file validation, deduplication, and processing steps from CMS business rules.
