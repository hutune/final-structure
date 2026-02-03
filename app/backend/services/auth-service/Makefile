.PHONY: run build swag

# Generate swagger docs
build-swag:
	swag init --parseDependency --parseInternal -g main.go -o ./docs

# Run with swagger generation
run: swag
	go run main.go

# Build with swagger generation
build: swag
	go build -o bin/app main.go 

deps:
	go mod tidy