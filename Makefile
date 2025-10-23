# Task Management API - Makefile
# Simple commands to set up and run the application

.PHONY: help install setup seed test run clean dev check-deps check-postgres \
	check-server demo-users-list demo-user-create demo-user-get-first demo-user-update-first \
	demo-user-delete-first demo-user-get-demo demo-tasks-list demo-task-create-for-first-user \
	demo-task-get-first demo-task-update-first demo-task-delete-first demo-tasks-filter-pending \
	demo-tasks-filter-user demo-tasks-paginated demo-tasks-ordered demo-user-tasks \
	demo-tasks-summary demo-task-idempotency demo-full-workflow demo-interactive-workflow \
	demo-crud-showcase demo-api-docs demo-help test-assignment-requirements

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

help: ## Show this help message
	@echo "$(BLUE)Task Management API - Available Commands$(RESET)"
	@echo "========================================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(RESET)"
	@echo "  make setup    # Complete setup (databases, dependencies, seed data)"
	@echo "  make run      # Start the API server"
	@echo ""

check-deps: ## Check if required dependencies are installed
	@echo "$(BLUE)Checking dependencies...$(RESET)"
	@command -v uv >/dev/null 2>&1 || { echo "$(RED)Error: uv is not installed. Install with: curl -LsSf https://astral.sh/uv/install.sh | sh$(RESET)"; exit 1; }
	@echo "$(GREEN)uv is installed$(RESET)"

check-postgres: ## Check if PostgreSQL is running
	@echo "$(BLUE)Checking PostgreSQL...$(RESET)"
	@pgrep -x postgres >/dev/null 2>&1 || { echo "$(RED)Error: PostgreSQL is not running. Start with: brew services start postgresql$(RESET)"; exit 1; }
	@echo "$(GREEN)PostgreSQL is running$(RESET)"

install: check-deps ## Install dependencies
	@echo "$(BLUE)Installing dependencies...$(RESET)"
	uv sync --dev
	@echo "$(GREEN)Dependencies installed$(RESET)"

db-setup: check-postgres ## Set up databases
	@echo "$(BLUE)Setting up databases...$(RESET)"
	@createdb taskdb 2>/dev/null || echo "$(YELLOW)Database 'taskdb' already exists$(RESET)"
	@createdb test_taskdb 2>/dev/null || echo "$(YELLOW)Database 'test_taskdb' already exists$(RESET)"
	@echo "$(GREEN)Databases ready$(RESET)"

seed: install db-setup ## Create seed data
	@echo "$(BLUE)Creating seed data...$(RESET)"
	uv run python seed_data.py
	@echo "$(GREEN)Seed data created$(RESET)"

setup: install db-setup seed ## Complete setup (dependencies, databases, seed data)
	@echo ""
	@echo "$(GREEN)Setup complete!$(RESET)"
	@echo ""
	@echo "$(YELLOW)Ready to go! Try these commands:$(RESET)"
	@echo "  make run      # Start the API server"
	@echo "  make test     # Run tests"
	@echo "  make dev      # Start with auto-reload"
	@echo ""

run: install ## Start the API server
	@echo "$(BLUE)Starting Task Management API...$(RESET)"
	@echo "$(GREEN)Server: http://localhost:8000$(RESET)"
	@echo "$(GREEN)API Docs: http://localhost:8000/docs$(RESET)"
	@echo "$(GREEN)ReDoc: http://localhost:8000/redoc$(RESET)"
	@echo ""
	@echo "$(YELLOW)Press Ctrl+C to stop$(RESET)"
	@echo ""
	uv run uvicorn eventual_backend.main:app --host 0.0.0.0 --port 8000

dev: install ## Start with auto-reload (development mode)
	@echo "$(BLUE)Starting in development mode...$(RESET)"
	@echo "$(GREEN)Server: http://localhost:8000$(RESET)"
	@echo "$(GREEN)API Docs: http://localhost:8000/docs$(RESET)"
	@echo "$(GREEN)Auto-reload enabled$(RESET)"
	@echo ""
	@echo "$(YELLOW)Press Ctrl+C to stop$(RESET)"
	@echo ""
	uv run uvicorn eventual_backend.main:app --host 0.0.0.0 --port 8000 --reload

test: install db-setup ## Run all tests
	@echo "$(BLUE)Running tests...$(RESET)"
	uv run pytest eventual_backend/tests/ -v --tb=short
	@echo "$(GREEN)Tests completed$(RESET)"

test-watch: install db-setup ## Run tests with file watching
	@echo "$(BLUE)Running tests with file watching...$(RESET)"
	@echo "$(YELLOW)Tests will re-run when files change. Press Ctrl+C to stop.$(RESET)"
	uv run pytest eventual_backend/tests/ -v --tb=short -f

lint: install ## Run code linting
	@echo "$(BLUE)Running linter...$(RESET)"
	uv run ruff check eventual_backend/
	@echo "$(GREEN)Linting completed$(RESET)"

format: install ## Format code
	@echo "$(BLUE)Formatting code...$(RESET)"
	uv run ruff format eventual_backend/
	@echo "$(GREEN)Code formatted$(RESET)"

check: lint test ## Run linting and tests
	@echo "$(GREEN)All checks passed$(RESET)"

clean: ## Clean up generated files and caches
	@echo "$(BLUE)Cleaning up...$(RESET)"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name ".coverage" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -f test.db 2>/dev/null || true
	rm -f debug_test.py 2>/dev/null || true
	@echo "$(GREEN)Cleanup completed$(RESET)"

reset-db: db-setup ## Reset databases (drop and recreate)
	@echo "$(BLUE)Resetting databases...$(RESET)"
	@dropdb taskdb 2>/dev/null || true
	@dropdb test_taskdb 2>/dev/null || true
	@createdb taskdb
	@createdb test_taskdb
	@echo "$(GREEN)Databases reset$(RESET)"

fresh: clean reset-db seed ## Fresh start (clean, reset DB, seed data)
	@echo "$(GREEN)Fresh environment ready!$(RESET)"

demo: setup run ## Complete demo setup and start server

# Development helpers
shell: install ## Open a shell with the virtual environment activated
	@echo "$(BLUE)Opening shell with virtual environment...$(RESET)"
	uv run python

deps-update: ## Update dependencies
	@echo "$(BLUE)Updating dependencies...$(RESET)"
	uv sync --upgrade
	@echo "$(GREEN)Dependencies updated$(RESET)"

info: ## Show project information
	@echo "$(BLUE)Task Management API$(RESET)"
	@echo "==================="
	@echo ""
	@echo "$(GREEN)Project Structure:$(RESET)"
	@echo "  eventual_backend/     # Main application code"
	@echo "  eventual_backend/tests/  # Test suite"
	@echo "  seed_data.py         # Database seeding script"
	@echo "  Makefile            # This file"
	@echo ""
	@echo "$(GREEN)Key Features:$(RESET)"
	@echo "  • FastAPI web framework"
	@echo "  • PostgreSQL database"
	@echo "  • Async SQLAlchemy ORM"
	@echo "  • Pydantic data validation"
	@echo "  • Comprehensive test suite"
	@echo "  • Auto-generated API documentation"
	@echo ""

# =============================================================================
# CRUD DEMONSTRATION COMMANDS
# =============================================================================

# Variables for demo
API_BASE := http://localhost:8000
DEMO_USER_EMAIL := demo-user@example.com
DEMO_USER_NAME := Demo User
DEMO_USER_PHONE := +1-555-DEMO

# Check if server is running
check-server: ## Check if the API server is running
	@echo "$(BLUE)Checking if API server is running...$(RESET)"
	@curl -s -f http://localhost:8000/health > /dev/null 2>&1 || { echo "$(RED)Error: API server is not running. Start with: make run$(RESET)"; exit 1; }
	@echo "$(GREEN)API server is running at http://localhost:8000$(RESET)"

# =============================================================================
# USER CRUD OPERATIONS
# =============================================================================

demo-users-list: check-server ## List all users
	@./scripts/user_crud.sh list

demo-user-create: check-server ## Create a new demo user
	@./scripts/user_crud.sh create

demo-user-get-first: check-server ## Get the first user from the database
	@./scripts/user_crud.sh get-first

demo-user-update-first: check-server ## Update the first user in the database
	@./scripts/user_crud.sh update-first

demo-user-delete-first: check-server ## Delete the first user in the database
	@./scripts/user_crud.sh delete-first

demo-user-get-demo: check-server ## Get the demo user we created (if it exists)
	@./scripts/user_crud.sh get-demo

# =============================================================================
# TASK CRUD OPERATIONS
# =============================================================================

demo-tasks-list: check-server ## List all tasks
	@./scripts/task_crud.sh list

demo-task-create-for-first-user: check-server ## Create a new task for the first user in the database
	@./scripts/task_crud.sh create

demo-task-get-first: check-server ## Get the first task from the database
	@./scripts/task_crud.sh get-first

demo-task-update-first: check-server ## Update the first task in the database
	@./scripts/task_crud.sh update-first

demo-task-delete-first: check-server ## Delete the first task in the database
	@./scripts/task_crud.sh delete-first

# =============================================================================
# ADVANCED TASK OPERATIONS
# =============================================================================

demo-tasks-filter-pending: check-server ## List tasks filtered by pending status
	@./scripts/task_crud.sh filter-pending

demo-tasks-filter-user: check-server ## List tasks for the first user
	@./scripts/task_crud.sh filter-by-user

demo-tasks-paginated: check-server ## List tasks with pagination (limit=2, skip=0)
	@./scripts/task_crud.sh paginated

demo-tasks-ordered: check-server ## List tasks ordered by due date descending
	@./scripts/task_crud.sh ordered

demo-user-tasks: check-server ## Get all tasks for the first user
	@./scripts/task_crud.sh user-tasks

demo-tasks-summary: check-server ## Get task summary (counts by status)
	@./scripts/task_crud.sh summary

demo-task-idempotency: check-server ## Test idempotency by creating the same task twice
	@./scripts/task_crud.sh idempotency

# =============================================================================
# COMPREHENSIVE DEMO WORKFLOWS
# =============================================================================

demo-full-workflow: check-server ## Complete CRUD workflow demonstration
	@./scripts/demo_workflow.sh full

demo-interactive-workflow: check-server ## Interactive workflow with user and task operations
	@./scripts/demo_workflow.sh interactive

demo-crud-showcase: check-server ## CRUD operations showcase
	@./scripts/demo_workflow.sh crud

demo-api-docs: check-server ## Open API documentation in browser
	@echo "$(BLUE)📖 Opening API documentation...$(RESET)"
	@echo "$(GREEN)Swagger UI: http://localhost:8000/docs$(RESET)"
	@echo "$(GREEN)ReDoc: http://localhost:8000/redoc$(RESET)"
	@open http://localhost:8000/docs 2>/dev/null || echo "$(YELLOW)Visit http://localhost:8000/docs in your browser$(RESET)"

test-assignment-requirements: check-server ## Comprehensive test of all assignment requirements
	@./scripts/test_assignment_requirements.sh

demo-help: ## Show available demo commands
	@echo "$(BLUE)Task Management API - CRUD Demo Commands$(RESET)"
	@echo "=============================================="
	@echo ""
	@echo "$(GREEN)Prerequisites:$(RESET)"
	@echo "  make setup    # Set up the project"
	@echo "  make run      # Start the API server (in another terminal)"
	@echo ""
	@echo "$(GREEN)Quick Start Demo:$(RESET)"
	@echo "  make demo-full-workflow          # Complete demonstration"
	@echo "  make demo-interactive-workflow   # Interactive demo with detailed steps"
	@echo "  make demo-crud-showcase          # CRUD operations showcase"
	@echo ""
	@echo "$(GREEN)User CRUD Operations:$(RESET)"
	@echo "  make demo-users-list             # List all users"
	@echo "  make demo-user-create            # Create a demo user"
	@echo "  make demo-user-get-first         # Get first user"
	@echo "  make demo-user-update-first      # Update first user"
	@echo "  make demo-user-delete-first      # Delete first user"
	@echo "  make demo-user-get-demo          # Get demo user by email"
	@echo ""
	@echo "$(GREEN)Task CRUD Operations:$(RESET)"
	@echo "  make demo-tasks-list             # List all tasks"
	@echo "  make demo-task-create-for-first-user  # Create task for first user"
	@echo "  make demo-task-get-first         # Get first task"
	@echo "  make demo-task-update-first      # Update first task"
	@echo "  make demo-task-delete-first      # Delete first task"
	@echo ""
	@echo "$(GREEN)Advanced Features:$(RESET)"
	@echo "  make demo-tasks-filter-pending   # Filter tasks by pending status"
	@echo "  make demo-tasks-filter-user      # Filter tasks by first user"
	@echo "  make demo-tasks-paginated        # Pagination example"
	@echo "  make demo-tasks-ordered          # Ordering example"
	@echo "  make demo-user-tasks             # Get first user's tasks"
	@echo "  make demo-tasks-summary          # Task counts by status"
	@echo "  make demo-task-idempotency       # Test idempotency feature"
	@echo ""
	@echo "$(GREEN)Documentation:$(RESET)"
	@echo "  make demo-api-docs               # Open API documentation"
	@echo "  make check-server                # Check if server is running"
	@echo ""
	@echo "$(GREEN)Direct Script Usage:$(RESET)"
	@echo "  ./scripts/user_crud.sh {list|create|get-first|update-first|delete-first|get-demo}"
	@echo "  ./scripts/task_crud.sh {list|create|get-first|update-first|delete-first|...}"
	@echo "  ./scripts/demo_workflow.sh {full|interactive|crud}"
	@echo ""
	@echo "$(YELLOW)Example Usage:$(RESET)"
	@echo "  1. make demo-full-workflow"
	@echo "  2. make demo-interactive-workflow"
	@echo "  3. make demo-crud-showcase"
	@echo ""
