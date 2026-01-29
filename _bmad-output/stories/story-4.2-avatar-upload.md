---
id: "STORY-4.2"
epic_id: "EPIC-004"
title: "Avatar Upload"
status: "to-do"
priority: "normal"
assigned_to: "work.huutrung@gmail.com"
tags: ["frontend", "backend", "performance"]
story_points: 5
sprint: "Sprint 2"
start_date: "2026-02-05"
due_date: "2026-02-12"
time_estimate: 10
clickup_task_id: null
---

# Avatar Upload

## User Story

**As a** registered user,
**I want** to upload and crop my profile picture,
**So that** I can personalize my account.

## Acceptance Criteria

- [ ] Image upload with drag & drop
- [ ] Crop tool with aspect ratio lock
- [ ] Preview before save
- [ ] Resize to 256x256 on server
- [ ] Support PNG, JPG, WebP

## Technical Notes

- Client: react-image-crop
- API: POST `/api/users/me/avatar`
- Storage: S3 bucket
- CDN: CloudFront

## Checklist (Subtasks)

- [ ] Upload component
- [ ] Crop functionality
- [ ] Backend resize
- [ ] S3 integration

## Updates

