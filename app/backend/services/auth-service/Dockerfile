# Build stage
FROM golang:1.23-bookworm AS builder

WORKDIR /app

# Use secret mount instead of ARG for token
RUN --mount=type=secret,id=read_repo_user,target=/run/secrets/READ_REPO_USER \
    --mount=type=secret,id=read_repo_token,target=/run/secrets/READ_REPO_TOKEN \
    \
    READ_REPO_USER=$(cat /run/secrets/READ_REPO_USER) && \
    READ_REPO_TOKEN=$(cat /run/secrets/READ_REPO_TOKEN) && \
    \
    git config --global \
      url."https://${READ_REPO_USER}:${READ_REPO_TOKEN}@gitea.solu-m.io".insteadOf \
      "https://gitea.solu-m.io" && \
    \
    go env -w GOPRIVATE=gitea.solu-m.io/*

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy source files
COPY . .

# Build the Go binary
RUN go build -o /app/build/bin/main ./main.go

# Final stage
FROM debian:bookworm-slim
# Install CA certs in final image
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Copy the built binary
COPY --from=builder /app/build/bin/main main

# Expose the app port
EXPOSE 8011

# Run the binary
CMD ["/app/main"]
