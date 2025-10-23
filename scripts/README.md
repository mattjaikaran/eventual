# CRUD Demo Scripts

This directory contains scripts to demonstrate the CRUD functionality of the Task Management API.

## Scripts Overview

### `api_utils.py`

Python utility script with helper functions for API interactions:

- Server connectivity checking
- Dynamic UUID fetching
- HTTP request handling
- JSON pretty printing

**Usage:**

```bash
python3 api_utils.py check-server
python3 api_utils.py get-first-user-id
python3 api_utils.py get-first-task-id
python3 api_utils.py get-user-by-email demo-user@example.com
```

### `user_crud.sh`

Bash script for user CRUD operations:

- List all users
- Create demo user
- Get/update/delete first user
- Get demo user by email

**Usage:**

```bash
./user_crud.sh list
./user_crud.sh create
./user_crud.sh get-first
./user_crud.sh update-first
./user_crud.sh delete-first
./user_crud.sh get-demo
```

### `task_crud.sh`

Bash script for task CRUD operations and advanced features:

- Basic CRUD operations
- Filtering and pagination
- Task summary
- Idempotency testing

**Usage:**

```bash
./task_crud.sh list
./task_crud.sh create
./task_crud.sh get-first
./task_crud.sh update-first
./task_crud.sh delete-first
./task_crud.sh filter-pending
./task_crud.sh filter-by-user
./task_crud.sh paginated
./task_crud.sh ordered
./task_crud.sh user-tasks
./task_crud.sh summary
./task_crud.sh idempotency
```

### `demo_workflow.sh`

Comprehensive demo workflows that combine multiple operations:

- Full workflow demonstration
- Interactive workflow with detailed steps
- CRUD operations showcase

**Usage:**

```bash
./demo_workflow.sh full
./demo_workflow.sh interactive
./demo_workflow.sh crud
```

## Features Demonstrated

### ✅ **User Management**

- Create, read, update, delete users
- Email-based user lookup
- Input validation and error handling

### ✅ **Task Management**

- Create, read, update, delete tasks
- Task status management (pending, in_progress, done)
- Due date handling with automatic future dates

### ✅ **Advanced Features**

- **Filtering**: By status, user, etc.
- **Pagination**: Limit and offset support
- **Ordering**: By due date (ascending/descending)
- **Idempotency**: Duplicate prevention with idempotency keys
- **Summary**: Task counts by status
- **User Tasks**: Get all tasks for a specific user

### ✅ **Dynamic UUID Handling**

- No hardcoded UUIDs
- Automatic fetching of first available user/task
- Works with changing seed data
- Graceful error handling for missing data

## Prerequisites

1. **API Server Running**: Start with `make run`
2. **Sample Data**: Run `make seed` to create test data
3. **Dependencies**: Python 3 with httpx (managed by uv)
4. **UV Environment**: Scripts use `uv run python` to access project dependencies

## Integration with Makefile

All scripts are integrated with the main Makefile:

```bash
# Quick demos
make demo-full-workflow
make demo-interactive-workflow
make demo-crud-showcase

# Individual operations
make demo-users-list
make demo-task-create-for-first-user
make demo-tasks-summary

# See all available commands
make demo-help
```

## Error Handling

- **Server Check**: All scripts verify API server is running
- **Data Validation**: Graceful handling of missing users/tasks
- **Clear Messages**: Colored output with helpful error messages
- **Fallback Options**: Suggestions for resolving common issues

## Cross-Platform Compatibility

- **macOS**: Uses `date -v+7d` for date calculations
- **Linux**: Uses `date -d "+7 days"` for date calculations
- **JSON Formatting**: Uses `python3 -m json.tool` for readable output
- **Color Support**: ANSI color codes for better UX
