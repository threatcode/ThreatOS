.PHONY: help help-all dev build test clean shell format lint \
        deps deps-update logs restart stop status format-check typecheck security \
        docs serve-docs test-unit test-integration test-coverage \
        build-deps build-clean build-all env doctor

# Default target
help:
	@echo "ThreatOS Development Environment"
	@echo "==================================="
	@echo "Basic Commands:"
	@echo "  make dev           - Start development environment"
	@echo "  make build         - Build ThreatOS ISO"
	@echo "  make test          - Run all tests"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make shell         - Open shell in development container"
	@echo "  make format        - Format code"
	@echo "  make lint          - Lint code"
	@echo ""
	@echo "Run 'make help-all' for all available commands"

# Extended help
help-all: check-docker
	@echo "ThreatOS Development Environment - All Commands"
	@echo "============================================="
	@echo "Dependency Management:"
	@echo "  make deps           - Install build dependencies"
	@echo "  make deps-update    - Update dependencies"
	@echo ""
	@echo "Development Tools:"
	@echo "  make logs           - View container logs"
	@echo "  make restart        - Restart containers"
	@echo "  make stop           - Stop containers"
	@echo "  make status         - Check container status"
	@echo ""
	@echo "Code Quality:"
	@echo "  make format-check   - Check formatting without making changes"
	@echo "  make typecheck      - Run static type checking"
	@echo "  make security       - Run security checks"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs           - Generate documentation"
	@echo "  make serve-docs     - Serve documentation locally"
	@echo ""
	@echo "Testing:"
	@echo "  make test-unit      - Run unit tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-coverage  - Generate test coverage report"
	@echo ""
	@echo "Build System:"
	@echo "  make build-deps     - Build container images"
	@echo "  make build-clean    - Clean build artifacts"
	@echo "  make build-all      - Clean and rebuild everything"
	@echo ""
	@echo "Utility:"
	@echo "  make env            - Show environment information"
	@echo "  make doctor         - Diagnose common issues"

# Check if Docker is installed and running
check-docker:
	@if ! command -v docker &> /dev/null; then \
		echo "[!] Docker is not installed. Please install Docker first: https://docs.docker.com/get-docker/"; \
		exit 1; \
	fi
	@if ! docker info &> /dev/null; then \
		echo "[!] Docker daemon is not running. Please start Docker and try again."; \
		exit 1; \
	fi

# Development environment
dev: check-docker
	@echo "[+] Starting development environment..."
	@docker compose up -d

# Build targets
build: check-docker dev
	@echo "[+] Building ThreatOS..."
	@docker compose exec -T dev ./build-threatos.sh

build-deps: check-docker
	@echo "[+] Building container images..."
	@docker compose build

build-clean: check-docker
	@echo "[+] Cleaning build artifacts..."
	@docker compose run --rm dev make clean

build-all: check-docker build-clean build-deps build

# Container management
logs: check-docker
	@docker compose logs -f

restart: check-docker
	@docker compose restart

stop: check-docker
	@docker compose down

status: check-docker
	@docker compose ps

# Code quality
format: check-docker
	@echo "[+] Formatting code..."
	@docker compose exec -T dev find . -name '*.sh' -exec sh -c 'shfmt -w {}' \;

format-check: check-docker
	@echo "[+] Checking code formatting..."
	@docker compose exec -T dev find . -name '*.sh' -exec sh -c 'shfmt -d {}' \;

lint: check-docker
	@echo "[+] Linting code..."
	@docker compose exec -T dev find . -name '*.sh' -exec shellcheck {} \;

typecheck: check-docker
	@echo "[+] Running static type checking..."
	@docker compose exec -T dev mypy .

security: check-docker
	@echo "[+] Running security checks..."
	@docker compose exec -T dev bandit -r .

# Testing
test: test-unit test-integration

test-unit: check-docker
	@echo "[+] Running unit tests..."
	@docker compose exec -T dev python -m pytest tests/unit

test-integration: check-docker
	@echo "[+] Running integration tests..."
	@docker compose exec -T dev python -m pytest tests/integration

test-coverage: check-docker
	@echo "[+] Generating test coverage report..."
	@docker compose exec -T dev python -m pytest --cov=. --cov-report=html tests/

# Documentation
docs: check-docker
	@echo "[+] Generating documentation..."
	@docker compose exec -T dev mkdocs build

serve-docs: check-docker
	@echo "[+] Serving documentation at http://localhost:8000"
	@docker compose exec -T dev mkdocs serve -a 0.0.0.0:8000

# Dependencies
deps: check-docker
	@echo "[+] Installing build dependencies..."
	@docker compose exec -T dev apt-get update && \
	 docker compose exec -T dev apt-get install -y $(shell cat requirements.txt)

deps-update: check-docker
	@echo "[+] Updating dependencies..."
	@docker compose exec -T dev pip install --upgrade -r requirements.txt

# Utility
env: check-docker
	@echo "[+] Environment Information:"
	@echo "Docker Version:"
	@docker --version
	@echo "\nDocker Compose Version:"
	@docker compose version
	@echo "\nContainers:"
	@docker ps -a
	@echo "\nImages:"
	@docker images

doctor: check-docker
	@echo "[+] Running diagnostics..."
	@echo "✓ Docker is running"
	@echo "✓ Docker Compose is available"
	@echo "✓ All required containers are built"
	@docker compose ps | grep -q "Up" && echo "✓ All services are running" || echo "✗ Some services are not running"

# Cleanup
clean: check-docker
	@echo "[+] Cleaning up..."
	@docker compose down -v
	@docker system prune -f
	@sudo rm -rf iso-artifacts/ installer-artifacts/ binary/ chroot/ config/ .build/ .pytest_cache/ .mypy_cache/ htmlcov/
