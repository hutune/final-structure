---
id: "STORY-4.1"
epic_id: "EPIC-004"
title: "Profile View & Edit"
status: "in-progress"
priority: "high"
assigned_to: "leonkenzo1997@gmail.com"
tags: ["frontend", "backend", "auth"]
story_points: 8
sprint: "Sprint 2"
start_date: "2026-02-01"
due_date: "2026-02-10"
time_estimate: 16
clickup_task_id: "86ewdmdjr"
---

# Profile View & Edit

## User Story

**As a** registered user,
**I want** to view and edit my profile information,
**So that** I can keep my account details up to date.

## Acceptance Criteria

- [ ] Profile page displays all user info (name, email, phone, bio)
- [ ] Edit mode with inline validation
- [ ] Save button with loading state
- [ ] Success/error toast notifications
- [ ] Cancel button reverts changes

## Technical Notes

- API: GET/PUT `/api/users/me`
- Form validation: Zod schema
- State management: React Query

## Checklist (Subtasks)

- [ ] API endpoint implementation
- [ ] Profile page UI
- [ ] Form validation
- [ ] Unit tests

## Updates

**2026-01-29 14:35** - @Leo: Đã bắt đầu implement API endpoint. Dự kiến xong GET/PUT endpoints trong hôm nay. Có 1 câu hỏi về validation rules cho phone number - cần confirm với PM.

