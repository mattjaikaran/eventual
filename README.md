# Task Management API

A FastAPI-based task management system with PostgreSQL backend, designed for scalability and ease of use.

I've created several scripts and make commands to help you see everything in action pretty easily.

- **make dev** - to run server
- **make seed** - to create sample data
- **make test** - run tests
- **make demo-full-workflow** - will perform all the crud tasks

## Quick Start

```bash
make setup && make run
```

This will:

- Install all dependencies
- Set up PostgreSQL databases
- Create sample data
- Start the API server

**Then visit:** http://localhost:8000/docs for interactive API documentation

## Available Commands

```bash
make help          # Show all available commands
make setup         # Complete setup (dependencies, databases, seed data)
make run           # Start the API server
make dev           # Start with auto-reload (development mode)
make test          # Run all tests
make clean         # Clean up generated files
make fresh         # Fresh start (reset everything)
```

## Prerequisites

- **PostgreSQL** - Make sure it's running

  ```bash
  # macOS
  brew services start postgresql

  # Linux
  sudo systemctl start postgresql
  ```

- **uv** - Python package manager (auto-installs if missing)
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

## Features

- **User Management** - Full CRUD operations for users
- **Task Management** - Create, update, delete, and track tasks
- **Status Tracking** - Pending, In Progress, Done
- **Idempotency** - Prevent duplicate task creation
- **Advanced Filtering** - Filter by status, user, due date
- **Async Operations** - database operations
- **Auto Documentation** - Interactive API docs with Swagger UI
- **Comprehensive Tests** - Full test suite with PostgreSQL

## Tech Stack

- **FastAPI** - web framework for APIs
- **PostgreSQL** - relational database
- **SQLAlchemy** - ORM for database operations
- **Pydantic** - Data validation and serialization
- **pytest** - Testing framework with async support
- **uvicorn** - ASGI server

## Sample Data

The setup automatically creates sample users and tasks:

- **5 Users** (Alice, Bob, Carol, David, Eva)
- **12 Tasks** with various statuses and due dates
- **Realistic scenarios** for testing and demonstration

## API Endpoints

| Method | Endpoint                    | Description                 |
| ------ | --------------------------- | --------------------------- |
| GET    | `/api/users/`               | List all users              |
| POST   | `/api/users/`               | Create a new user           |
| GET    | `/api/users/{id}`           | Get user by ID              |
| PUT    | `/api/users/{id}`           | Update user                 |
| DELETE | `/api/users/{id}`           | Delete user                 |
| GET    | `/api/tasks/`               | List tasks (with filters)   |
| POST   | `/api/tasks/`               | Create a new task           |
| GET    | `/api/tasks/{id}`           | Get task by ID              |
| PUT    | `/api/tasks/{id}`           | Update task                 |
| DELETE | `/api/tasks/{id}`           | Delete task                 |
| GET    | `/api/tasks/summary/`       | Get task status summary     |
| GET    | `/api/tasks/user/{user_id}` | Get tasks for specific user |

## Development

```bash
make dev           # Start with auto-reload
make test          # Run tests
make test-watch    # Run tests with file watching
make lint          # Check code style
make format        # Format code
make check         # Run linting + tests
```

## Project Structure

```
eventual_backend/
├── api/           # API dependencies
├── core/          # Core configuration and database
├── models/        # SQLAlchemy models
├── repositories/  # Data access layer
├── routers/       # FastAPI route handlers
├── schemas/       # Pydantic schemas
├── services/      # Business logic
└── tests/         # Test suite
```

## Explore

1. **Start the API:** `make run`
2. **Interactive Docs:** http://localhost:8000/docs
3. **Alternative Docs:** http://localhost:8000/redoc
4. **Health Check:** http://localhost:8000/health
