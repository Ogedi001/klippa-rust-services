# Makefile - Klippa Rust Microservices

# Configuration
CARGO := cargo
PROJECT := klippa-rust
SERVICES := booking payment file-media audit chat
LIBS := common db config telemetry messaging domain error

# Colors for pretty output
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

.PHONY: help build test fmt clippy clean dev deps docker

## Help - show available commands
help:
	@echo "$(GREEN)Klippa Rust Microservices$(NC)"
	@echo ""
	@echo "$(YELLOW)Development:$(NC)"
	@echo "  make dev       - Start development environment"
	@echo "  make deps      - Start dependencies (PostgreSQL, Redis, Kafka)"
	@echo "  make build     - Build all services and libraries"
	@echo "  make test      - Run all tests"
	@echo ""
	@echo "$(YELLOW)Code Quality:$(NC)"
	@echo "  make fmt       - Format all code"
	@echo "  make clippy    - Run clippy linter"
	@echo "  make check     - Quick compilation check"
	@echo ""
	@echo "$(YELLOW)Service Management:$(NC)"
	@echo "  make run-booking    - Run booking service"
	@echo "  make run-payment    - Run payment service"
	@echo "  make run-file-media - Run file media service"
	@echo "  make run-audit      - Run audit service"
	@echo "  make run-chat       - Run chat service"
	@echo "  make run-all        - Run all services"
	@echo ""
	@echo "$(YELLOW)Cleanup:$(NC)"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make nuke      - Clean everything including dependencies"

## Development
dev: deps build
	@echo "$(GREEN)🚀 Starting development environment...$(NC)"
	@make run-all

deps:
	@echo "$(GREEN)📦 Starting dependencies...$(NC)"
	docker-compose -f ops/docker-compose.yml up -d postgres redis kafka

## Building
build:
	@echo "$(GREEN)🔨 Building workspace...$(NC)"
	$(CARGO) build --workspace

build-release:
	@echo "$(GREEN)🔨 Building for release...$(NC)"
	$(CARGO) build --workspace --release

check:
	@echo "$(GREEN)✅ Checking code...$(NC)"
	$(CARGO) check --workspace

## Testing
test:
	@echo "$(GREEN)🧪 Running tests...$(NC)"
	$(CARGO) test --workspace

test-watch:
	@echo "$(GREEN)🧪 Running tests in watch mode...$(NC)"
	$(CARGO) watch -x test

## Code Quality
fmt:
	@echo "$(GREEN)🎨 Formatting code...$(NC)"
	$(CARGO) fmt --all

clippy:
	@echo "$(GREEN)🔍 Running clippy...$(NC)"
	$(CARGO) clippy --workspace -- -D warnings

audit:
	@echo "$(GREEN)🔒 Security audit...$(NC)"
	$(CARGO) audit

quality: fmt clippy test
	@echo "$(GREEN)✨ All quality checks passed!$(NC)"

## Service Management
run-booking:
	@echo "$(GREEN)🚀 Starting booking service...$(NC)"
	$(CARGO) run -p booking

run-payment:
	@echo "$(GREEN)🚀 Starting payment service...$(NC)"
	$(CARGO) run -p payment

run-file-media:
	@echo "$(GREEN)🚀 Starting file media service...$(NC)"
	$(CARGO) run -p file-media

run-audit:
	@echo "$(GREEN)🚀 Starting audit service...$(NC)"
	$(CARGO) run -p audit

run-chat:
	@echo "$(GREEN)🚀 Starting chat service...$(NC)"
	$(CARGO) run -p chat

run-all:
	@echo "$(GREEN)🚀 Starting all services...$(NC)"
	@for service in $(SERVICES); do \
		echo "Starting $$service..."; \
		$(CARGO) run -p $$service & \
	done
	@wait

## Database
migrate:
	@echo "$(GREEN)🗃️ Running migrations...$(NC)"
	@for service in $(SERVICES); do \
		if [ -f "services/$$service/migrations" ]; then \
			echo "Migrating $$service..."; \
			$(CARGO) run -p $$service -- migrate; \
		fi \
	done

## Cleanup
clean:
	@echo "$(GREEN)🧹 Cleaning build artifacts...$(NC)"
	$(CARGO) clean

nuke: clean
	@echo "$(GREEN)💥 Stopping and removing dependencies...$(NC)"
	docker-compose -f ops/docker-compose.yml down -v