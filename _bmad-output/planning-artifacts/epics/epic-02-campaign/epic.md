---
id: "EPIC-002"
title: "Campaign Management Service"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["epic", "backend", "campaign"]
start_date: null
due_date: null
clickup_task_id: null
---

# Campaign Management Service

## Overview

Xây dựng Campaign Service với đầy đủ CRUD, scheduling, và targeting capabilities. Đây là core service cho phép Advertisers tạo và quản lý các chiến dịch quảng cáo.

## Goals

- Implement Campaign CRUD APIs
- Implement Campaign Status Management (submit, pause, resume, cancel)
- Implement Campaign Targeting & Store Selection
- Implement Campaign Scheduling Engine
- Implement Campaign List với filtering và pagination

## User Stories

| ID | Title | Status | Assignee |
|----|-------|--------|----------|
| STORY-2.1 | Campaign CRUD APIs | to-do | - |
| STORY-2.2 | Campaign Status Management | to-do | - |
| STORY-2.3 | Campaign Targeting & Store Selection | to-do | - |
| STORY-2.4 | Campaign Scheduling Engine | to-do | - |
| STORY-2.5 | Campaign List & Filtering | to-do | - |

## Success Metrics

- Advertiser có thể tạo campaign trong < 5 clicks
- Campaign status transitions hoạt động đúng state machine
- Scheduler tự động start/stop campaigns đúng thời gian
- API response time < 200ms cho list operations

## Dependencies

- EPIC-001: Project Foundation & Authentication

## Tech Stack

- Golang
- PostgreSQL
- Kafka (events)

## Updates

<!--
Progress updates will be added here.
Format: **YYYY-MM-DD** - Status update
-->
