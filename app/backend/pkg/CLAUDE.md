# RMN Backend - Shared Libraries (pkg/)

## Module
`rmn-backend/pkg`

## Packages

| Package | Purpose |
|---------|---------|
| `config/` | YAML config loading with env var override |
| `database/` | CockroachDB connection, Goose migrations |
| `redis/` | Redis client wrapper |
| `kafka/` | Kafka publisher/subscriber |
| `httpclient/` | Internal HTTP client for service-to-service |
| `middleware/` | Common HTTP middlewares |
| `token/` | PASETO token management |
| `errorx/` | Error types and codes |
| `logger/` | Zerolog wrapper |
| `httpserver/` | HTTP server setup |
| `utils/` | Utility functions |

## Config Package Usage

```go
// Define service config struct
type Config struct {
    config.BaseConfig `yaml:",inline"`
    Token TokenConfig `yaml:"token"`
}

// Load config
var cfg Config
config.MustLoadConfig(config.GetConfigPath(), &cfg)
```

**Load order:** `config.yaml` → `config.{APP_ENV}.yaml` → Environment Variables

**Env var override format:** `SECTION_KEY` (uppercase)
- `database.password` → `DATABASE_PASSWORD`
- `http_server.port` → `HTTP_SERVER_PORT`

## Usage in services
```go
import (
    "rmn-backend/pkg/config"
    "rmn-backend/pkg/database"
    "rmn-backend/pkg/logger"
)
```

## Adding a new package
1. Create directory under pkg/
2. Add Go files
3. Run `go work sync` from backend root
4. Import in services
