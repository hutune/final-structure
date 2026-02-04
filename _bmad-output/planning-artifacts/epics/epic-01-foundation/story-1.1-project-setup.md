---
id: "STORY-1.1"
epic_id: "EPIC-001"
title: "Project Setup & API Gateway Foundation"
status: "doing"
priority: "critical"
assigned_to: "Leo <leonkenzo1997@gmail.com>"
tags: ["backend", "gateway", "setup"]
story_points: 5
sprint: 1
start_date: "2026-01-15"
due_date: "2026-01-17"
time_estimate: "2d"
clickup_task_id: null
---

# Project Setup & API Gateway Foundation

## User Story

**As a** Developer,
**I want** một project structure chuẩn với API Gateway cơ bản,
**So that** tôi có nền tảng để xây dựng các microservices.

## Acceptance Criteria

- [x] Project structure được tạo với các thư mục: `cmd/`, `internal/`, `config/`, `pkg/`
- [x] API Gateway chạy trên port 8080
- [x] Health check endpoint `/health` trả về status 200
- [x] Config được load từ `config/config.yaml` bằng Viper
- [x] Graceful shutdown được implement

## Implementation Notes

> **✅ DONE** - Đã implement trong các services hiện có:
> - `mtsgn-source-base-svc/` - Base template với full project structure
> - `mtsgn-system-gateway-svc/` - API Gateway implementation
> - Config loading: `pkg/config/config.go` sử dụng Viper
> - Server: `internal/app/server.go` với graceful shutdown

## Technical Notes

**Project Structure:**
```
├── cmd/
│   └── gateway/
│       └── main.go          # Entry point
├── internal/
│   ├── handlers/
│   ├── middleware/
│   └── config/
├── config/
│   └── config.yaml
├── pkg/
├── go.mod
└── go.sum
```

**Entry Point:** `cmd/gateway/main.go`
- Initializes configuration
- Sets up HTTP server
- Chains middleware

**Config Schema:**
```yaml
server:
  port: 8080
  host: "0.0.0.0"
```

## Checklist (Subtasks)

- [x] Initialize Go module với `go mod init`
- [x] Tạo folder structure
- [x] Implement config loading với YAML (updated from Viper)
- [x] Implement basic HTTP server
- [x] Implement `/health` endpoint
- [x] Implement graceful shutdown
- [x] Viết unit tests cho config loading
- [x] Tạo Dockerfile

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
