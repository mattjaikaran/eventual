#!/bin/bash
#
# Task CRUD operations demo script
#

# Colors
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Configuration
API_BASE="http://localhost:8000/api"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
print_colored() {
    echo -e "${1}${2}${RESET}"
}

check_server() {
    uv run python "$SCRIPT_DIR/api_utils.py" check-server
}

get_future_date() {
    # Get a date 7 days in the future in ISO format
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -u -v+7d +%Y-%m-%dT%H:%M:%S.000Z
    else
        # Linux
        date -u -d "+7 days" +%Y-%m-%dT%H:%M:%S.000Z
    fi
}

# Task operations
list_tasks() {
    print_colored "$BLUE" "📋 Listing all tasks..."
    curl -s -X GET "$API_BASE/tasks/" -H "accept: application/json" | python3 -m json.tool
}

create_task_for_first_user() {
    print_colored "$BLUE" "➕ Creating a new task for first user..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Run 'make seed' to create sample data."
        exit 1
    fi
    
    print_colored "$YELLOW" "Creating task for User ID: $USER_ID"
    
    DUE_DATE=$(get_future_date)
    IDEMPOTENCY_KEY="demo-task-$(date +%s)"
    
    curl -s -X POST "$API_BASE/tasks/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Demo Task - Complete API Testing\", \"status\": \"pending\", \"due_date\": \"$DUE_DATE\", \"user_id\": \"$USER_ID\", \"idempotency_key\": \"$IDEMPOTENCY_KEY\"}" | python3 -m json.tool
}

get_first_task() {
    print_colored "$BLUE" "📄 Getting first task details..."
    TASK_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-task-id 2>/dev/null)
    
    if [ -z "$TASK_ID" ]; then
        print_colored "$RED" "No tasks found. Run 'make demo-task-create-for-first-user' to create a task."
        exit 1
    fi
    
    print_colored "$YELLOW" "Using Task ID: $TASK_ID"
    curl -s -X GET "$API_BASE/tasks/$TASK_ID" -H "accept: application/json" | python3 -m json.tool
}

update_first_task() {
    print_colored "$BLUE" "✏️ Updating first task..."
    TASK_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-task-id 2>/dev/null)
    
    if [ -z "$TASK_ID" ]; then
        print_colored "$RED" "No tasks found. Run 'make demo-task-create-for-first-user' to create a task."
        exit 1
    fi
    
    print_colored "$YELLOW" "Using Task ID: $TASK_ID"
    curl -s -X PUT "$API_BASE/tasks/$TASK_ID" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{"title": "Demo Task - Complete API Testing (Updated)", "status": "in_progress"}' | python3 -m json.tool
}

delete_first_task() {
    print_colored "$BLUE" "🗑️ Deleting first task..."
    TASK_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-task-id 2>/dev/null)
    
    if [ -z "$TASK_ID" ]; then
        print_colored "$RED" "No tasks found. Nothing to delete."
        exit 1
    fi
    
    print_colored "$YELLOW" "Deleting Task ID: $TASK_ID"
    curl -s -X DELETE "$API_BASE/tasks/$TASK_ID" -H "accept: application/json"
    print_colored "$GREEN" "Task deleted successfully"
}

# Advanced operations
filter_pending_tasks() {
    print_colored "$BLUE" "📋 Listing pending tasks..."
    curl -s -X GET "$API_BASE/tasks/?status=pending" -H "accept: application/json" | python3 -m json.tool
}

filter_tasks_by_first_user() {
    print_colored "$BLUE" "📋 Listing tasks for first user..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Run 'make seed' to create sample data."
        exit 1
    fi
    
    print_colored "$YELLOW" "Filtering tasks for User ID: $USER_ID"
    curl -s -X GET "$API_BASE/tasks/?user_id=$USER_ID" -H "accept: application/json" | python3 -m json.tool
}

list_tasks_paginated() {
    print_colored "$BLUE" "📋 Listing tasks with pagination (limit=2, skip=0)..."
    curl -s -X GET "$API_BASE/tasks/?limit=2&skip=0" -H "accept: application/json" | python3 -m json.tool
}

list_tasks_ordered() {
    print_colored "$BLUE" "📋 Listing tasks ordered by due date (desc)..."
    curl -s -X GET "$API_BASE/tasks/?order_by=due_date_desc" -H "accept: application/json" | python3 -m json.tool
}

list_tasks_ordered_asc() {
    print_colored "$BLUE" "📋 Listing tasks ordered by due date (asc)..."
    curl -s -X GET "$API_BASE/tasks/?order_by=due_date_asc" -H "accept: application/json" | python3 -m json.tool
}

get_user_tasks() {
    print_colored "$BLUE" "📋 Getting tasks for first user..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Run 'make seed' to create sample data."
        exit 1
    fi
    
    print_colored "$YELLOW" "Getting tasks for User ID: $USER_ID"
    curl -s -X GET "$API_BASE/tasks/user/$USER_ID" -H "accept: application/json" | python3 -m json.tool
}

get_task_summary() {
    print_colored "$BLUE" "📊 Getting task summary..."
    curl -s -X GET "$API_BASE/tasks/summary/" -H "accept: application/json" | python3 -m json.tool
}

test_idempotency() {
    print_colored "$BLUE" "🔄 Testing idempotency - creating task twice..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Run 'make seed' to create sample data."
        exit 1
    fi
    
    print_colored "$YELLOW" "Testing idempotency for User ID: $USER_ID"
    
    DUE_DATE=$(get_future_date)
    IDEMPOTENCY_KEY="idempotency-test-123"
    
    print_colored "$YELLOW" "First creation:"
    curl -s -X POST "$API_BASE/tasks/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Idempotency Test Task\", \"status\": \"pending\", \"due_date\": \"$DUE_DATE\", \"user_id\": \"$USER_ID\", \"idempotency_key\": \"$IDEMPOTENCY_KEY\"}" | python3 -m json.tool
    
    echo ""
    print_colored "$YELLOW" "Second creation (should return existing):"
    curl -s -X POST "$API_BASE/tasks/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Idempotency Test Task\", \"status\": \"pending\", \"due_date\": \"$DUE_DATE\", \"user_id\": \"$USER_ID\", \"idempotency_key\": \"$IDEMPOTENCY_KEY\"}" | python3 -m json.tool
}

# Main function
main() {
    # Check if server is running
    if ! check_server; then
        print_colored "$RED" "API server is not running. Start with: make run"
        exit 1
    fi
    
    case "${1:-list}" in
        "list")
            list_tasks
            ;;
        "create")
            create_task_for_first_user
            ;;
        "get-first")
            get_first_task
            ;;
        "update-first")
            update_first_task
            ;;
        "delete-first")
            delete_first_task
            ;;
        "filter-pending")
            filter_pending_tasks
            ;;
        "filter-by-user")
            filter_tasks_by_first_user
            ;;
        "paginated")
            list_tasks_paginated
            ;;
        "ordered")
            list_tasks_ordered
            ;;
        "ordered-asc")
            list_tasks_ordered_asc
            ;;
        "user-tasks")
            get_user_tasks
            ;;
        "summary")
            get_task_summary
            ;;
        "idempotency")
            test_idempotency
            ;;
        *)
            echo "Usage: $0 {list|create|get-first|update-first|delete-first|filter-pending|filter-by-user|paginated|ordered|ordered-asc|user-tasks|summary|idempotency}"
            echo ""
            echo "Basic CRUD Commands:"
            echo "  list         - List all tasks"
            echo "  create       - Create a task for the first user"
            echo "  get-first    - Get the first task"
            echo "  update-first - Update the first task"
            echo "  delete-first - Delete the first task"
            echo ""
            echo "Advanced Commands:"
            echo "  filter-pending  - Filter tasks by pending status"
            echo "  filter-by-user  - Filter tasks by first user"
            echo "  paginated       - List tasks with pagination"
            echo "  ordered         - List tasks ordered by due date (desc)"
            echo "  ordered-asc     - List tasks ordered by due date (asc)"
            echo "  user-tasks      - Get tasks for first user"
            echo "  summary         - Get task summary"
            echo "  idempotency     - Test idempotency feature"
            exit 1
            ;;
    esac
}

main "$@"
