# Local Development

### 1. Set up database (PostgreSQL)

```bash
docker run -d \
  --name boilerplate-mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=boilerplate \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=password \
  -p 10201:3306 \
  mysql:latest

```

### 2. Set up cache (Redis)

```bash
docker run \
--name boilerplate-redis \
-p 10202:6379 \
-d redis
```

### 3. Set up File Storage (MinIO)

```bash
docker run \
--name boilerplate-minio \
-p 9000:9000 \
-p 9001:9001 \
-e "MINIO_ROOT_USER=user" \
-e "MINIO_ROOT_PASSWORD=password" \
-d \
minio/minio server /data --console-address ":9001"
```

### 3. Run the application

**3.1. Set environment**

```bash
export APP_ENV="development"
```

**3.2. Run the application**

```bash
go run cmd/main.go
```

# Project Structure

- **`cmd/`**: Contains command-line tools for the application.
  - **`main.go`**: The main entry point for starting the application.

- **`config/`**: Holds configuration files and utilities for environment-specific settings.

- **`internal/`**: Core application code not intended for external use.
  - **`api/`**: API-related code, including request handlers and routing.
  - **`app/`**: Application logic, including server setup and initialization.
  - **`common/`**: Shared utilities and components.
  - **`models/`**: Data models corresponding to database schemas.
  - **`repositories/`**: Data access logic, such as database queries.
  - **`services/`**: Business logic and services interacting with repositories.

- **`migrations/`**: Contains SQL files to migrate.

- **`pkg/`**: Reusable components or libraries intended for use by other projects.

- **`go.mod` and `go.sum`**: Dependency management files specifying required modules and their versions.


# How to add/update models
### I. Add a new model
1. Create a new model file in `internal/models`
2. Define model
3. Add a new migration
```
goose create <migration-name> sql
```
4. Define up and down SQL
5. Migrate
```
goose -dir migrations mysql "user:password@/dbname?parseTime=true" up
```

### II. Update a model
1. Update model
2. Add a new migration
```
goose create <migration-name> sql
```
3. Define up and down SQL
4. Migrate
```
goose -dir migrations mysql "user:password@/dbname?parseTime=true" up
```

**Note**
- If you want to rollback
```
goose -dir migrations mysql "user:password@/dbname?parseTime=true" down
```


### III. Generate API docs

1. Set up environment
```
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

2. Install Go Swag
```
go get -u github.com/swaggo/swag/cmd/swag@latest
```

3. Generate docs
```
swag init --parseDependency --parseInternal -g main.go
```
