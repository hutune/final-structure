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
**I want** nhận playlist cần phát từ server,
**So that** tôi biết phát quảng cáo nào và khi nào.

## Acceptance Criteria

- [ ] GET `/api/v1/devices/{id}/playlist` trả về current playlist
- [ ] Playlist chứa content items, schedule, priority order
- [ ] CDN URLs được include cho content files
- [ ] Device nhận notification khi playlist updated
- [ ] Playlist generation dựa trên active campaigns targeting store

## Technical Notes

**API Endpoint:**
```
GET /api/v1/devices/{id}/playlist
```

**Playlist Response:**
```json
{
    "playlist_id": "uuid",
    "device_id": "uuid",
    "generated_at": "2026-02-02T10:00:00Z",
    "valid_until": "2026-02-02T11:00:00Z",
    "items": [
        {
            "position": 1,
            "campaign_id": "uuid",
            "content_id": "uuid",
            "content_url": "https://cdn.example.com/content/abc.mp4",
            "duration_seconds": 15,
            "content_type": "video",
            "schedule": {
                "start_time": "09:00",
                "end_time": "21:00"
            },
            "priority": 1
        }
    ],
    "default_content": {
        "content_url": "https://cdn.example.com/default.mp4",
        "duration_seconds": 30
    }
}
```

**Playlist Generation Logic:**
```go
func (s *PlaylistService) GeneratePlaylist(deviceID string) *Playlist {
    device := s.deviceRepo.Get(deviceID)
    store := s.storeRepo.Get(device.StoreID)

    // Get active campaigns targeting this store
    campaigns := s.campaignRepo.FindActiveForStore(store.ID)

    // Filter by blocking rules
    campaigns = s.blockingEngine.FilterCampaigns(campaigns, store.ID)

    // Sort by priority/bid
    sort.Sort(ByPriority(campaigns))

    // Generate playlist items
    items := s.buildPlaylistItems(campaigns)

    return &Playlist{
        DeviceID: deviceID,
        Items: items,
        GeneratedAt: time.Now(),
        ValidUntil: time.Now().Add(1 * time.Hour),
    }
}
```

**Kafka Notification:**
- Topic: `playlist-updates`
- Device subscribes to updates
- Push notification on campaign changes

## Checklist (Subtasks)

- [ ] Implement Get Playlist endpoint
- [ ] Implement playlist generation logic
- [ ] Integrate với Campaign Service
- [ ] Integrate với Blocking Engine
- [ ] Generate CDN URLs
- [ ] Implement playlist caching
- [ ] Setup Kafka notifications
- [ ] Default content fallback
- [ ] Unit tests
- [ ] Integration tests

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
