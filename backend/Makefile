# Makefile for Expense Management Backend

# Variables
BINARY_NAME=expense_management_backend
BUILD_DIR=build
MAIN_FILE=cmd/main.go

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
BINARY_UNIX=$(BINARY_NAME)_unix

# Default target
all: clean build

# Build the application
build:
	$(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_FILE)

# Build for Linux
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(BINARY_UNIX) $(MAIN_FILE)

# Clean build artifacts
clean:
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)

# Run the application
run:
	$(GOCMD) run $(MAIN_FILE)

# Run with hot reload (requires air)
dev:
	air

# Install dependencies
deps:
	$(GOMOD) tidy
	$(GOMOD) download

# Run tests
test:
	$(GOTEST) ./...

# Run tests with coverage
test-coverage:
	$(GOTEST) -cover ./...

# Run tests with verbose output
test-verbose:
	$(GOTEST) -v ./...

# Run tests and generate coverage report
test-coverage-report:
	$(GOTEST) -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html

# Format code
fmt:
	$(GOCMD) fmt ./...

# Vet code
vet:
	$(GOCMD) vet ./...

# Lint code (requires golangci-lint)
lint:
	golangci-lint run

# Install development tools
install-tools:
	$(GOGET) -u github.com/cosmtrek/air
	$(GOGET) -u github.com/golangci/golangci-lint/cmd/golangci-lint

# Create database migration
migrate:
	$(GOCMD) run $(MAIN_FILE) migrate

# Setup development environment
setup: deps install-tools
	cp env.example .env
	@echo "Development environment setup complete!"
	@echo "Please edit .env file with your configuration."

# Docker commands
docker-build:
	docker build -t $(BINARY_NAME) .

docker-run:
	docker run -p 8080:8080 $(BINARY_NAME)

# Help
help:
	@echo "Available commands:"
	@echo "  build              - Build the application"
	@echo "  build-linux        - Build for Linux"
	@echo "  clean              - Clean build artifacts"
	@echo "  run                - Run the application"
	@echo "  dev                - Run with hot reload (requires air)"
	@echo "  deps               - Install dependencies"
	@echo "  test               - Run tests"
	@echo "  test-coverage      - Run tests with coverage"
	@echo "  test-verbose       - Run tests with verbose output"
	@echo "  fmt                - Format code"
	@echo "  vet                - Vet code"
	@echo "  lint               - Lint code (requires golangci-lint)"
	@echo "  install-tools      - Install development tools"
	@echo "  setup              - Setup development environment"
	@echo "  docker-build       - Build Docker image"
	@echo "  docker-run         - Run Docker container"
	@echo "  help               - Show this help message"

.PHONY: all build build-linux clean run dev deps test test-coverage test-verbose fmt vet lint install-tools setup docker-build docker-run help 