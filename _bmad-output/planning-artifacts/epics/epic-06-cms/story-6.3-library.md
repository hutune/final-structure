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
**I want** quản lý thư viện content của tôi,
**So that** tôi có thể tái sử dụng content cho nhiều campaigns.

## Acceptance Criteria

- [ ] GET `/api/v1/content` trả về content library với filters
- [ ] Filter theo status, content_type
- [ ] DELETE `/api/v1/content/{id}` archive content
- [ ] Content đang được sử dụng không thể xóa

## Technical Notes

**API Endpoints:**
```
GET    /api/v1/content?status=approved&type=video&page=1
GET    /api/v1/content/{id}
DELETE /api/v1/content/{id}
```

**List Response:**
```json
{
    "data": [
        {
            "id": "uuid",
            "filename": "summer-sale.mp4",
            "content_type": "video",
            "thumbnail_url": "https://cdn.example.com/thumb/abc.jpg",
            "status": "approved",
            "duration_seconds": 15,
            "used_in_campaigns": 2,
            "created_at": "2026-02-01T10:00:00Z"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 45
    }
}
```

**Delete Validation:**
```go
func (s *ContentService) Delete(contentID string) error {
    content := s.repo.Get(contentID)

    // Check if used in active campaigns
    activeCampaigns := s.campaignRepo.FindActiveByContentID(contentID)
    if len(activeCampaigns) > 0 {
        return errors.New("content is used in active campaigns")
    }

    // Soft delete (archive)
    content.Status = "archived"
    content.ArchivedAt = time.Now()
    return s.repo.Update(content)
}
```

## Checklist (Subtasks)

- [ ] Implement List Content endpoint
- [ ] Add status filter
- [ ] Add content_type filter
- [ ] Add pagination
- [ ] Implement Get Content endpoint
- [ ] Implement Delete (archive) endpoint
- [ ] Check active campaign usage before delete
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
