.PHONY: help setup dev dev-backend dev-frontend test lint format docker-up docker-down clean

help:
	@echo "Code Mentor AI - Development Commands"
	@echo "====================================="
	@echo "make setup          - Initial project setup"
	@echo "make dev            - Start all services (Docker)"
	@echo "make dev-backend    - Start backend only"
	@echo "make dev-frontend   - Start frontend only"
	@echo "make test           - Run all tests"
	@echo "make test-backend   - Run backend tests"
	@echo "make test-frontend  - Run frontend tests"
	@echo "make lint           - Lint code"
	@echo "make format         - Format code"
	@echo "make docker-up      - Start Docker services"
	@echo "make docker-down    - Stop Docker services"
	@echo "make clean          - Clean build artifacts"

setup:
	@echo "Setting up Code Mentor AI..."
	cp .env.example .env
	cd backend && python -m venv .venv
	cd frontend && npm install
	@echo "Setup complete! Update .env and run 'make dev'"

dev:
	docker-compose up --build

dev-backend:
	cd backend && \
	source .venv/bin/activate 2>/dev/null || .venv\Scripts\activate && \
	uvicorn main:app --reload --port 8000

dev-frontend:
	cd frontend && npm run dev

test:
	cd backend && pytest --cov && \
	cd ../frontend && npm run test:coverage

test-backend:
	cd backend && pytest --cov

test-frontend:
	cd frontend && npm run test:coverage

lint:
	cd backend && flake8 . && mypy . && \
	cd ../frontend && npm run lint

format:
	cd backend && black . && \
	cd ../frontend && npm run format

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

clean:
	rm -rf backend/.venv backend/__pycache__ backend/.pytest_cache backend/htmlcov
	rm -rf frontend/node_modules frontend/dist frontend/.vite
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.py[cod]" -delete
