---
id: "STORY-6.4"
epic_id: "EPIC-006"
title: "Content Distribution to Devices"
status: "to-do"
priority: "normal"
assigned_to: null
tags: ["backend", "cms", "cdn", "distribution"]
story_points: 3
sprint: null
start_date: null
due_date: null
time_estimate: "1d"
clickup_task_id: null
---

# Content Distribution to Devices

## User Story

**As a** System,
**I want** phân phối content đến devices qua CDN,
**So that** devices có thể cache và phát content nhanh chóng.

## Acceptance Criteria

- [ ] CDN URLs được include trong playlist response
- [ ] Optimal caching headers được set
- [ ] Signed URLs cho security (optional)
- [ ] Cache invalidation khi content updated

## Technical Notes

**CDN URL Generation:**
```go
func (s *ContentService) GetCDNURL(content *Content) string {
    baseURL := s.config.CDNBaseURL
    return fmt.Sprintf("%s/content/%s", baseURL, content.S3Key)
}

// With signed URL (optional)
func (s *ContentService) GetSignedCDNURL(content *Content, expiry time.Duration) string {
    baseURL := s.config.CDNBaseURL
    url := fmt.Sprintf("%s/content/%s", baseURL, content.S3Key)
    return s.signURL(url, expiry)
}
```

**Caching Headers:**
```
Cache-Control: public, max-age=86400
ETag: "abc123"
```

**CDN Configuration:**
- Origin: S3 bucket
- TTL: 24 hours for content
- TTL: 1 hour for thumbnails
- Compression: enabled for images
- HTTPS only

**Cache Invalidation:**
```go
func (s *ContentService) InvalidateCache(content *Content) error {
    paths := []string{
        fmt.Sprintf("/content/%s", content.S3Key),
        fmt.Sprintf("/thumbnails/%s", content.ThumbnailKey),
    }
    return s.cdnClient.CreateInvalidation(paths)
}
```

## Checklist (Subtasks)

- [ ] Configure CDN (CloudFront/Cloudflare)
- [ ] Implement CDN URL generation
- [ ] Set appropriate caching headers
- [ ] Implement signed URLs (optional)
- [ ] Implement cache invalidation
- [ ] Test content delivery performance
- [ ] Unit tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
