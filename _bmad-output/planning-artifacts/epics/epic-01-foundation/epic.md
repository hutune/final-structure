---
id: "EPIC-001"
title: "Project Foundation & Authentication"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["epic", "backend", "foundation", "auth"]
start_date: null
due_date: null
clickup_task_id: null
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

| ID | Title | Status | Assignee |
|----|-------|--------|----------|
| STORY-1.1 | Project Setup & API Gateway Foundation | to-do | - |
| STORY-1.2 | Middleware Stack Implementation | to-do | - |
| STORY-1.3 | JWT Authentication Service | to-do | - |
| STORY-1.4 | Role-Based Authorization Middleware | to-do | - |

## Success Metrics

- API Gateway chạy stable trên port 8080
- Health check endpoint `/health` trả về 200
- JWT authentication hoạt động với token expiry 24h
- Rate limiting block requests vượt quá 100/min
- Role-based access control hoạt động đúng

## Dependencies

- Không có dependency (Epic nền tảng)

## Tech Stack

- Golang
- JWT (HMAC-SHA256)
- Viper (config management)
- PostgreSQL

## Updates

<!--
Progress updates will be added here.
Format: **YYYY-MM-DD** - Status update
-->
