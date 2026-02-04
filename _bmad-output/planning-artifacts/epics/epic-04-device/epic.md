---
id: "EPIC-004"
title: "Device Integration & Playback"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["epic", "backend", "device", "playback", "heartbeat"]
start_date: null
due_date: null
clickup_task_id: "86ewgd3vp"
---

# Device Integration & Playback

## Overview

Xây dựng Device Service để xử lý heartbeat, playback logs, và proof-of-play. Đây là core service để tracking thiết bị và ghi nhận impressions cho billing.

## Goals

- Implement Device Heartbeat System
- Implement Playback Log Ingestion
- Implement Proof-of-Play Generation
- Implement Device Playlist Sync

## User Stories

| ID | Title | Status | Assignee |
|----|-------|--------|----------|
| STORY-4.1 | Device Heartbeat System | to-do | - |
| STORY-4.2 | Playback Log Ingestion | to-do | - |
| STORY-4.3 | Proof-of-Play Generation | to-do | - |
| STORY-4.4 | Device Playlist Sync | to-do | - |

## Success Metrics

- Heartbeat latency < 100ms
- Playback logs ingestion > 10,000 logs/second
- Device online detection trong < 2 phút
- Proof-of-play accuracy 100%

## Dependencies

- EPIC-001: Project Foundation & Authentication
- EPIC-003: Supplier & Store Management

## Tech Stack

- Golang
- Kafka
- MongoDB/ClickHouse (NoSQL for logs)
- PostgreSQL

## Updates

<!--
Progress updates will be added here.
Format: **YYYY-MM-DD** - Status update
-->
