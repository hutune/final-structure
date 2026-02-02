---
id: "STORY-1.1"
epic_id: "EPIC-001"
title: "Project Setup & API Gateway Foundation"
status: "to-do"
priority: "critical"
assigned_to: null
tags: ["backend", "gateway", "setup"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: null
---

# Project Setup & API Gateway Foundation

## User Story

**As a** Developer,
**I want** một project structure chuẩn với API Gateway cơ bản,
**So that** tôi có nền tảng để xây dựng các microservices.

## Acceptance Criteria

- [ ] Project structure được tạo với các thư mục: `cmd/`, `internal/`, `config/`, `pkg/`
- [ ] API Gateway chạy trên port 8080
- [ ] Health check endpoint `/health` trả về status 200
- [ ] Config được load từ `config/config.yaml` bằng Viper
- [ ] Graceful shutdown được implement

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

- [ ] Initialize Go module với `go mod init`
- [ ] Tạo folder structure
- [ ] Implement config loading với Viper
- [ ] Implement basic HTTP server
- [ ] Implement `/health` endpoint
- [ ] Implement graceful shutdown
- [ ] Viết unit tests cho config loading
- [ ] Tạo Dockerfile (optional)

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
