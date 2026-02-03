# RMN-Arms Backend Monorepo Architecture Document

## Metadata

| Field | Value |
|-------|-------|
| **Version** | 2.1 |
| **Created** | 2026-02-02 |
| **Status** | Approved |
| **Author** | RMN Team + Winston (Architect Agent) |
| **Base On** | architecture.md v1.0, PRD v1.0, EN Documents |

---

## 1. Executive Summary

### 1.1 Quyết định chính: Monorepo

**Lý do chọn Monorepo thay vì Multi-repo:**

| Factor | Monorepo | Multi-repo |
|--------|----------|------------|
| **Cross-service refactoring** | Single atomic commit | Multiple coordinated PRs |
| **Shared library update** | Immediate | Tag → release → bump in each consumer |
| **CI/CD maintenance** | One pipeline config | N pipelines to manage |
| **Kafka schema sharing** | Single proto/ dir, atomic updates | Dedicated schema repo + versioning |
| **Claude Code context** | Full visibility, hierarchical CLAUDE.md | 40-60% token overhead |
| **Team size (1-5 devs)** | Natural fit | Significant coordination overhead |

**Kết luận**: Với team nhỏ (RMN Team), monorepo là lựa chọn tối ưu. Key insight: **Repository layout does not determine service coupling; code design does.**

### 1.2 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT APPLICATIONS                             │
│                    (Flutter Web, Mobile, Device Agent)                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         API GATEWAY (api-gateway-svc)                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │   CORS   │ │  Logger  │ │  Auth    │ │Rate Limit│ │  Priority Router │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         │                            │                            │
         ▼                            ▼                            ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│   Auth Service  │        │  User Service   │        │Campaign Service │
│   (Epic 1)      │        │   (Epic 1)      │        │    (Epic 2)     │
└─────────────────┘        └─────────────────┘        └─────────────────┘
         │                            │                            │
         │                            │                            │
         ▼                            ▼                            ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│Supplier Service │        │ Device Service  │        │ Billing Service │
│    (Epic 3)     │        │    (Epic 4)     │        │    (Epic 5)     │
└─────────────────┘        └─────────────────┘        └─────────────────┘
         │                            │                            │
         │                            │                            │
         ▼                            ▼                            ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│   CMS Service   │        │Blocking Service │        │  Admin Service  │
│    (Epic 6)     │        │    (Epic 7)     │        │    (Epic 8)     │
└─────────────────┘        └─────────────────┘        └─────────────────┘
         │                            │                            │
         └────────────────────────────┼────────────────────────────┘
                                      │
                            ┌─────────┴─────────┐
                            │   Kafka Events    │
                            │   (Event Bus)     │
                            └─────────┬─────────┘
                                      │
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ CockroachDB  │  │    Redis     │  │    Kafka     │  │  S3/MinIO    │     │
│  │  (Primary)   │  │   (Cache)    │  │  (Events)    │  │  (Storage)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Monorepo Directory Structure

### 2.1 Complete Structure

```
demo-structure/                  # Project root
├── CLAUDE.md                    # Root: project overview
├── .gitignore
├── README.md
│
├── .github/
│   └── workflows/
│       ├── backend-api-gateway.yaml
│       ├── backend-auth-service.yaml
│       ├── backend-user-service.yaml
│       ├── backend-campaign-service.yaml
│       ├── backend-supplier-service.yaml
│       ├── backend-device-service.yaml
│       ├── backend-billing-service.yaml
│       ├── backend-cms-service.yaml
│       ├── backend-blocking-service.yaml
│       ├── backend-admin-service.yaml
│       ├── backend-proto-lint.yaml
│       └── fe-flutter.yaml
│
├── .claude/                     # Claude Code configuration
│   ├── settings.json            # Team-shared settings
│   ├── settings.local.json      # Personal (gitignore)
│   ├── agents/
│   │   ├── golang-expert.md
│   │   ├── flutter-expert.md
│   │   └── code-reviewer.md
│   └── commands/
│       ├── service-create.md
│       ├── event-create.md
│       ├── api-add.md
│       ├── feature-create.md    # Flutter feature
│       └── deploy.md
│
├── _bmad/                       # BMAD framework
├── _bmad-output/                # Planning artifacts
├── docs/                        # Project documentation
│
├── app/                         # Application code
│   │
│   ├── backend/                 # ===== BACKEND MONOREPO =====
│   │   ├── CLAUDE.md            # Backend architecture overview
│   │   ├── go.work              # Go workspace
│   │   ├── go.work.sum
│   │   ├── Makefile             # Backend commands
│   │   ├── docker-compose.yaml  # Local development
│   │   │
│   │   ├── proto/               # Event schemas (Protobuf)
│   │   │   ├── CLAUDE.md
│   │   │   ├── buf.yaml
│   │   │   ├── buf.gen.yaml
│   │   │   ├── common/
│   │   │   │   └── types.proto
│   │   │   └── events/
│   │   │       ├── auth/v1/events.proto
│   │   │       ├── user/v1/events.proto
│   │   │       ├── campaign/v1/events.proto
│   │   │       ├── supplier/v1/events.proto
│   │   │       ├── device/v1/events.proto
│   │   │       ├── billing/v1/events.proto
│   │   │       ├── cms/v1/events.proto
│   │   │       └── blocking/v1/events.proto
│   │   │
│   │   ├── generated/           # Generated code (committed)
│   │   │   └── go/
│   │   │       └── events/
│   │   │
│   │   ├── pkg/                 # Shared Go libraries
│   │   │   ├── CLAUDE.md
│   │   │   ├── config/
│   │   │   │   ├── config.go
│   │   │   │   └── model.go
│   │   │   ├── database/
│   │   │   │   ├── cockroach.go
│   │   │   │   ├── migrate.go
│   │   │   │   └── goose_logger.go
│   │   │   ├── redis/
│   │   │   │   └── redis.go
│   │   │   ├── kafka/
│   │   │   │   ├── publisher.go
│   │   │   │   ├── subscriber.go
│   │   │   │   └── schema.go
│   │   │   ├── httpclient/
│   │   │   │   ├── client.go
│   │   │   │   ├── options.go
│   │   │   │   └── retry.go
│   │   │   ├── middleware/
│   │   │   │   ├── cors.go
│   │   │   │   ├── auth.go
│   │   │   │   ├── ratelimit.go
│   │   │   │   ├── logger.go
│   │   │   │   └── request_id.go
│   │   │   ├── token/
│   │   │   │   ├── token.go
│   │   │   │   └── paseto.go
│   │   │   ├── errorx/
│   │   │   │   └── errorx.go
│   │   │   ├── logger/
│   │   │   │   ├── logger.go
│   │   │   │   └── opentelemetry.go
│   │   │   ├── httpserver/
│   │   │   │   ├── server.go
│   │   │   │   └── options.go
│   │   │   └── utils/
│   │   │       ├── file.go
│   │   │       ├── str.go
│   │   │       └── time.go
│   │   │
│   │   ├── services/            # Go microservices
│   │   │   ├── CLAUDE.md
│   │   │   │
│   │   │   ├── api-gateway/
│   │   │   │   ├── CLAUDE.md
│   │   │   │   ├── go.mod
│   │   │   │   ├── main.go
│   │   │   │   ├── Dockerfile
│   │   │   │   ├── config/
│   │   │   │   │   └── app.development.yaml
│   │   │   │   ├── internal/
│   │   │   │   │   ├── handlers/
│   │   │   │   │   ├── middleware/
│   │   │   │   │   └── server/
│   │   │   │   └── chart/
│   │   │   │       ├── Chart.yaml
│   │   │   │       ├── values.yaml
│   │   │   │       ├── values-dev.yaml
│   │   │   │       ├── values-stg.yaml
│   │   │   │       └── values-prd.yaml
│   │   │   │
│   │   │   ├── auth-service/    # Epic 1
│   │   │   │   ├── CLAUDE.md
│   │   │   │   ├── go.mod
│   │   │   │   ├── main.go
│   │   │   │   ├── Dockerfile
│   │   │   │   ├── config/
│   │   │   │   ├── internal/
│   │   │   │   │   ├── app/
│   │   │   │   │   │   ├── server.go
│   │   │   │   │   │   └── routes/
│   │   │   │   │   ├── common/
│   │   │   │   │   ├── dto/
│   │   │   │   │   ├── models/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   ├── logic/
│   │   │   │   │   ├── services/
│   │   │   │   │   ├── presentation/
│   │   │   │   │   ├── events/
│   │   │   │   │   └── migrations/
│   │   │   │   └── chart/
│   │   │   │
│   │   │   ├── user-service/        # Epic 1
│   │   │   ├── campaign-service/    # Epic 2
│   │   │   ├── supplier-service/    # Epic 3
│   │   │   ├── device-service/      # Epic 4
│   │   │   ├── billing-service/     # Epic 5
│   │   │   ├── cms-service/         # Epic 6
│   │   │   ├── blocking-service/    # Epic 7
│   │   │   └── admin-service/       # Epic 8
│   │   │
│   │   ├── infrastructure/      # Kubernetes & GitOps
│   │   │   ├── CLAUDE.md
│   │   │   ├── base/
│   │   │   │   ├── namespace.yaml
│   │   │   │   └── configmap.yaml
│   │   │   └── overlays/
│   │   │       ├── dev/
│   │   │       ├── stg/
│   │   │       └── prd/
│   │   │
│   │   └── argocd/
│   │       └── appset.yaml
│   │
│   └── fe/                      # ===== FRONTEND =====
│       ├── CLAUDE.md            # Frontend context
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── Makefile
│       │
│       ├── lib/
│       │   ├── main.dart
│       │   │
│       │   ├── core/            # Core utilities
│       │   │   ├── config/
│       │   │   ├── constants/
│       │   │   ├── theme/
│       │   │   └── utils/
│       │   │
│       │   ├── shared/          # Shared components
│       │   │   ├── widgets/
│       │   │   ├── models/
│       │   │   └── services/
│       │   │
│       │   ├── api/             # API layer
│       │   │   ├── client/
│       │   │   ├── models/
│       │   │   └── repositories/
│       │   │
│       │   └── features/        # Feature modules
│       │       ├── auth/
│       │       │   ├── data/
│       │       │   ├── domain/
│       │       │   └── presentation/
│       │       ├── dashboard/
│       │       ├── campaign/
│       │       ├── supplier/
│       │       ├── device/
│       │       ├── billing/
│       │       ├── cms/
│       │       └── admin/
│       │
│       ├── test/
│       │   ├── unit/
│       │   ├── widget/
│       │   └── integration/
│       │
│       └── web/
│           └── index.html
│
└── infrastructure/              # Shared infrastructure (optional)
    ├── terraform/               # Cloud resources
    └── scripts/                 # Deployment scripts
```

### 2.2 go.work Configuration

```go
// app/backend/go.work - Go Workspace for local development
go 1.23

use (
    ./pkg
    ./services/api-gateway
    ./services/auth-service
    ./services/user-service
    ./services/campaign-service
    ./services/supplier-service
    ./services/device-service
    ./services/billing-service
    ./services/cms-service
    ./services/blocking-service
    ./services/admin-service
)
```

**Lưu ý**: `go.work` có thể gitignore trong production, sử dụng `go.work.sum` để đảm bảo consistency.

### 2.3 Directory Summary

| Path | Description | Tech |
|------|-------------|------|
| `app/backend/` | Backend monorepo | Golang, Kafka, K8s |
| `app/fe/` | Frontend app | Flutter Web |
| `.github/workflows/` | CI/CD pipelines | GitHub Actions |
| `.claude/` | Claude Code config | Team settings |
| `_bmad-output/` | Planning artifacts | PRD, Architecture |
| `docs/` | Documentation | Markdown |

---

## 3. Service Architecture (Standard Layout)

### 3.1 Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Handlers   │  │ Middlewares │  │      Routes         │  │
│  │  (HTTP)     │  │ (Auth,Log)  │  │   (Gin Router)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     SERVICE LAYER                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               Services (DI Container)                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    Logic                              │    │
│  │           (Business Rules, Validation)                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  Repositories                         │    │
│  │              (GORM, Database Access)                  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  Models  │  │   DTOs   │  │  Cache   │  │  Events  │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Service Internal Structure

```
services/{service-name}/
├── main.go                          # Entry point
├── Dockerfile                       # Container build
├── go.mod                           # Service dependencies
│
├── config/
│   └── app.development.yaml         # Environment configs
│
├── internal/                        # Private application code
│   ├── app/
│   │   ├── server.go                # HTTP server initialization
│   │   └── routes/
│   │       ├── router.go            # Router setup
│   │       └── v1/routes.go         # API v1 endpoints
│   │
│   ├── common/
│   │   ├── app.go                   # Application context
│   │   └── errors/errors.go         # Error definitions
│   │
│   ├── dto/                         # Data Transfer Objects
│   │   ├── response.go              # Standard response format
│   │   └── {domain}.go              # Domain-specific DTOs
│   │
│   ├── models/                      # Database models
│   │   ├── base.go                  # Base model (ID, timestamps)
│   │   └── {domain}.go              # Domain entities
│   │
│   ├── repositories/                # Data access layer
│   │   └── {domain}_repository.go   # Repository implementations
│   │
│   ├── logic/                       # Business logic
│   │   └── {domain}/logic.go        # Domain logic
│   │
│   ├── services/                    # Service layer (DI container)
│   │   └── {domain}_service.go      # Service registration
│   │
│   ├── presentation/
│   │   ├── handlers/{domain}.go     # HTTP handlers
│   │   └── middlewares/             # Middleware implementations
│   │
│   ├── events/                      # Kafka event handlers
│   │   ├── publisher.go             # Event publishing
│   │   └── subscriber.go            # Event consuming
│   │
│   └── migrations/                  # Database migrations
│       ├── fs.go                    # Embed migrations
│       └── *.sql                    # Migration files
│
└── chart/                           # Helm chart
    ├── Chart.yaml
    ├── values.yaml
    ├── values-dev.yaml
    ├── values-stg.yaml
    └── values-prd.yaml
```

---

## 4. Configuration Management

### 4.1 Quyết định: YAML thay vì .env

**Lý do chọn YAML:**

| Aspect | YAML | .env |
|--------|------|------|
| **Cấu trúc** | Nested, hierarchical | Flat key=value |
| **Type safety** | Arrays, objects, numbers | Chỉ strings |
| **Comments** | Có (inline & block) | Hạn chế |
| **Validation** | Dễ validate schema | Khó hơn |
| **Readability** | Dễ đọc với config phức tạp | Khó với nhiều config |

### 4.2 File Structure

```
services/{service-name}/config/
├── config.yaml              # Base config (committed)
├── config.development.yaml  # Local dev (gitignore optional)
├── config.staging.yaml      # Staging (committed)
└── config.production.yaml   # Production (secrets manager)
```

### 4.3 Load Order

```
1. config.yaml           (base defaults)
2. config.{APP_ENV}.yaml (environment-specific)
3. Environment Variables (override sensitive data)
```

### 4.4 Environment Variable Override

Format: `SECTION_KEY` (uppercase, underscore-separated)

| YAML Path | Environment Variable |
|-----------|---------------------|
| `database.password` | `DATABASE_PASSWORD` |
| `redis.password` | `REDIS_PASSWORD` |
| `token.secret` | `TOKEN_SECRET` |
| `http_server.port` | `HTTP_SERVER_PORT` |

### 4.5 Sensitive Data Handling

**Rule: KHÔNG commit sensitive data vào YAML files**

| Data Type | Storage |
|-----------|---------|
| DB Password | Env var / K8s Secret |
| API Keys | Env var / K8s Secret |
| JWT Secret | Env var / K8s Secret |
| OAuth Secrets | Env var / Vault |

**Kubernetes Secret injection:**
```yaml
# values.yaml (Helm)
env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password
```

### 4.6 Usage in Go Services

```go
// internal/common/config.go
type Config struct {
    config.BaseConfig `yaml:",inline"`
    Token             TokenConfig `yaml:"token"`
    // Service-specific configs
}

// main.go
func main() {
    var cfg Config
    config.MustLoadConfig(config.GetConfigPath(), &cfg)
    // ...
}
```

---

## 5. Tech Stack

### 5.1 Core Technologies (continued from section 4)

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| **Language** | Go | 1.23+ | Primary backend language |
| **Database** | CockroachDB | Latest | Distributed SQL database |
| **Cache** | Redis | 7.x | Caching, rate limiting, sessions |
| **Message Queue** | Kafka | Latest | Event streaming |
| **Object Storage** | S3/MinIO | Latest | Media content storage |
| **Container** | Docker | Latest | Containerization |
| **Orchestration** | Kubernetes | 1.28+ | Container orchestration |
| **GitOps** | ArgoCD | Latest | Deployment automation |

### 4.2 Go Libraries

| Library | Purpose | Location |
|---------|---------|----------|
| **Gin** | HTTP router & framework | All services |
| **Viper** | Configuration management | `pkg/config/` |
| **GORM** | ORM for database | `pkg/database/` |
| **Zerolog** | Structured logging | `pkg/logger/` |
| **PASETO** | Token authentication | `pkg/token/` |
| **go-redis** | Redis client | `pkg/redis/` |
| **Goose** | Database migrations | `pkg/database/migrate.go` |
| **Buf CLI** | Protobuf for Kafka events | `proto/` |
| **confluent-kafka-go** | Kafka client | `pkg/kafka/` |
| **net/http** | Internal HTTP client | `pkg/httpclient/` |

### 4.3 Communication Patterns

| Communication | Protocol | Library | Use Case |
|---------------|----------|---------|----------|
| **External API** | HTTP REST | Gin | Client → API Gateway |
| **Service-to-Service (sync)** | HTTP REST | net/http | Real-time queries |
| **Service-to-Service (async)** | Kafka | confluent-kafka-go | Event-driven processing |
| **Caching** | Redis Protocol | go-redis | Session, rate limiting |

---

## 5. Services Inventory

### 5.1 Service Registry

| Service | Port | Epic | Description | Status |
|---------|------|------|-------------|--------|
| **api-gateway** | 8080 | Epic 1 | API Gateway với auth, rate limit, proxy | ✅ Implemented |
| **auth-service** | 8081 | Epic 1 | Authentication, JWT/PASETO tokens | ✅ Implemented |
| **user-service** | 8082 | Epic 1 | User/Profile management, RBAC | 🔄 In Progress |
| **campaign-service** | 8083 | Epic 2 | Campaign CRUD, scheduling, targeting | 🔜 To-do |
| **supplier-service** | 8084 | Epic 3 | Store/Supplier management | 🔜 To-do |
| **device-service** | 8085 | Epic 4 | Device heartbeat, playback logs | 🔜 To-do |
| **billing-service** | 8086 | Epic 5 | Wallet, billing engine, revenue | 🔜 To-do |
| **cms-service** | 8087 | Epic 6 | Content upload, approval, library | 🔜 To-do |
| **blocking-service** | 8088 | Epic 7 | Competitor blocking rules | 🔜 To-do |
| **admin-service** | 8089 | Epic 8 | Admin dashboard, user management | 🔜 To-do |

### 5.2 Service Communication Patterns

**Hai phương thức giao tiếp chính:**

| Pattern | Protocol | Use Case | Example |
|---------|----------|----------|---------|
| **Synchronous** | HTTP REST | Request-response, real-time queries | Auth validation, data fetching |
| **Asynchronous** | Kafka Events | Event-driven, decoupled processing | Billing charges, playback logs |

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVICE DEPENDENCY GRAPH                  │
└─────────────────────────────────────────────────────────────┘

api-gateway
    ├── auth-service (sync: HTTP REST)
    └── all services (proxy via HTTP)

auth-service
    ├── user-service (sync: HTTP REST)
    └── redis (session cache)

campaign-service
    ├── supplier-service (sync: HTTP REST)
    ├── device-service (sync: HTTP REST)
    ├── billing-service (async: Kafka)
    └── blocking-service (sync: HTTP REST)

billing-service
    ├── campaign-service (async: Kafka)
    └── device-service (async: Kafka)

cms-service
    ├── campaign-service (async: Kafka)
    └── device-service (async: Kafka)
```

### 5.3 Internal HTTP Client Pattern

Để gọi giữa các services, sử dụng internal HTTP client:

```go
// pkg/httpclient/client.go
type ServiceClient struct {
    baseURL    string
    httpClient *http.Client
}

func NewServiceClient(baseURL string) *ServiceClient {
    return &ServiceClient{
        baseURL: baseURL,
        httpClient: &http.Client{
            Timeout: 30 * time.Second,
        },
    }
}

// Example usage in campaign-service
func (c *CampaignLogic) GetSupplierInfo(ctx context.Context, supplierID string) (*SupplierDTO, error) {
    return c.supplierClient.Get(ctx, "/api/v1/suppliers/"+supplierID)
}
```

---

## 6. Kafka Event Architecture

### 6.1 Event Schema Management

**Protobuf + Buf CLI trong monorepo:**

```
proto/
├── buf.yaml                 # Buf config
├── buf.gen.yaml             # Code generation config
├── common/
│   └── types.proto          # Shared types
└── events/
    ├── campaign/v1/events.proto
    ├── billing/v1/events.proto
    └── device/v1/events.proto
```

**buf.yaml:**
```yaml
version: v1
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
```

**buf.gen.yaml:**
```yaml
version: v1
plugins:
  - plugin: go
    out: generated/go
    opt:
      - paths=source_relative
```

### 6.2 Event Naming Convention

| Domain | Topic Pattern | Example |
|--------|---------------|---------|
| Campaign | `campaign.{event}` | `campaign.created`, `campaign.status_changed` |
| Device | `device.{event}` | `device.heartbeat`, `device.playback_completed` |
| Billing | `billing.{event}` | `billing.charged`, `billing.revenue_distributed` |

### 6.3 Sample Event Definition

```protobuf
// proto/events/campaign/v1/events.proto
syntax = "proto3";
package events.campaign.v1;

import "common/types.proto";

message CampaignCreated {
  string campaign_id = 1;
  string advertiser_id = 2;
  string name = 3;
  common.Timestamp created_at = 4;
}

message CampaignStatusChanged {
  string campaign_id = 1;
  string old_status = 2;
  string new_status = 3;
  common.Timestamp changed_at = 4;
}
```

---

## 7. CI/CD with Path-Based Triggers

### 7.1 Per-Service GitHub Actions

```yaml
# .github/workflows/backend-campaign-service.yaml
name: backend-campaign-service
on:
  push:
    paths:
      - 'app/backend/services/campaign-service/**'
      - 'app/backend/pkg/**'                    # Shared libraries
      - 'app/backend/proto/events/campaign/**'  # Service-specific schema
      - 'app/backend/generated/go/events/campaign/**'
    branches: [main]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: app/backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'
          cache-dependency-path: 'app/backend/services/campaign-service/go.sum'

      - name: Test
        run: cd services/campaign-service && go test ./...

      - name: Build and push
        run: |
          docker build -t ghcr.io/${{ github.repository }}/campaign-service:${{ github.sha }} \
            -f services/campaign-service/Dockerfile .
          docker push ghcr.io/${{ github.repository }}/campaign-service:${{ github.sha }}
```

### 7.2 Frontend GitHub Actions

```yaml
# .github/workflows/fe-flutter.yaml
name: fe-flutter
on:
  push:
    paths:
      - 'app/fe/**'
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: app/fe
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

      - name: Build Web
        run: flutter build web --release
```

### 7.3 ArgoCD ApplicationSet

```yaml
# app/backend/argocd/appset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: rmn-services
spec:
  goTemplate: true
  generators:
    - git:
        repoURL: https://github.com/rmn-platform/demo-structure.git
        revision: HEAD
        directories:
          - path: app/backend/services/*/chart
  template:
    metadata:
      name: '{{index .path.segments 3}}-{{.values.env}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/rmn-platform/demo-structure.git
        path: '{{.path.path}}'
        helm:
          valueFiles:
            - values-{{.values.env}}.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{index .path.segments 3}}'
```

---

## 8. Claude Code Integration

### 8.1 Hierarchical CLAUDE.md Structure

```
demo-structure/
├── CLAUDE.md                    # Root: project overview
│
├── app/
│   ├── backend/
│   │   ├── CLAUDE.md            # Backend architecture overview
│   │   ├── services/
│   │   │   ├── CLAUDE.md        # Services common context
│   │   │   ├── campaign-service/
│   │   │   │   └── CLAUDE.md    # Per-service context
│   │   │   └── billing-service/
│   │   │       └── CLAUDE.md
│   │   ├── proto/
│   │   │   └── CLAUDE.md        # Schema conventions
│   │   └── pkg/
│   │       └── CLAUDE.md        # Shared library patterns
│   │
│   └── fe/
│       └── CLAUDE.md            # Frontend context
```

### 8.2 Root CLAUDE.md Template (demo-structure/CLAUDE.md)

```markdown
# RMN Platform - Demo Structure

## Project overview
RMN (Retail Media Network) advertising management platform.

## Directory structure
- app/backend/ — Golang microservices monorepo
- app/fe/ — Flutter Web frontend
- _bmad-output/ — Planning artifacts (PRD, Architecture)
- docs/ — Documentation

## Quick commands

### Backend
```bash
cd app/backend
make build          # Build all services
make test           # Test all services
buf generate        # Generate Kafka event code
```

### Frontend
```bash
cd app/fe
flutter pub get     # Install dependencies
flutter run -d chrome   # Run dev server
flutter test        # Run tests
```

## Communication Patterns
- Client → Backend: HTTP REST via API Gateway
- Service-to-Service (sync): HTTP REST
- Service-to-Service (async): Kafka Events
- NO gRPC in this project
```

### 8.3 Backend CLAUDE.md Template (app/backend/CLAUDE.md)

```markdown
# RMN Backend Monorepo

## Quick commands
- Full build: `make build`
- Service test: `cd services/<name> && go test ./...`
- Proto generation: `buf generate` (for Kafka events only)
- Staging deploy: `make deploy-stg SERVICE=<name>`

## Architecture
- External API: HTTP REST via API Gateway
- Service-to-Service (sync): HTTP REST via pkg/httpclient
- Service-to-Service (async): Kafka events (see proto/events/)
- Shared libraries live in pkg/ — import as internal packages
- Each service has its own Helm chart under chart/

## Conventions
- Event naming: PascalCase verb (CampaignCreated, UserUpdated)
- API versioning: /api/v1/, /api/v2/
- Service directory name matches Kubernetes namespace
- Follow layer architecture: Handler → Logic → Repository
```

### 8.4 Frontend CLAUDE.md Template (app/fe/CLAUDE.md)

```markdown
# RMN Frontend (Flutter Web)

## Quick commands
- Install: `flutter pub get`
- Run dev: `flutter run -d chrome`
- Test: `flutter test`
- Build: `flutter build web --release`

## Architecture
- Feature-First Clean Architecture
- State management: Riverpod / flutter_bloc
- Routing: go_router
- API client: dio

## Directory structure
- lib/core/ — Core utilities, theme, constants
- lib/shared/ — Shared widgets, models
- lib/api/ — API client, repositories
- lib/features/ — Feature modules (auth, campaign, etc.)

## Conventions
- Widget naming: PascalCase
- File naming: snake_case
- One widget per file for complex components
```

### 8.5 Team Settings

```json
// .claude/settings.json
{
  "permissions": {
    "allow": [
      "Bash(go build:*)",
      "Bash(go test:*)",
      "Bash(buf:*)",
      "Bash(make:*)",
      "Bash(docker:*)",
      "Bash(git:*)",
      "Bash(flutter:*)",
      "Bash(dart:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Read(.env*)",
      "Bash(kubectl delete:*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(app/backend/**/*.go)",
        "hooks": [{
          "type": "command",
          "command": "gofmt -w $CLAUDE_FILE_PATH"
        }]
      },
      {
        "matcher": "Write(app/fe/**/*.dart)",
        "hooks": [{
          "type": "command",
          "command": "dart format $CLAUDE_FILE_PATH"
        }]
      }
    ]
  }
}
```

---

## 9. Migration Strategy (Multi-repo → Monorepo)

### 9.1 Migration Steps

| Step | Action | Notes |
|------|--------|-------|
| 1 | Create monorepo structure | Set up directories, go.work |
| 2 | Move pkg/ (common libraries) | Update import paths |
| 3 | Move proto/ (event schemas) | Configure buf.yaml |
| 4 | Move services one by one | Update go.mod, remove replace directives |
| 5 | Configure GitHub Actions | Path-based triggers |
| 6 | Set up ArgoCD | ApplicationSet for all services |
| 7 | Update CLAUDE.md hierarchy | Team onboarding |

### 9.2 Current Services Mapping

| Old Name | New Name | Location |
|----------|----------|----------|
| `mtsgn-system-gateway-svc` | `api-gateway` | `services/api-gateway/` |
| `mtsgn-access-auth-svc` | `auth-service` | `services/auth-service/` |
| `mtsgn-access-user-svc` | `user-service` | `services/user-service/` |
| `mtsgn-aps-be-common-svc` | (merged to pkg/) | `pkg/` |
| `mtsgn-system-common-svc` | (merged to proto/ + pkg/) | `proto/`, `pkg/` |
| `mtsgn-source-base-svc` | (template removed) | Use service generator |

---

## 10. Epic-Service Mapping

| Epic | Service(s) | Stories |
|------|-----------|---------|
| **Epic 1: Foundation** | `api-gateway`, `auth-service`, `user-service` | Story 1.1-1.4 |
| **Epic 2: Campaign** | `campaign-service` | Story 2.1-2.5 |
| **Epic 3: Supplier** | `supplier-service` | Story 3.1-3.4 |
| **Epic 4: Device** | `device-service` | Story 4.1-4.4 |
| **Epic 5: Billing** | `billing-service` | Story 5.1-5.5 |
| **Epic 6: CMS** | `cms-service` | Story 6.1-6.4 |
| **Epic 7: Blocking** | `blocking-service` | Story 7.1-7.3 |
| **Epic 8: Admin** | `admin-service` | Story 8.1-8.3 |

---

## 11. Development Workflow

### 11.1 Local Development - Backend

```bash
# 1. Clone repo
git clone https://github.com/rmn-platform/demo-structure.git
cd demo-structure

# 2. Start local infra
cd app/backend
docker-compose up -d   # Kafka, CockroachDB, Redis

# 3. Initialize Go workspace
go work sync

# 4. Generate proto (Kafka events)
buf generate

# 5. Run a service
cd services/campaign-service && go run ./main.go

# 6. Start Claude Code (from project root)
cd ../..
claude
> /help
```

### 11.2 Local Development - Frontend

```bash
# 1. Navigate to frontend
cd app/fe

# 2. Install dependencies
flutter pub get

# 3. Run dev server
flutter run -d chrome

# 4. Run tests
flutter test
```

### 11.3 Creating a New Backend Service

```bash
# Use Claude Code command (from project root)
claude
> /service-create billing-service "Handles wallet, billing engine, revenue distribution"

# This will:
# 1. Create app/backend/services/billing-service/ with standard structure
# 2. Add to go.work
# 3. Create Dockerfile
# 4. Create Helm chart
# 5. Create GitHub Actions workflow
# 6. Create CLAUDE.md for the service
```

### 11.4 Creating a New Frontend Feature

```bash
# Use Claude Code command
claude
> /feature-create campaign "Campaign management feature"

# This will:
# 1. Create app/fe/lib/features/campaign/ with Clean Architecture
# 2. Add BLoC/Riverpod boilerplate
# 3. Add route to go_router
# 4. Create basic tests
```

---

## 12. Appendix

### 12.1 Backend Makefile Commands

```makefile
# app/backend/Makefile
.PHONY: build test lint proto deploy

# Build all services
build:
	@for dir in services/*/; do \
		echo "Building $$dir..."; \
		cd $$dir && go build ./... && cd ../..; \
	done

# Test all services
test:
	@for dir in services/*/; do \
		echo "Testing $$dir..."; \
		cd $$dir && go test ./... && cd ../..; \
	done

# Lint
lint:
	golangci-lint run ./...

# Generate proto (Kafka events)
proto:
	buf generate

# Deploy to staging
deploy-stg:
	@if [ -z "$(SERVICE)" ]; then echo "Usage: make deploy-stg SERVICE=<name>"; exit 1; fi
	cd services/$(SERVICE)/chart && helm upgrade --install $(SERVICE) . -f values-stg.yaml

# Run a specific service
run:
	@if [ -z "$(SERVICE)" ]; then echo "Usage: make run SERVICE=<name>"; exit 1; fi
	cd services/$(SERVICE) && go run ./main.go
```

### 12.2 Frontend Makefile Commands

```makefile
# app/fe/Makefile
.PHONY: get analyze test build run

# Install dependencies
get:
	flutter pub get

# Analyze code
analyze:
	flutter analyze

# Run tests
test:
	flutter test

# Build for web
build:
	flutter build web --release

# Run dev server
run:
	flutter run -d chrome

# Format code
format:
	dart format lib/ test/
```

### 12.3 Docker Compose (Local Development)

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
    volumes:
      - cockroach-data:/cockroach/cockroach-data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  kafka:
    image: confluentinc/cp-kafka:latest
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1

  minio:
    image: minio/minio:latest
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9001"

volumes:
  cockroach-data:
```

### 12.4 References

- Backend source: `app/backend/`
- Frontend source: `app/fe/`
- PRD: `_bmad-output/planning-artifacts/prd.md`
- Original Architecture: `_bmad-output/planning-artifacts/architecture.md`
- EN Documents: `backend/documents/*-EN.md`

---

**Document Version**: 2.2
**Last Updated**: 2026-02-02
**Author**: RMN Team + Winston (Architect Agent)

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.2 | 2026-02-02 | Restructure to `app/backend` and `app/fe` |
| 2.1 | 2026-02-02 | Remove gRPC, use HTTP REST only |
| 2.0 | 2026-02-02 | Initial monorepo architecture |
