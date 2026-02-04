---
id: "EPIC-001"
title: "Project Foundation & Authentication"
status: "done"
priority: "critical"
assigned_to: null
tags: ["epic", "backend", "foundation", "auth"]
start_date: null
due_date: null
clickup_task_id: "86ewgdtzu"
---

# Project Foundation & Authentication

## Overview

Thiết lập nền tảng project với API Gateway, middleware stack, và Auth Service hoàn chỉnh. Đây là epic nền tảng mà tất cả các epic khác phụ thuộc vào.

## Goals

- Khởi tạo project structure chuẩn Golang
- Xây dựng API Gateway với middleware stack (CORS, Logger, Rate Limiter)
- Implement JWT Authentication Service
- Implement Role-Based Authorization

## User Stories

| ID | Title | Status | Assignee | Priority |
|----|-------|--------|----------|----------|
| STORY-1.1 | Project Setup & API Gateway Foundation | doing | Leo | Critical |
| STORY-1.2 | Middleware Stack Implementation | doing | Leo | Critical |
| STORY-1.3 | JWT Authentication Service | doing | Leo | Critical |
| STORY-1.4 | Role-Based Authorization Middleware | doing | Leo | Critical |
| STORY-1.5 | Password Reset Flow | to-do | - | High |
| STORY-1.6 | Email Verification Flow | to-do | - | Medium |
| STORY-1.7 | User Profile Management | to-do | - | Medium |
| STORY-1.8 | Infrastructure & DevOps Setup | to-do | - | High |

## Success Metrics

- API Gateway chạy stable trên port 8080
- Health check endpoint `/health` trả về 200
- JWT authentication hoạt động với token expiry 24h
- Rate limiting block requests vượt quá 100/min
- Role-based access control hoạt động đúng
- Password reset flow hoàn chỉnh
- Email verification functional
- User profile CRUD hoạt động
- Local dev environment setup trong < 5 phút

## Dependencies

- Không có dependency (Epic nền tảng)

## Tech Stack

- Golang
- JWT (HMAC-SHA256) / PASETO
- Viper (config management)
- CockroachDB (PostgreSQL compatible)
- Redis (token blacklist, rate limiting, sessions)
- Docker & Docker Compose (local dev)

## Updates

<!--
Progress updates will be added here.
Format: **YYYY-MM-DD** - Status update
-->

**2026-02-04** - Testing ClickUp workflow sync integration

**2026-02-04 14:45** - Testing workflows after grep pattern fix

**2026-02-04 14:47** - Testing after API mapping fixes (status=COMPLETE, priority=urgent)

**2026-02-04 14:58** - Testing with error logging enabled
