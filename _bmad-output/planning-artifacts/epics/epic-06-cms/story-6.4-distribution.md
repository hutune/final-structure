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
clickup_task_id: "86ewgdm8y"
---

# Content Distribution to Devices

## User Story

**As an** Advertiser,
**I want** my content delivered to devices quickly and reliably,
**So that** my ads play smoothly without buffering or delays.

## Business Context

Fast content delivery is critical for seamless ad playback:
- CDN ensures low-latency delivery worldwide
- Pre-caching prevents buffering during playback
- Signed URLs protect content from unauthorized access
- Cache invalidation ensures updates propagate quickly

## Business Rules

> Reference: [10-business-rules-content.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/10-business-rules-content.md)

### CDN Architecture
| Tier | Purpose | TTL |
|------|---------|-----|
| Origin (S3) | Master storage | - |
| CDN Edge | Fast delivery | 24h |
| Device Cache | Offline playback | Until campaign ends |

### Content Pre-Distribution
- Content pushed 24h before campaign starts
- Device downloads and caches locally
- Confirmation sent to server before go-live
- Campaign blocked if content not ready

### Signed URLs
- All content URLs are signed (HMAC-SHA256)
- Expiry: 72 hours for device download
- Prevents hotlinking and unauthorized access

### Cache Invalidation
| Trigger | Action |
|---------|--------|
| Content updated | Invalidate CDN path |
| Content deleted | Invalidate + remove from devices |
| Campaign ends | Keep in device cache 24h, then purge |

## Acceptance Criteria

### For Delivery
- [ ] CDN URLs generated for all approved content
- [ ] Signed URLs with 72h expiry
- [ ] HTTPS-only delivery
- [ ] Compression for images (gzip/brotli)

### For Performance
- [ ] < 100ms latency to edge (target regions)
- [ ] Adaptive bitrate for videos (480p/720p/1080p)
- [ ] Fallback to origin if edge miss

### For Cache Management
- [ ] Pre-distribution 24h before campaign
- [ ] Invalidation on content update
- [ ] Device confirms download complete

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**CDN Configuration:**
```
Origin: s3.amazonaws.com/rmn-content-bucket
Edge Locations: Asia, Americas, Europe
Cache-Control: public, max-age=86400
Signed URL: HMAC-SHA256, 72h expiry
Compression: gzip for images, none for video
```

**Signed URL Generation:**
```go
func GenerateSignedURL(contentURL string, expiry time.Duration) string {
    expires := time.Now().Add(expiry).Unix()
    toSign := fmt.Sprintf("%s%d%s", contentURL, expires, secretKey)
    signature := hmacSHA256(toSign)
    return fmt.Sprintf("%s?expires=%d&sig=%s", contentURL, expires, signature)
}
```

</details>

## Checklist (Subtasks)

- [ ] Configure CDN (CloudFront/Cloudflare)
- [ ] Implement signed URL generation
- [ ] Set caching headers
- [ ] Implement pre-distribution job
- [ ] Implement cache invalidation
- [ ] Track download confirmations
- [ ] Load test CDN performance
- [ ] Unit tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:22** - Rewrote with CDN architecture, pre-distribution, and signed URLs from CMS business rules.
