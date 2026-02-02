# 🏗️ RMN-Arms System Architecture

**Version**: 1.0  
**Date**: 2026-01-23  
**Status**: Draft  
**Owner**: Technical Architecture Team

---

## 📖 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Component Details](#-component-details)
3. [Request Flow](#-request-flow)
4. [Configuration Schema](#-configuration-schema)
5. [Security Features](#-security-features)
6. [Performance Considerations](#-performance-considerations)
7. [Extension Points](#-extension-points)
8. [Monitoring & Observability](#-monitoring--observability)
9. [Deployment Strategies](#-deployment-strategies)
10. [Best Practices](#-best-practices)

---

## 🎯 Architecture Overview

### 1.1 System Architecture

```
┌─────────────┐
│   Client    │  ← Flutter Web Frontend / Mobile App
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│   API Gateway (Port :8080)      │  ← Single Entry Point
│  ┌───────────────────────────┐  │
│  │   Middleware Stack        │  │
│  │  1. CORS                  │  │  ← Cross-Origin Handling
│  │  2. Logger                │  │  ← Request Logging
│  │  3. Rate Limiter          │  │  ← Rate Limiting
│  │  4. Authorization (JWT)   │  │  ← Token Validation
│  └──────┬────────────────────┘  │
│         │                        │
│         ▼                        │
│  ┌─────────────┐                │
│  │   Proxy     │                │  ← Request Routing
│  │   Handler   │                │
│  └──────┬──────┘                │
└─────────┼────────────────────────┘
          │
          ├──────────┬──────────┬──────────┬──────────┐
          ▼          ▼          ▼          ▼          ▼
    ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
    │ User   │ │ Auth   │ │Campaign│ │Device  │ │Content │
    │Service │ │Service │ │Service │ │Service │ │Service │
    │:8081   │ │:8082   │ │:8083   │ │:8084   │ │:8085   │
    └────┬───┘ └────┬───┘ └────┬───┘ └────┬───┘ └────┬───┘
         │          │          │          │          │
         └──────────┴──────────┴──────────┴──────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   PostgreSQL     │  ← Primary Database
                    │   + Redis Cache  │
                    └──────────────────┘
```

### 1.2 Architecture Description

**Microservices Architecture** with the following characteristics:

- **API Gateway**: Single entry point for all requests
- **Service Layer**: Independent microservices for each domain
- **Database Layer**: PostgreSQL for primary data, Redis for caching
- **CDN Layer**: CloudFront/Cloudflare for content delivery

**Benefits**:
- ✅ **Scalability** - Scale services independently
- ✅ **Maintainability** - Code organized by domain
- ✅ **Resilience** - Failure in one service doesn't affect entire system
- ✅ **Technology Flexibility** - Each service can use different stack

## 🔧 Component Details

### 2.1 Entry Point

**File**: `cmd/main.go`

**Functionality**:
```
1. INITIALIZE configuration from config.yaml
2. SET UP HTTP server (port 8080)
3. BUILD middleware chain in order:
   - Logger       → Log all requests
   - Rate Limiter → Limit requests per client
   - CORS         → Handle cross-origin
   - Authorization→ Validate JWT
   - Proxy Handler→ Route to microservices
```

**Code Flow**:
```go
func main() {
    // 1. Load configuration
    cfg := config.LoadConfig()
    
    // 2. Initialize services
    services := initServices(cfg)
    
    // 3. Build middleware chain
    handler := middleware.Logger(
        middleware.RateLimiter(
            middleware.CORS(
                middleware.Authorization(
                    handlers.ProxyHandler(services)
                )
            )
        )
    )
    
    // 4. Start server
    log.Printf("Starting gateway on :%d", cfg.Server.Port)
    http.ListenAndServe(":"+cfg.Server.Port, handler)
}
```

### 2.2 Configuration

**File**: `config/config.go`

**Configuration management with Viper**:

```yaml
server:
  port: 8080                    # Gateway port
  host: "0.0.0.0"              # Binding address
  read_timeout: 30             # Request read timeout (seconds)
  write_timeout: 30            # Response write timeout (seconds)

auth:
  jwt_secret: "${JWT_SECRET}"   # Secret from env var
  jwt_expiry: 3600             # Token expires after 1 hour

rate_limit:
  default_limit: 100            # Requests per minute (default)
  default_window: 60            # Time window (seconds)
  cleanup_interval: 300         # Cache cleanup (seconds)

services:
  - name: "user-service"
    base_path: "/api/users"
    target: "http://user-service:8081"
    methods: ["GET", "POST", "PUT", "DELETE"]
    rate_limit: 200             # Override global limit
    timeout: 30
    
  - name: "auth-service"
    base_path: "/api/auth"
    target: "http://auth-service:8082"
    methods: ["POST"]
    rate_limit: 50              # Lower for auth
    timeout: 10

  - name: "campaign-service"
    base_path: "/api/campaigns"
    target: "http://campaign-service:8083"
    methods: ["GET", "POST", "PUT", "DELETE"]
    rate_limit: 150
    timeout: 30
```

**Explanation**:
- 🔑 **JWT Secret**: Used to verify tokens, stored in environment variable
- ⏱️ **Timeout**: Prevents requests from running too long
- 🚦 **Rate Limit**: Protects system from abuse
- 🎯 **Service Config**: Defines routing for each microservice

### 2.3 Middleware Stack

#### 2.3.1 Logger Middleware

**File**: `internal/middleware/logger.go`

**Functionality**:
```
LOG all incoming requests with:
  • HTTP Method (GET, POST, PUT, DELETE)
  • Request Path (/api/users/123)
  • Remote Address (client IP)
  • Status Code (200, 404, 500, etc.)
  • Response Time (duration in ms)
```

**Implementation**:
```go
func Logger(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        
        // Capture response status
        rw := &responseWriter{ResponseWriter: w}
        
        // Call next handler
        next.ServeHTTP(rw, r)
        
        // Log request
        log.Printf(
            "[%s] %s %s - Status: %d, Duration: %v",
            r.Method,
            r.RemoteAddr,
            r.URL.Path,
            rw.status,
            time.Since(start),
        )
    })
}
```

**Output Example**:
```
[GET] 192.168.1.100 /api/campaigns/123 - Status: 200, Duration: 45ms
[POST] 192.168.1.101 /api/auth/login - Status: 401, Duration: 12ms
[PUT] 192.168.1.100 /api/campaigns/123 - Status: 200, Duration: 89ms
```

#### 2.3.2 Rate Limiter Middleware

**File**: `internal/middleware/ratelimit.go`

**Functionality**:
```
LIMIT number of requests per client using Token Bucket Algorithm:
  • Each client has own bucket (keyed by IP)
  • Bucket contains N tokens (N = rate limit)
  • Each request consumes 1 token
  • Tokens refill over time (refill rate)
  • If no tokens left → Return 429 Too Many Requests
```

**Token Bucket Algorithm**:
```
┌─────────────────┐
│   Token Bucket  │  Capacity: 100 tokens
│   [●●●●●●●●●●]  │  Refill: 100 tokens/minute
└─────────────────┘

Request arrives → Check tokens
├─ If tokens > 0:
│  ├─ Consume 1 token
│  └─ Allow request ✅
└─ If tokens = 0:
   └─ Reject request ❌ (429)

Background: Add tokens at refill rate
```

**Implementation**:
```go
type RateLimiter struct {
    mu       sync.Mutex
    clients  map[string]*bucket
    limit    int           // Tokens per window
    window   time.Duration // Time window
}

type bucket struct {
    tokens    int
    lastRefill time.Time
}

func (rl *RateLimiter) Allow(clientID string) bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()
    
    // Get or create bucket
    b, exists := rl.clients[clientID]
    if !exists {
        b = &bucket{
            tokens: rl.limit,
            lastRefill: time.Now(),
        }
        rl.clients[clientID] = b
    }
    
    // Refill tokens
    now := time.Now()
    elapsed := now.Sub(b.lastRefill)
    refill := int(elapsed.Seconds() / rl.window.Seconds() * float64(rl.limit))
    b.tokens = min(rl.limit, b.tokens + refill)
    b.lastRefill = now
    
    // Check and consume token
    if b.tokens > 0 {
        b.tokens--
        return true
    }
    return false
}
```

**Rate Limit Configuration**:
```yaml
# Global default
rate_limit:
  default_limit: 100      # 100 requests
  default_window: 60      # per 60 seconds (1 minute)

# Per-service override
services:
  - name: "auth-service"
    rate_limit: 50        # Stricter for auth endpoints
  - name: "campaign-service"
    rate_limit: 200       # More relaxed for campaigns
```

**Automatic Cleanup**:
```go
// Clean stale entries every 5 minutes
func (rl *RateLimiter) StartCleanup(interval time.Duration) {
    ticker := time.NewTicker(interval)
    go func() {
        for range ticker.C {
            rl.mu.Lock()
            now := time.Now()
            for id, b := range rl.clients {
                // Remove if inactive for > 10 minutes
                if now.Sub(b.lastRefill) > 10*time.Minute {
                    delete(rl.clients, id)
                }
            }
            rl.mu.Unlock()
        }
    }()
}
```

#### 2.3.3 CORS Middleware

**File**: `internal/middleware/cors.go`

**Functionality**:
```
HANDLE Cross-Origin Resource Sharing (CORS):
  • Add CORS headers to response
  • Handle preflight OPTIONS requests
  • Configure allowed origins, methods, headers
```

**CORS Explanation**:
```
What is CORS?
  → Browser security mechanism
  → Prevents one website from calling another's API
  → Server must configure to allow

Example:
  Frontend: https://rmn-arms.com
  API:      https://api.rmn-arms.com
  → Need CORS to allow frontend to call API
```

**Implementation**:
```go
func CORS(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Set CORS headers
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
        w.Header().Set("Access-Control-Max-Age", "3600")
        
        // Handle preflight
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        
        next.ServeHTTP(w, r)
    })
}
```

**Preflight Request**:
```
Browser sends OPTIONS request first to ask server:
  1. Browser: "Am I allowed to make POST request?"
     → OPTIONS /api/campaigns
  2. Server: "Yes, you can POST, GET, PUT, DELETE"
     → 200 OK + CORS headers
  3. Browser: "OK, now sending actual POST"
     → POST /api/campaigns
```

#### 2.3.4 Authorization Middleware

**File**: `internal/middleware/auth.go`

**Functionality**:
```
AUTHENTICATE JWT Token:
  • Extract token from Authorization header
  • Verify token with secret key
  • Parse user claims from token
  • Add user context to request
  • Reject request if token invalid
```

**JWT (JSON Web Token) Explanation**:
```
JWT Structure:
  [Header].[Payload].[Signature]
  
Header (format):
  {
    "alg": "HS256",      ← Algorithm
    "typ": "JWT"         ← Type
  }

Payload (user data):
  {
    "user_id": "123",    ← User ID
    "email": "user@example.com",
    "role": "advertiser",
    "exp": 1640000000    ← Expiry
  }

Signature:
  HMACSHA256(
    base64(header) + "." + base64(payload),
    secret_key
  )
```

**Implementation**:
```go
func Authorization(secret string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // Extract token from header
            authHeader := r.Header.Get("Authorization")
            if authHeader == "" {
                http.Error(w, "Missing authorization header", http.StatusUnauthorized)
                return
            }
            
            // Parse "Bearer <token>"
            parts := strings.Split(authHeader, " ")
            if len(parts) != 2 || parts[0] != "Bearer" {
                http.Error(w, "Invalid authorization format", http.StatusUnauthorized)
                return
            }
            tokenString := parts[1]
            
            // Verify and parse token
            token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
                // Validate algorithm
                if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
                    return nil, fmt.Errorf("unexpected signing method")
                }
                return []byte(secret), nil
            })
            
            if err != nil || !token.Valid {
                http.Error(w, "Invalid token", http.StatusUnauthorized)
                return
            }
            
            // Extract claims
            claims, ok := token.Claims.(jwt.MapClaims)
            if !ok {
                http.Error(w, "Invalid token claims", http.StatusUnauthorized)
                return
            }
            
            // Add user context to request
            ctx := context.WithValue(r.Context(), "user_id", claims["user_id"])
            ctx = context.WithValue(ctx, "role", claims["role"])
            
            // Continue with user context
            next.ServeHTTP(w, r.WithContext(ctx))
        })
    }
}
```

**Token Flow**:
```
1. User login → Auth service creates JWT token
2. Client stores token (localStorage/cookie)
3. Each request sends token in header:
   Authorization: Bearer eyJhbGc...
4. Gateway verifies token and extracts user info
5. Forward request with user context to service
```

### 2.4 Proxy Handler

**File**: `internal/handlers/proxy.go`

**Functionality**:
```
ROUTE request to appropriate microservice:
  • Match request path with service config
  • Rewrite URL (strip prefix)
  • Validate HTTP method
  • Forward headers
  • Handle timeout (30s default)
  • Return response from service
```

**URL Routing**:
```
Request Path              Service                Target URL
────────────────         ────────────           ─────────────────────
/api/users/123      →    user-service    →      http://user-service:8081/users/123
/api/auth/login     →    auth-service    →      http://auth-service:8082/auth/login
/api/campaigns/456  →    campaign-service →     http://campaign-service:8083/campaigns/456

URL Rewrite:
  Original:  /api/campaigns/456
  Strip:     /api           ← base_path
  Rewritten: /campaigns/456 ← forward this to service
```

**Implementation**:
```go
func ProxyHandler(services []ServiceConfig) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Find matching service
        var targetService *ServiceConfig
        for _, svc := range services {
            if strings.HasPrefix(r.URL.Path, svc.BasePath) {
                targetService = &svc
                break
            }
        }
        
        if targetService == nil {
            http.Error(w, "Service not found", http.StatusNotFound)
            return
        }
        
        // Validate method
        if !contains(targetService.Methods, r.Method) {
            http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
            return
        }
        
        // Rewrite URL
        targetPath := strings.TrimPrefix(r.URL.Path, targetService.BasePath)
        targetURL := targetService.Target + targetPath
        if r.URL.RawQuery != "" {
            targetURL += "?" + r.URL.RawQuery
        }
        
        // Create proxy request
        proxyReq, err := http.NewRequest(r.Method, targetURL, r.Body)
        if err != nil {
            http.Error(w, "Failed to create proxy request", http.StatusInternalServerError)
            return
        }
        
        // Copy headers
        for key, values := range r.Header {
            for _, value := range values {
                proxyReq.Header.Add(key, value)
            }
        }
        
        // Add timeout
        ctx, cancel := context.WithTimeout(r.Context(), targetService.Timeout)
        defer cancel()
        proxyReq = proxyReq.WithContext(ctx)
        
        // Send request to service
        client := &http.Client{}
        resp, err := client.Do(proxyReq)
        if err != nil {
            if ctx.Err() == context.DeadlineExceeded {
                http.Error(w, "Service timeout", http.StatusGatewayTimeout)
            } else {
                http.Error(w, "Service unavailable", http.StatusBadGateway)
            }
            return
        }
        defer resp.Body.Close()
        
        // Copy response headers
        for key, values := range resp.Header {
            for _, value := range values {
                w.Header().Add(key, value)
            }
        }
        
        // Copy response
        w.WriteHeader(resp.StatusCode)
        io.Copy(w, resp.Body)
    })
}
```

**Method Filtering**:
```yaml
services:
  - name: "auth-service"
    methods: ["POST"]           # Only allow POST (login, register)
    
  - name: "user-service"
    methods: ["GET", "PUT"]     # Only allow GET (read), PUT (update)
    
  - name: "campaign-service"
    methods: ["GET", "POST", "PUT", "DELETE"]  # Full CRUD
```

**Timeout Handling**:
```
Default: 30 seconds
  → If service doesn't respond within 30s
  → Gateway returns 504 Gateway Timeout
  → Prevents requests from running forever

Can configure different per service:
  - auth-service: 10s (fast)
  - campaign-service: 30s (medium)
  - report-service: 60s (slow, complex calculations)
```

---

## 🔄 Request Flow

### 3.1 Request Flow

```
┌─────────┐
│ Client  │ Sends request with JWT token
└────┬────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ 1. CORS Middleware                      │
│    ✓ Add CORS headers                   │
│    ✓ Handle preflight OPTIONS           │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ 2. Logger Middleware                    │
│    ✓ Log: method, path, IP, time       │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ 3. Rate Limiter Middleware              │
│    ✓ Check IP rate limit                │
│    ✓ Consume token from bucket          │
│    ✗ If no tokens → 429 Too Many        │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ 4. Authorization Middleware             │
│    ✓ Parse JWT token from header       │
│    ✓ Verify signature with secret       │
│    ✓ Extract user claims                │
│    ✓ Add user context to request        │
│    ✗ If invalid → 401 Unauthorized      │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ 5. Proxy Handler                        │
│    ✓ Match service by path              │
│    ✓ Validate HTTP method               │
│    ✓ Rewrite URL                        │
│    ✓ Forward request                    │
│    ✗ If timeout → 504 Gateway Timeout   │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────┐
│  Microservice   │ Process business logic
│  (User/Auth/    │
│   Campaign...)  │
└────┬────────────┘
     │
     ▼ Response returns through middleware in reverse
┌─────────┐
│ Client  │ Receives response
└─────────┘
```

### 3.2 Concrete Example

**Request**: Create new campaign

```http
POST /api/campaigns HTTP/1.1
Host: gateway.rmn-arms.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json

{
  "name": "Summer Sale 2026",
  "budget": 5000,
  "start_date": "2026-06-01"
}
```

**Processing**:

1. **CORS**: Add `Access-Control-Allow-Origin: *`
2. **Logger**: Log `[POST] 192.168.1.100 /api/campaigns`
3. **Rate Limiter**: 
   - Check IP `192.168.1.100` → has 85/100 tokens
   - Consume 1 token → 84/100 tokens left
   - Allow ✅
4. **Authorization**: 
   - Parse token → user_id="adv_123", role="advertiser"
   - Add context → `ctx["user_id"] = "adv_123"`
   - Allow ✅
5. **Proxy**: 
   - Match `/api/campaigns` → campaign-service
   - Rewrite `/api/campaigns` → `/campaigns`
   - Forward → `http://campaign-service:8083/campaigns`
   - Service response: `201 Created`
6. **Response**: Return `201 Created` with campaign data

**Log Output**:
```
[POST] 192.168.1.100 /api/campaigns - Status: 201, Duration: 89ms
```

### 3.3 Error Cases

#### Rate Limit Exceeded
```
Request #101 in 1 minute
→ Rate Limiter: tokens = 0
→ Response: 429 Too Many Requests
{
  "error": "Rate limit exceeded. Try again in 60 seconds."
}
```

#### Invalid Token
```
Authorization: Bearer invalid_token_here
→ Authorization Middleware: JWT verify failed
→ Response: 401 Unauthorized
{
  "error": "Invalid or expired token"
}
```

#### Service Timeout
```
Request → campaign-service
→ Service doesn't respond after 30s
→ Proxy Handler: context deadline exceeded
→ Response: 504 Gateway Timeout
{
  "error": "Service timeout"
}
```

#### Service Down
```
Request → user-service
→ Connection refused (service offline)
→ Proxy Handler: service unavailable
→ Response: 502 Bad Gateway
{
  "error": "Service unavailable"
}
```

---

## ⚙️ Configuration Schema

### 4.1 Configuration File

**File**: `config/config.yaml`

```yaml
# ════════════════════════════════════════
#  SERVER CONFIGURATION
# ════════════════════════════════════════
server:
  port: 8080                      # Gateway listening port
  host: "0.0.0.0"                 # Bind all network interfaces
  read_timeout: 30                # Request read timeout (seconds)
  write_timeout: 30               # Response write timeout (seconds)
  idle_timeout: 120               # Connection idle timeout (seconds)
  max_header_bytes: 1048576       # Max header size (1 MB)

# ════════════════════════════════════════
#  AUTHENTICATION CONFIGURATION
# ════════════════════════════════════════
auth:
  jwt_secret: "${JWT_SECRET}"     # Secret key (from env var)
  jwt_algorithm: "HS256"          # HMAC SHA-256
  jwt_expiry: 3600                # Token expires after 1 hour
  refresh_token_expiry: 604800    # Refresh token 7 days

# ════════════════════════════════════════
#  RATE LIMITING CONFIGURATION
# ════════════════════════════════════════
rate_limit:
  enabled: true                   # Enable/disable rate limiting
  default_limit: 100              # Requests per minute (global)
  default_window: 60              # Time window (seconds)
  cleanup_interval: 300           # Cleanup cache every 5 minutes
  burst_size: 10                  # Allow burst of 10 extra requests
  
  # Whitelist IPs not subject to rate limiting
  whitelist:
    - "127.0.0.1"                 # Localhost
    - "10.0.0.0/8"                # Internal network

# ════════════════════════════════════════
#  CORS CONFIGURATION
# ════════════════════════════════════════
cors:
  enabled: true
  allowed_origins:
    - "https://rmn-arms.com"
    - "https://app.rmn-arms.com"
    - "http://localhost:3000"     # Dev environment
  allowed_methods:
    - "GET"
    - "POST"
    - "PUT"
    - "DELETE"
    - "OPTIONS"
  allowed_headers:
    - "Content-Type"
    - "Authorization"
    - "X-Request-ID"
  expose_headers:
    - "X-Request-ID"
  max_age: 3600                   # Cache preflight 1 hour

# ════════════════════════════════════════
#  MICROSERVICES CONFIGURATION
# ════════════════════════════════════════
services:
  # ────────────────────────────────────
  #  User Service
  # ────────────────────────────────────
  - name: "user-service"
    base_path: "/api/users"
    target: "http://user-service:8081"
    methods: ["GET", "POST", "PUT", "DELETE"]
    rate_limit: 200               # Override global
    timeout: 30
    health_check: "/health"
    retry:
      max_attempts: 3
      backoff: "exponential"
    
  # ────────────────────────────────────
  #  Auth Service
  # ────────────────────────────────────
  - name: "auth-service"
    base_path: "/api/auth"
    target: "http://auth-service:8082"
    methods: ["POST"]
    rate_limit: 50                # Stricter for auth
    timeout: 10                   # Auth faster
    health_check: "/health"
    public: true                  # No JWT required
    
  # ────────────────────────────────────
  #  Campaign Service
  # ────────────────────────────────────
  - name: "campaign-service"
    base_path: "/api/campaigns"
    target: "http://campaign-service:8083"
    methods: ["GET", "POST", "PUT", "DELETE"]
    rate_limit: 150
    timeout: 30
    health_check: "/health"
    
  # ────────────────────────────────────
  #  Device Service
  # ────────────────────────────────────
  - name: "device-service"
    base_path: "/api/devices"
    target: "http://device-service:8084"
    methods: ["GET", "POST", "PUT", "DELETE"]
    rate_limit: 100
    timeout: 30
    health_check: "/health"
    
  # ────────────────────────────────────
  #  Content Service
  # ────────────────────────────────────
  - name: "content-service"
    base_path: "/api/content"
    target: "http://content-service:8085"
    methods: ["GET", "POST", "PUT", "DELETE"]
    rate_limit: 100
    timeout: 60                   # Upload needs longer timeout
    health_check: "/health"
    max_body_size: 524288000      # 500 MB for video upload
    
  # ────────────────────────────────────
  #  Impression Service
  # ────────────────────────────────────
  - name: "impression-service"
    base_path: "/api/impressions"
    target: "http://impression-service:8086"
    methods: ["POST", "GET"]
    rate_limit: 500               # Higher for device reporting
    timeout: 15
    health_check: "/health"
    
  # ────────────────────────────────────
  #  Wallet Service
  # ────────────────────────────────────
  - name: "wallet-service"
    base_path: "/api/wallets"
    target: "http://wallet-service:8087"
    methods: ["GET", "POST"]
    rate_limit: 100
    timeout: 30
    health_check: "/health"
    
  # ────────────────────────────────────
  #  Analytics Service
  # ────────────────────────────────────
  - name: "analytics-service"
    base_path: "/api/analytics"
    target: "http://analytics-service:8088"
    methods: ["GET", "POST"]
    rate_limit: 50
    timeout: 60                   # Report calculation slow
    health_check: "/health"

# ════════════════════════════════════════
#  LOGGING CONFIGURATION
# ════════════════════════════════════════
logging:
  level: "info"                   # debug, info, warn, error
  format: "json"                  # json, text
  output: "stdout"                # stdout, file
  file: "/var/log/gateway.log"    # If output = file
  
# ════════════════════════════════════════
#  MONITORING CONFIGURATION
# ════════════════════════════════════════
monitoring:
  enabled: true
  metrics_port: 9090              # Prometheus metrics
  health_port: 8081               # Health check endpoint
  
# ════════════════════════════════════════
#  TRACING CONFIGURATION
# ════════════════════════════════════════
tracing:
  enabled: true
  provider: "jaeger"              # jaeger, zipkin
  endpoint: "http://jaeger:14268/api/traces"
  sample_rate: 0.1                # Sample 10% requests
```

### 4.2 Environment Variables

**File**: `.env`

```bash
# ══════════════════════════════════════
#  ENVIRONMENT VARIABLES
# ══════════════════════════════════════

# Server
PORT=8080
ENVIRONMENT=production            # development, staging, production

# Authentication
JWT_SECRET=your-super-secret-key-change-this-in-production
JWT_EXPIRY=3600

# Database
DATABASE_URL=postgresql://user:pass@postgres:5432/rmn_arms
REDIS_URL=redis://redis:6379/0

# External Services
CDN_URL=https://cdn.rmn-arms.com
STORAGE_BUCKET=rmn-arms-content

# Monitoring
SENTRY_DSN=https://xxx@sentry.io/xxx
JAEGER_ENDPOINT=http://jaeger:14268/api/traces

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_DEFAULT=100

# Feature Flags
ENABLE_A/B_TESTING=true
ENABLE_ANALYTICS=true
```

---

## 🔒 Security Features

### 5.1 JWT Authentication

**How it works**:

1. **User Login** → Auth service verifies credentials
2. **Generate Token** → Create JWT with user claims
3. **Return Token** → Client stores token
4. **Send Token** → Each request sends in header
5. **Verify Token** → Gateway verifies signature
6. **Extract Claims** → Get user info
7. **Authorize** → Check user permissions

**Token Structure**:
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "user_id": "adv_123",
    "email": "advertiser@example.com",
    "role": "advertiser",
    "tier": "PREMIUM",
    "iat": 1640000000,
    "exp": 1640003600
  },
  "signature": "HMACSHA256(...)"
}
```

**Security Best Practices**:
- ✅ **Secret Key**: Long, random, stored in env var
- ✅ **Expiry**: Token expires after 1 hour
- ✅ **Refresh Token**: Use to get new token
- ✅ **HTTPS Only**: Only transmit token over HTTPS
- ✅ **Rotate Secret**: Change secret periodically

### 5.2 Rate Limiting

**Protects against**:
- 🛡️ **DDoS Attack**: Prevents too many requests
- 🛡️ **Brute Force**: Prevents password guessing
- 🛡️ **API Abuse**: Prevents API misuse
- 🛡️ **Resource Exhaustion**: Prevents resource depletion

**Strategies**:

```
Strategy 1: Fixed Window
  ┌─────┬─────┬─────┬─────┐
  │ 100 │ 100 │ 100 │ 100 │ requests per minute
  └─────┴─────┴─────┴─────┘
   00:00 00:01 00:02 00:03

  Issue: Can exceed 2x limit at window boundaries

Strategy 2: Sliding Window
  Smoother, more accurate
  More complex to implement

Strategy 3: Token Bucket (in use)
  ┌─────────────┐
  │ [●●●●●●●●●] │ 100 tokens
  └─────────────┘
  • Flexible, allows bursts
  • Easy to implement
  • Memory efficient
```

**Configuration**:
```yaml
rate_limit:
  # Global default
  default_limit: 100              # 100 requests
  default_window: 60              # per minute
  
  # Per-service override
  services:
    auth-service: 50              # Stricter
    impression-service: 500       # More relaxed
    
  # Whitelist (not rate limited)
  whitelist:
    - "127.0.0.1"                 # Localhost
    - "10.0.0.0/8"                # Internal network
```

### 5.3 CORS (Cross-Origin Resource Sharing)

**Why CORS?**

```
Same-Origin Policy:
  • Browser blocks requests between different domains
  • Protects users from cross-site attacks
  
Example:
  Frontend: https://rmn-arms.com
  API:      https://api.rmn-arms.com
  → Different domains → Need CORS to allow
```

**CORS Headers**:
```http
Access-Control-Allow-Origin: https://rmn-arms.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600
```

**Preflight Request**:
```
Browser automatically sends OPTIONS request first:

OPTIONS /api/campaigns HTTP/1.1
Host: api.rmn-arms.com
Origin: https://rmn-arms.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

Server response:
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://rmn-arms.com
Access-Control-Allow-Methods: POST, GET, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600

→ Browser caches preflight for 1 hour
→ Then sends actual POST
```

**Security Considerations**:
```yaml
# ❌ NOT SECURE - Allow all
cors:
  allowed_origins: ["*"]

# ✅ SECURE - Only allow specific domains
cors:
  allowed_origins:
    - "https://rmn-arms.com"
    - "https://app.rmn-arms.com"
```

---

## ⚡ Performance Considerations

### 6.1 In-Memory Rate Limiting

**Advantages**:
- ✅ **Fast**: No I/O, decisions in memory
- ✅ **Low Latency**: < 1ms overhead
- ✅ **Simple**: No Redis/database needed

**Disadvantages**:
- ❌ **Single Instance**: Doesn't share state between instances
- ❌ **Memory**: Stores bucket for each client
- ❌ **Restart**: Loses state on restart

**Suitable for**:
- Single gateway instance
- Small to medium scale
- Development environment

**Implementation**:
```go
type RateLimiter struct {
    mu      sync.Mutex
    clients map[string]*bucket  // IP → bucket
}

// Memory usage estimate:
// 1000 clients × 50 bytes/client = ~50 KB
// Very efficient!
```

### 6.2 Future: Redis-Based Rate Limiting

**When to use Redis?**
- Multiple gateway instances
- Need shared rate limiting
- High availability requirement

**Implementation**:
```go
func (rl *RedisRateLimiter) Allow(clientID string) bool {
    key := fmt.Sprintf("ratelimit:%s", clientID)
    
    // Atomic increment
    count, err := rl.redis.Incr(key).Result()
    if err != nil {
        return true  // Fail open
    }
    
    // Set expiry on first request
    if count == 1 {
        rl.redis.Expire(key, rl.window)
    }
    
    return count <= rl.limit
}
```

**Architecture with Redis**:
```
┌─────────────┐
│  Gateway 1  │──┐
└─────────────┘  │
                 ├──→ ┌─────────┐
┌─────────────┐  │    │  Redis  │  Shared state
│  Gateway 2  │──┤    └─────────┘
└─────────────┘  │
                 │
┌─────────────┐  │
│  Gateway 3  │──┘
└─────────────┘
```

### 6.3 Request Timeouts

**Why timeouts?**

```
Without timeout:
  Request → Service hangs → Gateway waits forever
  → Requests accumulate → Exhaust connections
  → Entire system freezes

With timeout:
  Request → Service hangs → Timeout after 30s
  → Gateway returns 504 Gateway Timeout
  → Release connection
  → System continues operating
```

**Configuration**:
```yaml
services:
  - name: "auth-service"
    timeout: 10        # Fast: login, register
    
  - name: "campaign-service"
    timeout: 30        # Medium: CRUD operations
    
  - name: "analytics-service"
    timeout: 60        # Slow: Report generation
    
  - name: "content-service"
    timeout: 120       # Very slow: Video upload/processing
```

**Cascading Timeouts**:
```
Client → Gateway → Service → Database

Timeouts:
  Client timeout:   120s
  Gateway timeout:  100s
  Service timeout:  80s
  Database timeout: 60s

→ Ensure timeouts cascade from inside out
→ Service times out before Gateway
→ Gateway times out before Client
```

### 6.4 Connection Pooling

**HTTP Client Pool**:
```go
var httpClient = &http.Client{
    Timeout: 30 * time.Second,
    Transport: &http.Transport{
        MaxIdleConns:        100,  // Total idle connections
        MaxIdleConnsPerHost: 10,   // Per backend service
        IdleConnTimeout:     90 * time.Second,
        DisableCompression:  false,
    },
}
```

**Benefits**:
- ✅ Reuse connections → Faster
- ✅ Reduce handshake overhead
- ✅ Better resource utilization

---

## 🔌 Extension Points

### 7.1 Adding New Middleware

**Step 1**: Create middleware file

**File**: `internal/middleware/custom.go`

```go
package middleware

import (
    "log"
    "net/http"
)

// CustomMiddleware - Custom middleware
func CustomMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // ════════════════════════════════════
        //  PRE-PROCESSING
        // ════════════════════════════════════
        
        // Example: Add custom header
        w.Header().Set("X-Custom-Header", "RMN-Arms")
        
        // Example: Log custom metrics
        log.Printf("Custom: Processing %s %s", r.Method, r.URL.Path)
        
        // ════════════════════════════════════
        //  CALL NEXT HANDLER
        // ════════════════════════════════════
        next.ServeHTTP(w, r)
        
        // ════════════════════════════════════
        //  POST-PROCESSING
        // ════════════════════════════════════
        
        // Example: Cleanup, metrics, etc.
        log.Printf("Custom: Finished processing")
    })
}
```

**Step 2**: Chain in main.go

```go
func main() {
    // Build middleware chain
    handler := middleware.Logger(
        middleware.RateLimiter(
            middleware.CORS(
                middleware.CustomMiddleware(    // ← Add here
                    middleware.Authorization(
                        handlers.ProxyHandler(services)
                    )
                )
            )
        )
    )
    
    http.ListenAndServe(":8080", handler)
}
```

**Middleware order matters**:
```
Request Flow:
  1. Logger        → Log first
  2. RateLimiter   → Check limit early
  3. CORS          → Set headers before auth
  4. CustomMiddleware
  5. Authorization → Check token last
  6. ProxyHandler

Response Flow (reverse):
  6. ProxyHandler
  5. Authorization
  4. CustomMiddleware
  3. CORS
  2. RateLimiter
  1. Logger        → Log last
```

### 7.2 Adding New Service

**Step 1**: Deploy new service

```bash
# Deploy notification service
docker run -d \
  --name notification-service \
  --network rmn-network \
  -p 8089:8089 \
  rmn-arms/notification-service:latest
```

**Step 2**: Add to config.yaml

```yaml
services:
  # ... existing services ...
  
  # ────────────────────────────────────
  #  Notification Service (NEW)
  # ────────────────────────────────────
  - name: "notification-service"
    base_path: "/api/notifications"
    target: "http://notification-service:8089"
    methods: ["GET", "POST", "DELETE"]
    rate_limit: 100
    timeout: 15
    health_check: "/health"
```

**Step 3**: Restart gateway

```bash
# Reload configuration
kill -HUP $(pidof gateway)

# Or restart
systemctl restart gateway
```

**Step 4**: Test

```bash
# Test new service
curl -X POST http://localhost:8080/api/notifications \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "message": "Your campaign is now active!",
    "type": "info"
  }'
```

### 7.3 Adding Custom Handler

**Use Case**: Health check endpoint

**File**: `internal/handlers/health.go`

```go
package handlers

import (
    "encoding/json"
    "net/http"
    "time"
)

type HealthResponse struct {
    Status    string    `json:"status"`
    Timestamp time.Time `json:"timestamp"`
    Version   string    `json:"version"`
    Services  []ServiceHealth `json:"services"`
}

type ServiceHealth struct {
    Name   string `json:"name"`
    Status string `json:"status"`
    Latency int  `json:"latency_ms"`
}

func HealthHandler(services []ServiceConfig) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        response := HealthResponse{
            Status:    "healthy",
            Timestamp: time.Now(),
            Version:   "1.0.0",
            Services:  []ServiceHealth{},
        }
        
        // Check each service
        for _, svc := range services {
            start := time.Now()
            
            // Ping service health endpoint
            resp, err := http.Get(svc.Target + svc.HealthCheck)
            latency := time.Since(start).Milliseconds()
            
            status := "healthy"
            if err != nil || resp.StatusCode != 200 {
                status = "unhealthy"
                response.Status = "degraded"
            }
            
            response.Services = append(response.Services, ServiceHealth{
                Name:    svc.Name,
                Status:  status,
                Latency: int(latency),
            })
        }
        
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(response)
    })
}
```

**Register in main.go**:

```go
func main() {
    // ... existing code ...
    
    // Register health endpoint
    http.HandleFunc("/health", handlers.HealthHandler(services))
    
    // Register main gateway handler
    http.Handle("/api/", handler)
    
    http.ListenAndServe(":8080", nil)
}
```

**Test**:

```bash
curl http://localhost:8080/health

# Response:
{
  "status": "healthy",
  "timestamp": "2026-01-23T10:30:00Z",
  "version": "1.0.0",
  "services": [
    {
      "name": "user-service",
      "status": "healthy",
      "latency_ms": 5
    },
    {
      "name": "auth-service",
      "status": "healthy",
      "latency_ms": 3
    },
    {
      "name": "campaign-service",
      "status": "unhealthy",
      "latency_ms": 5000
    }
  ]
}
```

---

## 📊 Monitoring & Observability

### 8.1 Current State

**✅ Available**:
- Request logging (method, path, IP, status, duration)
- Health check endpoint
- Error responses with proper status codes

### 8.2 Future Enhancements

#### 8.2.1 Prometheus Metrics

**Metrics to collect**:

```go
// Counter - Count occurrences
http_requests_total{method="GET", path="/api/campaigns", status="200"}

// Histogram - Distribution
http_request_duration_seconds{method="GET", path="/api/campaigns"}

// Gauge - Current value
active_connections
rate_limit_current{client_ip="192.168.1.100"}
```

**Implementation**:

```go
import "github.com/prometheus/client_golang/prometheus"

var (
    requestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "path", "status"},
    )
    
    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request duration",
            Buckets: []float64{.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10},
        },
        []string{"method", "path"},
    )
)

func PrometheusMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        rw := &responseWriter{ResponseWriter: w}
        
        next.ServeHTTP(rw, r)
        
        duration := time.Since(start).Seconds()
        requestsTotal.WithLabelValues(r.Method, r.URL.Path, fmt.Sprint(rw.status)).Inc()
        requestDuration.WithLabelValues(r.Method, r.URL.Path).Observe(duration)
    })
}

// Expose metrics endpoint
http.Handle("/metrics", promhttp.Handler())
```

**Grafana Dashboard**:
```
┌────────────────────────────────────────┐
│  RMN-Arms Gateway Metrics              │
├────────────────────────────────────────┤
│  Requests/sec:  ████████░  850 req/s   │
│  Avg Latency:   ████████░  45ms        │
│  Error Rate:    █░░░░░░░░  0.5%        │
│                                        │
│  Top Endpoints:                        │
│  /api/impressions  450 req/s           │
│  /api/campaigns    200 req/s           │
│  /api/devices      150 req/s           │
└────────────────────────────────────────┘
```

#### 8.2.2 Distributed Tracing

**OpenTelemetry Integration**:

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/trace"
)

func TracingMiddleware(tracer trace.Tracer) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            ctx, span := tracer.Start(r.Context(), r.URL.Path)
            defer span.End()
            
            span.SetAttributes(
                attribute.String("http.method", r.Method),
                attribute.String("http.url", r.URL.String()),
                attribute.String("http.remote_addr", r.RemoteAddr),
            )
            
            next.ServeHTTP(w, r.WithContext(ctx))
            
            span.SetAttributes(
                attribute.Int("http.status_code", rw.status),
            )
        })
    }
}
```

**Trace Visualization (Jaeger)**:
```
Request: POST /api/campaigns
├─ Gateway (15ms)
│  ├─ Rate Limiter (1ms)
│  ├─ Authorization (5ms)
│  └─ Proxy (9ms)
└─ Campaign Service (50ms)
   ├─ Validate Campaign (10ms)
   ├─ Database Insert (30ms)
   └─ Kafka Publish (10ms)

Total: 65ms
```

#### 8.2.3 Log Aggregation

**Structured Logging**:

```go
import "go.uber.org/zap"

logger, _ := zap.NewProduction()

logger.Info("Request processed",
    zap.String("method", r.Method),
    zap.String("path", r.URL.Path),
    zap.String("remote_addr", r.RemoteAddr),
    zap.Int("status", status),
    zap.Duration("duration", duration),
    zap.String("user_id", userID),
)

// Output (JSON):
{
  "level": "info",
  "ts": 1640000000.123,
  "msg": "Request processed",
  "method": "POST",
  "path": "/api/campaigns",
  "remote_addr": "192.168.1.100",
  "status": 201,
  "duration": 0.089,
  "user_id": "adv_123"
}
```

**ELK Stack Integration**:
```
Gateway → Filebeat → Logstash → Elasticsearch → Kibana

Kibana Dashboard:
┌──────────────────────────────────────┐
│  Search: status:500 OR status:503    │
├──────────────────────────────────────┤
│  [ERROR] Service timeout             │
│    Path: /api/campaigns               │
│    Duration: 30s                      │
│    Time: 2026-01-23 10:15:30         │
│                                      │
│  [ERROR] Rate limit exceeded         │
│    IP: 192.168.1.100                 │
│    Path: /api/auth/login             │
│    Time: 2026-01-23 10:16:45         │
└──────────────────────────────────────┘
```

---

## 🚀 Deployment Strategies

### 9.1 Single Instance

**Suitable for**:
- Development environment
- Small scale deployment
- MVP / Prototype

**Architecture**:
```
┌─────────┐
│  Client │
└────┬────┘
     │
     ▼
┌────────────────┐
│  Gateway       │  Single instance
│  (Port 8080)   │  In-memory rate limiting
└────┬───────────┘
     │
     ▼
┌────────────────┐
│  Microservices │
└────────────────┘
```

**Deployment**:
```bash
# Build
go build -o gateway cmd/main.go

# Run
./gateway --config config.yaml

# Or Docker
docker run -d \
  --name gateway \
  -p 8080:8080 \
  -v $(pwd)/config.yaml:/app/config.yaml \
  rmn-arms/gateway:latest
```

**Pros**:
- ✅ Simple setup
- ✅ No coordination needed
- ✅ Low overhead

**Cons**:
- ❌ Single point of failure
- ❌ Limited scalability
- ❌ No high availability

### 9.2 Load Balanced

**Suitable for**:
- Production environment
- High traffic
- High availability requirement

**Architecture**:
```
┌─────────┐
│  Client │
└────┬────┘
     │
     ▼
┌────────────────┐
│  Load Balancer │  Nginx / HAProxy / AWS ALB
│  (Port 443)    │
└────┬───────────┘
     │
     ├─────────┬─────────┐
     ▼         ▼         ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│Gateway 1│ │Gateway 2│ │Gateway 3│
└────┬────┘ └────┬────┘ └────┬────┘
     │           │           │
     └───────────┴───────────┘
                 │
                 ▼
        ┌────────────────┐
        │  Redis         │  Shared rate limiting
        └────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │  Microservices │
        └────────────────┘
```

**Nginx Configuration**:
```nginx
upstream gateway_backend {
    least_conn;                    # Load balancing algorithm
    server gateway1:8080 weight=1;
    server gateway2:8080 weight=1;
    server gateway3:8080 weight=1;
    
    # Health check
    check interval=3000 rise=2 fall=3 timeout=1000;
}

server {
    listen 443 ssl http2;
    server_name api.rmn-arms.com;
    
    ssl_certificate /etc/ssl/rmn-arms.crt;
    ssl_certificate_key /etc/ssl/rmn-arms.key;
    
    location / {
        proxy_pass http://gateway_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
}
```

**Shared Rate Limiting with Redis**:
```go
// Use Redis instead of in-memory
func NewRedisRateLimiter(redis *redis.Client) *RedisRateLimiter {
    return &RedisRateLimiter{
        redis: redis,
        limit: 100,
        window: 60 * time.Second,
    }
}

func (rl *RedisRateLimiter) Allow(clientID string) bool {
    key := fmt.Sprintf("ratelimit:%s", clientID)
    
    // Use Redis pipeline for atomic ops
    pipe := rl.redis.Pipeline()
    incr := pipe.Incr(ctx, key)
    pipe.Expire(ctx, key, rl.window)
    _, err := pipe.Exec(ctx)
    
    if err != nil {
        return true  // Fail open
    }
    
    return incr.Val() <= int64(rl.limit)
}
```

**Pros**:
- ✅ High availability
- ✅ Horizontal scaling
- ✅ No single point of failure
- ✅ Better resource utilization

**Cons**:
- ❌ More complex setup
- ❌ Need Redis for shared state
- ❌ Higher infrastructure cost

### 9.3 Containerized (Docker & Kubernetes)

**Docker Compose** (Development):

```yaml
version: '3.8'

services:
  gateway:
    image: rmn-arms/gateway:latest
    ports:
      - "8080:8080"
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./config.yaml:/app/config.yaml
    depends_on:
      - redis
      - user-service
      - auth-service
      - campaign-service
    
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    
  user-service:
    image: rmn-arms/user-service:latest
    ports:
      - "8081:8081"
    
  auth-service:
    image: rmn-arms/auth-service:latest
    ports:
      - "8082:8082"
    
  campaign-service:
    image: rmn-arms/campaign-service:latest
    ports:
      - "8083:8083"
```

**Kubernetes** (Production):

```yaml
# gateway-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gateway
  namespace: rmn-arms
spec:
  replicas: 3                      # 3 instances
  selector:
    matchLabels:
      app: gateway
  template:
    metadata:
      labels:
        app: gateway
    spec:
      containers:
      - name: gateway
        image: rmn-arms/gateway:latest
        ports:
        - containerPort: 8080
        env:
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: gateway-secrets
              key: jwt-secret
        - name: REDIS_URL
          value: "redis://redis-service:6379"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5

---
# gateway-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: gateway-service
  namespace: rmn-arms
spec:
  type: LoadBalancer
  selector:
    app: gateway
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

---
# gateway-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: gateway-hpa
  namespace: rmn-arms
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gateway
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Benefits**:
- ✅ **Auto-scaling**: Scale based on CPU/Memory
- ✅ **Self-healing**: Restart on crash
- ✅ **Rolling updates**: Zero-downtime deployment
- ✅ **Service discovery**: Automatic service finding
- ✅ **Load balancing**: Built-in LB

**Deploy Commands**:
```bash
# Apply configuration
kubectl apply -f gateway-deployment.yaml
kubectl apply -f gateway-service.yaml
kubectl apply -f gateway-hpa.yaml

# Check status
kubectl get pods -n rmn-arms
kubectl get svc -n rmn-arms
kubectl get hpa -n rmn-arms

# View logs
kubectl logs -f gateway-pod-xxx -n rmn-arms

# Scale manually
kubectl scale deployment gateway --replicas=5 -n rmn-arms
```

**Benefits**:
- **Auto-scaling**: HPA automatically adjusts replicas
- **Self-healing**: Failed pods are automatically restarted
- **Rolling updates**: Zero-downtime deployments
- **Service discovery**: Built-in service mesh
- **Load balancing**: Automatic traffic distribution

---

## 📋 Best Practices

### 10.1 Configuration Management

**✅ DO**:
```yaml
# Use environment variables for secrets
auth:
  jwt_secret: "${JWT_SECRET}"     # ← From env var

# Separate configs per environment
config/
  ├── config.dev.yaml
  ├── config.staging.yaml
  └── config.prod.yaml

# Version control non-sensitive configs
git add config/*.yaml
```

**❌ DON'T**:
```yaml
# NEVER commit secrets to git
auth:
  jwt_secret: "my-secret-key-123"  # ← DANGEROUS!

# NEVER hardcode production values
database:
  url: "postgres://prod-db:5432"  # ← DANGEROUS!
```

### 10.2 Security

**✅ DO**:
```
• Rotate JWT secrets periodically (every 90 days)
• Implement HTTPS/TLS for production
• Monitor suspicious patterns:
  - Too many 401 errors → Brute force attack?
  - Sudden traffic spike → DDoS attack?
  - Unusual access patterns → Bot activity?
• Use strong secrets (>= 32 characters, random)
• Enable rate limiting per endpoint
• Log security events
```

**❌ DON'T**:
```
• NEVER use HTTP in production
• NEVER expose internal services to internet
• NEVER log sensitive data (passwords, tokens)
• NEVER use default secrets
• NEVER skip input validation
```

### 10.3 Performance

**✅ DO**:
```
• Adjust rate limits based on capacity:
  - Dev: 1000 req/min
  - Staging: 5000 req/min
  - Production: 10000 req/min

• Implement caching at multiple levels:
  - CDN cache for static content
  - Redis cache for database queries
  - In-memory cache for hot data

• Monitor resource usage:
  - CPU utilization
  - Memory usage
  - Connection pool size
  - Response time percentiles

• Optimize connection pooling:
  - MaxIdleConns: 100
  - MaxIdleConnsPerHost: 10
  - IdleConnTimeout: 90s
```

**❌ DON'T**:
```
• NEVER set timeout too high (>120s)
• NEVER create new connection per request
• NEVER ignore caching opportunities
• NEVER forget to close connections
```

### 10.4 Reliability

**✅ DO**:
```
• Implement health checks:
  - Liveness: Is service alive?
  - Readiness: Is service ready to serve?
  - Startup: Has service started?

• Circuit breaker pattern:
  - Detect failing services
  - Stop sending requests to them
  - Periodically retry
  - Recover when healthy

• Graceful degradation:
  - Continue with reduced functionality
  - Return cached data if possible
  - Show user-friendly error messages

• Implement retries with exponential backoff:
  Attempt 1: 0s
  Attempt 2: 1s
  Attempt 3: 2s
  Attempt 4: 4s
  Attempt 5: 8s (give up)
```

**Circuit Breaker Implementation**:
```go
type CircuitBreaker struct {
    maxFailures   int
    resetTimeout  time.Duration
    failures      int
    lastFailTime  time.Time
    state         string  // CLOSED, OPEN, HALF_OPEN
}

func (cb *CircuitBreaker) Call(fn func() error) error {
    if cb.state == "OPEN" {
        if time.Since(cb.lastFailTime) > cb.resetTimeout {
            cb.state = "HALF_OPEN"
        } else {
            return errors.New("circuit breaker open")
        }
    }
    
    err := fn()
    if err != nil {
        cb.failures++
        cb.lastFailTime = time.Now()
        
        if cb.failures >= cb.maxFailures {
            cb.state = "OPEN"
        }
        return err
    }
    
    // Success - reset
    cb.failures = 0
    cb.state = "CLOSED"
    return nil
}
```

### 10.5 Monitoring

**✅ DO**:
```
• Aggregate logs to central system:
  - ELK Stack (Elasticsearch, Logstash, Kibana)
  - Splunk
  - CloudWatch Logs

• Set up alerts for critical metrics:
  - Error rate > 1%
  - Response time P99 > 1s
  - CPU usage > 80%
  - Memory usage > 90%
  - Service down

• Analyze traffic patterns:
  - Peak hours
  - Geographic distribution
  - User behavior
  - Bot vs human traffic

• Track business metrics:
  - Campaign creations
  - Impression recordings
  - Payment transactions
  - Active users
```

**Sample Alert Rules** (Prometheus):
```yaml
groups:
  - name: gateway_alerts
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m]) 
          / 
          rate(http_requests_total[5m]) 
          > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}%"
      
      # High latency
      - alert: HighLatency
        expr: |
          histogram_quantile(0.99, 
            rate(http_request_duration_seconds_bucket[5m])
          ) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P99 latency is {{ $value }}s"
      
      # Service down
      - alert: ServiceDown
        expr: up{job="gateway"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Gateway is down"
          description: "Gateway {{ $labels.instance }} is down"
```

---

## 📚 References

### Related Documentation

| Document | Description |
|----------|-------------|
| [Terminology Dictionary](./00-terminology-dictionary.md) | Explains all technical terms |
| [Project Overview](./01-project-overview.md) | Product Requirements Document |
| [Campaign Rules](./04-campaign-rules.md) | Campaign API endpoints |
| [Device Rules](./05-device-rules.md) | Device API endpoints |
| [Content Rules](./10-content-rules.md) | Content API endpoints |

---

**Version**: 1.0  
**Last Updated**: 2026-01-23  
**Owner**: Technical Architecture Team  
**Status**: Ready for review

**Next Steps**:
1. Review with architecture team
2. Security audit
3. Performance testing
4. Production deployment planning
