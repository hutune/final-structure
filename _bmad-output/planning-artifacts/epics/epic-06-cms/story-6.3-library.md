---
id: "STORY-6.3"
epic_id: "EPIC-006"
title: "Content Library Management"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "cms", "library"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: "86ewgdm97"
---

# Content Library Management

## User Story

**As an** Advertiser,
**I want** to organize and find my content easily,
**So that** I can reuse approved content in multiple campaigns.

## Business Context

A well-organized content library saves time and maximizes ROI on creative assets:
- Easily find past content for reuse
- Track which content performs best
- Identify unused content for cleanup
- Organize by campaign, season, or type

## Business Rules

> Reference: [10-business-rules-content.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/10-business-rules-content.md)

### Library Organization
- **Folders:** Unlimited, up to 5 levels deep
- **Tags:** User-defined, autocomplete suggestions
- **Favorites:** Quick access to frequently used
- **Default folders:** Uncategorized, Favorites, Recently Uploaded

### Search Features
| Field | Searchable |
|-------|------------|
| Title | Yes (full-text) |
| Description | Yes (full-text) |
| Tags | Yes |
| File name | Yes |
| Brand/Category | Yes |

### Filter Options
- Content type (image/video/audio)
- Status (approved/pending/rejected)
- Date range (uploaded, modified)
- Usage (used in campaigns / unused)
- File size range

### Content Deletion
- **Soft delete:** Moved to archive
- **Active content:** Cannot delete if used in active campaigns
- **Archive retention:** 90 days, then permanent delete

## Acceptance Criteria

### For Library View
- [ ] Grid and list view options
- [ ] Preview thumbnails
- [ ] Show status badge (approved/pending/rejected)
- [ ] Show usage count (# campaigns)

### For Organization
- [ ] Create/rename/delete folders
- [ ] Move content between folders
- [ ] Add/remove tags (bulk supported)
- [ ] Mark as favorite

### For Search
- [ ] Full-text search across title, description, tags
- [ ] Filter by type, status, date
- [ ] Sort by date, name, usage, performance

### For Deletion
- [ ] Prevent delete if used in active campaign
- [ ] Show which campaigns use this content
- [ ] Soft delete → recoverable for 90 days

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoints:**
```
GET    /api/v1/content?search=...&type=...&status=...
GET    /api/v1/content/{id}
DELETE /api/v1/content/{id}              # Soft delete

GET    /api/v1/content/folders
POST   /api/v1/content/folders
PUT    /api/v1/content/folders/{id}
DELETE /api/v1/content/folders/{id}

POST   /api/v1/content/{id}/move         # Move to folder
POST   /api/v1/content/{id}/tags         # Add tags
DELETE /api/v1/content/{id}/tags/{tag}   # Remove tag
POST   /api/v1/content/{id}/favorite     # Toggle favorite
```

</details>

## Checklist (Subtasks)

- [ ] Implement list content with pagination
- [ ] Add search (full-text index)
- [ ] Add filters (type, status, date, usage)
- [ ] Implement folder CRUD
- [ ] Implement move to folder
- [ ] Implement tag management
- [ ] Implement soft delete with validation
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:22** - Rewrote with folder organization, search features, and deletion rules from CMS business rules.
