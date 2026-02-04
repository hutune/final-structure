---
id: "STORY-1.8"
epic_id: "EPIC-001"
title: "Infrastructure & DevOps Setup"
status: "to-do"
priority: "high"
assigned_to: null
tags: ["devops", "infrastructure", "docker", "database"]
story_points: 5
sprint: null
start_date: null
due_date: null
time_estimate: "2d"
clickup_task_id: "86ewgdmce"
---

# Infrastructure & DevOps Setup

## User Story

**As a** Developer,
**I want** môi trường development local được setup hoàn chỉnh,
**So that** tôi có thể phát triển và test các services một cách dễ dàng.

## Acceptance Criteria

### AC1: Docker Compose for Local Development
- [ ] **Given** developer clone repo
- [ ] **When** chạy `docker-compose up -d`
- [ ] **Then** tất cả infrastructure services khởi động:
  - CockroachDB (port 26257)
  - Redis (port 6379)
  - Kafka (port 9092)
  - MinIO (port 9000, 9001)
- [ ] **And** services healthy và ready trong < 60 giây

### AC2: Database Migrations
- [ ] **Given** database đang chạy
- [ ] **When** chạy `make migrate`
- [ ] **Then** tất cả migrations được apply theo thứ tự
- [ ] **And** migration status có thể check được
- [ ] **And** rollback có thể thực hiện được

### AC3: Seed Data for Development
- [ ] **Given** database đã migrate
- [ ] **When** chạy `make seed`
- [ ] **Then** admin user được tạo với credentials mặc định
- [ ] **And** test data cơ bản được insert
- [ ] **And** seed script idempotent (chạy nhiều lần không duplicate)

### AC4: Service Configuration Templates
- [ ] **Given** developer muốn run service
- [ ] **When** copy config template và điền values
- [ ] **Then** service khởi động được với config local
- [ ] **And** có config.example.yaml cho reference

### AC5: Makefile Commands
- [ ] **Given** developer muốn thao tác với backend
- [ ] **When** sử dụng Makefile
- [ ] **Then** có các commands:
  - `make infra-up` - Start local infrastructure
  - `make infra-down` - Stop infrastructure
  - `make migrate` - Run migrations
  - `make seed` - Seed data
  - `make build` - Build all services
  - `make test` - Run all tests
  - `make run SERVICE=x` - Run specific service

### AC6: Health Check Scripts
- [ ] **Given** infrastructure đang chạy
- [ ] **When** chạy `make health-check`
- [ ] **Then** kiểm tra connectivity tới tất cả services
- [ ] **And** report status của từng service

## Edge Cases

| Edge Case | Expected Behavior |
|-----------|-------------------|
| Port conflict | Clear error message về port đang bị dùng |
| Docker not installed | Clear error message với instructions |
| Migration fail | Rollback và report error |
| Seed run multiple times | Idempotent, không duplicate data |
| Config file missing | Copy từ example và warn user |

## Technical Notes

**Docker Compose Structure:**
```yaml
# app/backend/docker-compose.yaml
version: '3.8'
services:
  cockroachdb:
    image: cockroachdb/cockroach:latest
    ports:
      - "26257:26257"
      - "8090:8080"
    command: start-single-node --insecure
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka:
    image: confluentinc/cp-kafka:latest
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

  minio:
    image: minio/minio:latest
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9001"
```

**Initial Migrations:**
```sql
-- 001_create_users.sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    email_verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

**Seed Data Script:**
```sql
-- seed.sql (idempotent)
INSERT INTO users (email, password_hash, role, status, email_verified_at)
VALUES ('admin@rmn-platform.com', '$2a$10$...', 'admin', 'verified', NOW())
ON CONFLICT (email) DO NOTHING;
```

**Makefile:**
```makefile
.PHONY: infra-up infra-down migrate seed build test run

infra-up:
	docker-compose up -d
	@echo "Waiting for services to be healthy..."
	@sleep 10
	@make health-check

infra-down:
	docker-compose down

migrate:
	@for svc in services/*/; do \
		if [ -d "$$svc/internal/migrations" ]; then \
			echo "Migrating $$svc..."; \
			cd $$svc && go run main.go migrate && cd ../..; \
		fi \
	done

seed:
	@echo "Seeding database..."
	cockroach sql --insecure --host=localhost:26257 -f scripts/seed.sql

health-check:
	@echo "Checking CockroachDB..." && curl -sf http://localhost:8090/health || echo "FAILED"
	@echo "Checking Redis..." && redis-cli ping || echo "FAILED"
	@echo "Checking MinIO..." && curl -sf http://localhost:9000/minio/health/live || echo "FAILED"
```

## Checklist (Subtasks)

- [ ] Tạo docker-compose.yaml với healthchecks
- [ ] Tạo Makefile với tất cả commands
- [ ] Setup database migrations structure
- [ ] Tạo initial migrations cho users table
- [ ] Tạo seed script với admin user
- [ ] Tạo config.example.yaml cho mỗi service
- [ ] Tạo health-check script
- [ ] Document trong README.md
- [ ] Test full flow: up → migrate → seed → run service

## Dependencies

- Docker và Docker Compose installed
- Go 1.23+ installed

## Updates

<!--
Dev comments will be added here by AI when updating via chat.
Format: **YYYY-MM-DD HH:MM** - @author: Message
-->
