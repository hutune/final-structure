---
id: "STORY-4.4"
epic_id: "EPIC-004"
title: "Device Playlist Sync"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["backend", "device", "playlist", "sync"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmcw"
---

# Device Playlist Sync

## User Story

**As a** Device,
**I want** to receive the correct ads to play at the right times,
**So that** I deliver the advertising content as scheduled.

## Business Context

Playlist sync ensures devices always have the right content:
- Content pre-distributed before campaign starts (24h lead time)
- Playlists updated when campaigns change
- Fallback content when no ads scheduled
- Offline caching for network interruptions

## Business Rules

> Reference: [05-business-rules-device.md](file:///Users/mazhnguyen/Desktop/final-structure/docs/_rmn-arms-docs/business-rules%20(en%20ver)/05-business-rules-device.md)

### Playlist Generation
1. Get active campaigns targeting device's store
2. Apply blocking rules (exclude blocked brands)
3. Sort by priority and bid
4. Build playlist with schedule constraints
5. Include CDN URLs for content

### Sync Timing
| Event | Action |
|-------|--------|
| Campaign starts | Push new playlist |
| Campaign ends | Remove from playlist |
| Campaign paused | Remove from playlist |
| Budget exhausted | Remove from playlist |
| Heartbeat response | Include playlist_updated flag |

### Content Pre-Distribution
- Content pushed 24 hours before campaign starts
- Device downloads and caches locally
- Confirmation sent to server
- Campaign only starts if content ready

### Playlist Validity
- Playlists valid for 1 hour max
- Device re-fetches if expired
- Server can force refresh via heartbeat

## Acceptance Criteria

### For Content Delivery
- [ ] Playlist includes CDN URLs for all content
- [ ] Content pre-distributed 24h before start
- [ ] Device caches content locally
- [ ] Fallback content when no ads available

### For Real-time Updates
- [ ] Playlist updated within 5 minutes of campaign change
- [ ] Push notification via Kafka
- [ ] Heartbeat response indicates update needed

### For Performance
- [ ] Playlist generation < 100ms
- [ ] CDN URLs with appropriate cache headers
- [ ] Support offline playback from cache

## Technical Notes

<details>
<summary>Implementation Details (For Dev)</summary>

**API Endpoint:**
```
GET /api/v1/devices/{id}/playlist
```

**Response:**
```json
{
  "playlist_id": "uuid",
  "device_id": "uuid",
  "generated_at": "2026-02-05T10:00:00Z",
  "valid_until": "2026-02-05T11:00:00Z",
  "items": [
    {
      "position": 1,
      "campaign_id": "uuid",
      "content_id": "uuid",
      "content_url": "https://cdn.example.com/content/abc.mp4",
      "duration_seconds": 15,
      "content_type": "video",
      "schedule": {"start_time": "09:00", "end_time": "21:00"},
      "priority": 1
    }
  ],
  "default_content": {
    "content_url": "https://cdn.example.com/default.mp4",
    "duration_seconds": 30
  }
}
```

**Kafka Topics:**
- `playlist-updates` - Notify devices of changes
- `campaign.started/paused/completed` - Trigger regeneration

</details>

## Checklist (Subtasks)

- [ ] Implement playlist generation logic
- [ ] Integrate with Campaign Service
- [ ] Integrate with Blocking Engine
- [ ] Generate CDN URLs with signatures
- [ ] Implement content pre-distribution
- [ ] Setup Kafka notifications
- [ ] Default content fallback
- [ ] Playlist caching (Redis)
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->

**2026-02-05 09:17** - Rewrote with playlist generation, pre-distribution, and real-time updates from device business rules.
