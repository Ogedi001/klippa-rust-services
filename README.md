# 🦀 Klippa Rust Microservices Platform

A high-performance, type-safe microservices platform built in Rust, powering Klippa's core booking, payment, and real-time communication services.

> **Part of the Klippa SaaS Ecosystem** – This workspace contains Rust-based services that handle performance-critical operations alongside our TypeScript/Node.js and Go services.


## 🏗️ Architecture Overview

This repository follows a **monorepo workspace pattern** where each service and library is an independent Cargo package managed under a unified build, test, and deployment system.

### 🎯 Core Services

| Service          | Purpose                                           | Key Technologies       |
| ---------------- | ------------------------------------------------- | ---------------------- |
| **`booking`**    | Real-time booking engine with conflict resolution | Axum, SQLx, Redis      |
| **`payment`**    | Secure payment processing & wallet management     | Tonic gRPC, Stripe API |
| **`file-media`** | File storage, image processing & CDN integration  | AWS S3, ImageMagick    |
| **`audit`**      | Immutable audit logs & compliance tracking        | Kafka, PostgreSQL      |
| **`chat`**       | Real-time messaging & WebSocket communication     | Warp, Redis Pub/Sub    |

### 📚 Shared Libraries

| Library         | Purpose                                       |
| --------------- | --------------------------------------------- |
| **`common`**    | Shared types, utilities, and helpers          |
| **`db`**        | Database connections, pooling, and migrations |
| **`config`**    | Environment configuration management          |
| **`telemetry`** | Logging, metrics, and distributed tracing     |
| **`messaging`** | Event-driven communication abstractions       |
| **`domain`**    | Shared domain models and business logic       |
| **`error`**     | Unified error handling framework              |


## 🚀 Quick Start

### Prerequisites

- 🦀 **Rust 1.81+** (managed via `rust-toolchain.toml`)
- 🐋 **Docker & Docker Compose** (for dependencies)
- 🧩 **Make** (for development workflows)

### Development Setup

```bash
# 1. Clone and setup
git clone <repository>
cd klippa-rust

# 2. Install Rust toolchain (automatically managed)
rustup show

# 3. Start development environment
make dev
```
````

This will:

- Start all dependencies (PostgreSQL, Redis, Kafka)
- Build all services and libraries
- Launch the development environment

---

## 📁 Project Structure

```
klippa-rust/
├── 🏠 Root Configuration
│   ├── Cargo.toml              # Workspace manifest
│   ├── rust-toolchain.toml     # Pinned Rust version
│   ├── Makefile                # Development commands
│   └── .cargo/config.toml      # Build configuration
│
├── 🔧 Services (Independent Microservices)
│   ├── booking/                # Booking engine
│   ├── payment/                # Payment processing
│   ├── file-media/             # File handling
│   ├── audit/                  # Audit trails
│   └── chat/                   # Real-time chat
│
├── 📚 Shared Libraries
│   ├── common/                 # Utilities & helpers
│   ├── db/                     # Database layer
│   ├── config/                 # Configuration
│   ├── telemetry/              # Observability
│   ├── messaging/              # Event bus
│   ├── domain/                 # Domain models
│   └── error/                  # Error handling
│
├── 🚀 Operations
│   ├── docker-compose.yml      # Local dependencies
│   ├── prometheus/             # Metrics collection
│   ├── grafana/                # Monitoring dashboards
│   └── k8s/                    # Production deployment
│
├── 📡 API Contracts
│   ├── *.proto                 # gRPC service definitions
│   └── build.rs                # Code generation
│
├── 📖 Documentation
│   ├── adr/                    # Architecture decisions
│   ├── api/                    # API documentation
│   └── runbooks/               # Operational procedures
│
└── 🧪 Testing
    ├── contract/               # Service contract tests
    ├── e2e/                    # End-to-end tests
    ├── performance/            # Load testing
    └── smoke/                  # Health checks
```

---

## ⚙️ Configuration Management

### Environment Configuration

Services are configured using a hierarchical system:

```
config/
├── base.yaml              # Common settings across all environments
├── development.yaml       # Local development overrides
├── production.yaml        # Production environment settings
└── .env                   # Local secrets (gitignored)
```

### Configuration Priority (Highest to Lowest):

1. **Environment variables** (e.g., `DATABASE_URL`, `REDIS_PASSWORD`)
2. **Environment-specific config files** (`development.yaml`, `production.yaml`)
3. **Base configuration** (`base.yaml`)

### Setup for Development:

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env with your local values
# .env
DATABASE_URL=postgres://user:pass@localhost:5432/klippa_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret_here

# 3. Start services - config is automatically loaded
make run-booking
```

### Using Configuration in Services:

```rust
use config::AppConfig;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Configuration is automatically loaded
    let config = AppConfig::new()?;

    println!("Starting on port: {}", config.port);
    println!("Database: {}", config.database_url());

    // Your service logic here
    Ok(())
}
```

---

## 🛠️ Development Workflow

### Common Tasks

```bash
# Build everything
make build

# Run tests
make test

# Start specific service
make run-booking
make run-payment
make run-file-media
make run-audit
make run-chat

# Code quality checks
make fmt          # Format code
make clippy       # Lint code
make quality      # Run all quality checks

# Clean up
make clean        # Remove build artifacts
make nuke         # Reset everything including dependencies
```

### Service Development

```bash
# Work on a specific service
cargo check -p booking
cargo test -p payment
cargo run -p chat

# Add dependencies to workspace
# Edit [workspace.dependencies] in root Cargo.toml
# Then in service: cargo add tokio --workspace
```

### Database Operations

```bash
# Start dependencies (PostgreSQL, Redis, Kafka)
make deps

# Run migrations
make migrate
```

---

## 🔍 Observability & Monitoring

### Local Development

```bash
# Start monitoring stack
docker-compose -f ops/docker-compose.yml up prometheus grafana

# Access dashboards
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3000
```

### Metrics & Logging

All services automatically:

- Export Prometheus metrics at `/metrics`
- Output structured JSON logs
- Support distributed tracing with OpenTelemetry
- Include health checks at `/health`

---

## 🐳 Deployment

### Local Development

```bash
# Full local setup
make dev

# Or step by step
make deps        # Start dependencies
make build       # Build services
make run-all     # Start all services
```

### Production Build

```bash
# Build optimized binaries
make build-release

# Build Docker images
docker build -f ops/Dockerfile.booking -t klippa/booking:latest .

# Deploy to Kubernetes
kubectl apply -f ops/k8s/
```

---

## 🧪 Testing Strategy

| Test Type             | Location             | Purpose                      |
| --------------------- | -------------------- | ---------------------------- |
| **Unit Tests**        | `services/*/src/`    | Individual function testing  |
| **Integration Tests** | `services/*/tests/`  | Service + dependencies       |
| **Contract Tests**    | `tests/contract/`    | Service API compatibility    |
| **End-to-End Tests**  | `tests/e2e/`         | Full user journey validation |
| **Performance Tests** | `tests/performance/` | Load and stress testing      |
| **Benchmarks**        | `benches/`           | Code-level performance       |

Run all tests: `make test`

---

## 🛡️ Security & Compliance

### Security Features

- **Memory Safety**: All crates use `#![forbid(unsafe_code)]`
- **Dependency Scanning**: Regular `cargo audit` runs
- **Secure Defaults**: All services follow security best practices
- **Compliance**: NDPR/GDPR compliant audit trails
- **Secrets Management**: Environment variables for sensitive data

### Security Scanning

```bash
# Audit dependencies
cargo audit

# Check for vulnerable dependencies
cargo deny check advisories

# Security-focused linting
cargo clippy -- -D security
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow in `.github/workflows/` provides:

- **Continuous Integration**:

  - Format checking (`cargo fmt --check`)
  - Linting (`cargo clippy`)
  - Unit and integration tests
  - Security scanning (`cargo audit`)

- **Continuous Deployment**:
  - Docker image building and publishing
  - Kubernetes deployment manifests
  - Environment-specific configurations

---

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. **Fork & Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Develop & Test**

   ```bash
   make quality  # Run all quality checks
   make test     # Ensure all tests pass
   ```

3. **Submit PR**
   - Ensure CI passes
   - Update documentation as needed
   - Follow conventional commits

### Code Standards

- **Formatting**: `cargo fmt` before committing
- **Linting**: No `cargo clippy` warnings
- **Testing**: Maintain high test coverage
- **Documentation**: Update relevant README files

---

## 📚 Documentation

| Resource                   | Purpose                       | Location               |
| -------------------------- | ----------------------------- | ---------------------- |
| **Service Documentation**  | Service-specific setup & APIs | `services/*/README.md` |
| **Architecture Decisions** | Technical decision records    | `docs/adr/`            |
| **API Reference**          | Service API documentation     | `docs/api/`            |
| **Runbooks**               | Operational procedures        | `docs/runbooks/`       |
| **Development Guide**      | Development workflow          | `docs/development.md`  |

---

## 🏢 Related Projects

| Repository                | Language   | Purpose                          |
| ------------------------- | ---------- | -------------------------------- |
| **`klippa-ts-services`**  | TypeScript | Auth, CRM, Notification services |
| **`klippa-business-ops`** | TypeScript | Business logic & integrations    |
| **`klippa-infra`**        | YAML/Helm  | Kubernetes infrastructure        |

---

## 📄 License

© 2024 Klippa Inc. – Proprietary and confidential. All rights reserved.

_For internal use only._

---

> 🦀 **Built with Rust for safety, performance, and reliability at scale.**
>
> _"If it compiles, it works."_

```

```
