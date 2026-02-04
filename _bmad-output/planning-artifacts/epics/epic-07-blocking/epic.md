---
id: "EPIC-007"
title: "Competitor Blocking Engine"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["epic", "backend", "blocking", "competitor"]
start_date: null
due_date: null
clickup_task_id: "86ewgd3wa"
---

# Competitor Blocking Engine

## Overview

Xây dựng engine để matching blocking rules với campaigns và tự động exclude stores. Đảm bảo quảng cáo đối thủ không hiển thị tại stores có blocking rules.

## Goals

- Implement Campaign Metadata Tagging
- Implement Blocking Rules Matching Engine
- Implement Conflict Resolution & Alternatives

## User Stories

| ID | Title | Status | Assignee |
|----|-------|--------|----------|
| STORY-7.1 | Campaign Metadata Tagging | to-do | - |
| STORY-7.2 | Blocking Rules Matching Engine | to-do | - |
| STORY-7.3 | Conflict Resolution & Alternatives | to-do | - |

## Success Metrics

- Blocking rule matching accuracy 100%
- Matching latency < 100ms
- Zero false positives (ads shown where they shouldn't)

## Dependencies

- EPIC-002: Campaign Management Service
- EPIC-003: Supplier & Store Management

## Tech Stack

- Golang
- PostgreSQL

## Updates

<!--
Progress updates will be added here.
Format: **YYYY-MM-DD** - Status update
-->
