.PHONY: help dev-up dev-down prod-up prod-down build-dev build-prod logs-dev logs-prod test clean

help:
	@echo "Available commands:"
	@echo "  make dev-up        - Start development environment"
	@echo "  make dev-down      - Stop development environment"
	@echo "  make prod-up       - Start production environment"
	@echo "  make prod-down     - Stop production environment"
	@echo "  make build-dev     - Build development images"
	@echo "  make build-prod    - Build production images"
	@echo "  make logs-dev      - View development logs"
	@echo "  make logs-prod     - View production logs"
	@echo "  make test          - Run test suite"
	@echo "  make clean         - Remove all containers, volumes, and images"

dev-up:
	@if [ ! -f .env ]; then \
		echo "Copying .env.example to .env"; \
		cp .env.example .env; \
		cp .env.example docker/.env; \
	fi
	docker compose -f docker/compose.development.yaml up -d

dev-down:
	docker compose -f docker/compose.development.yaml down

prod-up:
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found. Create one from .env.example"; \
		exit 1; \
	fi
	docker compose -f docker/compose.production.yaml up -d --build

prod-down:
	docker compose -f docker/compose.production.yaml down

build-dev:
	docker compose -f docker/compose.development.yaml build

build-prod:
	docker compose -f docker/compose.production.yaml build

logs-dev:
	docker compose -f docker/compose.development.yaml logs -f

logs-prod:
	docker compose -f docker/compose.production.yaml logs -f

test:
	@echo "Testing gateway health..."
	@curl -f http://localhost:5921/health || echo "Gateway health check failed"
	@echo "\nTesting backend health via gateway..."
	@curl -f http://localhost:5921/api/health || echo "Backend health check failed"
	@echo "\nCreating a product..."
	@curl -X POST http://localhost:5921/api/products \
		-H 'Content-Type: application/json' \
		-d '{"name":"Test Product","price":99.99}' || echo "Product creation failed"
	@echo "\nGetting all products..."
	@curl -f http://localhost:5921/api/products || echo "Failed to get products"
	@echo "\nTesting backend direct access (should fail)..."
	@curl -s http://localhost:3847/api/products && echo "ERROR: Backend should not be directly accessible" || echo "Success: Backend is not directly accessible"

clean:
	docker compose -f docker/compose.development.yaml down -v
	docker compose -f docker/compose.production.yaml down -v
	docker system prune -f