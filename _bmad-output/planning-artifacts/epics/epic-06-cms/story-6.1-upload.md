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
clickup_task_id: null
---

# Content Upload & Storage

## User Story

**As an** Advertiser,
**I want** upload hình ảnh và video quảng cáo,
**So that** tôi có content để chạy campaigns.

## Acceptance Criteria

- [ ] POST `/api/v1/content/upload` upload file lên S3
- [ ] Supported formats: JPG, PNG, MP4
- [ ] Max size: 500MB
- [ ] Minimum resolution: 1920x1080
- [ ] CDN URL được generate sau upload
- [ ] Content record được tạo với status "pending_approval"

## Technical Notes

**API Endpoint:**
```
POST /api/v1/content/upload (multipart/form-data)
```

**Database Table:**
```sql
CREATE TABLE contents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID NOT NULL REFERENCES users(id),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    content_type VARCHAR(50), -- image, video
    mime_type VARCHAR(100),
    size_bytes BIGINT,
    width INT,
    height INT,
    duration_seconds INT, -- for videos
    s3_key VARCHAR(500) NOT NULL,
    cdn_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    status VARCHAR(50) DEFAULT 'pending_approval',
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_contents_advertiser ON contents(advertiser_id);
CREATE INDEX idx_contents_status ON contents(status);
```

**Upload Response:**
```json
{
    "id": "uuid",
    "filename": "summer-sale.mp4",
    "content_type": "video",
    "size_bytes": 52428800,
    "duration_seconds": 15,
    "cdn_url": "https://cdn.example.com/content/abc123.mp4",
    "thumbnail_url": "https://cdn.example.com/thumbnails/abc123.jpg",
    "status": "pending_approval"
}
```

**Validation Rules:**
- File size <= 500MB
- Image: JPG, PNG, minimum 1920x1080
- Video: MP4, minimum 1920x1080, max duration 60s

## Checklist (Subtasks)

- [ ] Setup S3/MinIO connection
- [ ] Implement multipart upload endpoint
- [ ] Validate file type và size
- [ ] Extract metadata (resolution, duration)
- [ ] Generate unique S3 key
- [ ] Upload to S3
- [ ] Generate CDN URL
- [ ] Generate thumbnail for videos
- [ ] Create content record
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
