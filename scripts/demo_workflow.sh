#!/bin/bash

# Colors
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
print_colored() {
    echo -e "${1}${2}${RESET}"
}

print_step() {
    echo ""
    print_colored "$YELLOW" "Step $1: $2"
    echo ""
}

check_server() {
    uv run python "$SCRIPT_DIR/api_utils.py" check-server
}

# Workflow functions
full_workflow() {
    print_colored "$BLUE" "🚀 Starting complete assignment requirements demonstration..."
    
    print_step "1" "User CRUD Operations"
    echo "Creating users..."
    bash "$SCRIPT_DIR/user_crud.sh" create
    bash "$SCRIPT_DIR/user_crud.sh" list
    
    print_step "2" "Task CRUD Operations"
    echo "Creating tasks..."
    bash "$SCRIPT_DIR/task_crud.sh" create
    bash "$SCRIPT_DIR/task_crud.sh" list
    
    print_step "3" "Task Filtering by Status"
    echo "Filtering pending tasks:"
    bash "$SCRIPT_DIR/task_crud.sh" filter-pending
    
    print_step "4" "Task Ordering by Due Date"
    echo "Tasks ordered by due date (descending):"
    bash "$SCRIPT_DIR/task_crud.sh" ordered
    echo ""
    echo "Tasks ordered by due date (ascending):"
    bash "$SCRIPT_DIR/task_crud.sh" ordered-asc
    
    print_step "5" "Task Pagination"
    echo "Paginated results (limit=2):"
    bash "$SCRIPT_DIR/task_crud.sh" paginated
    
    print_step "6" "User-Specific Tasks"
    echo "Tasks for specific user:"
    bash "$SCRIPT_DIR/task_crud.sh" user-tasks
    
    print_step "7" "Idempotency Feature"
    echo "Testing idempotency (same task created twice):"
    bash "$SCRIPT_DIR/task_crud.sh" idempotency
    
    print_step "8" "Task Summary Endpoint"
    echo "Task counts by status:"
    bash "$SCRIPT_DIR/task_crud.sh" summary
    
    echo ""
    print_colored "$GREEN" "✅ All assignment requirements demonstrated!"
    echo ""
    print_colored "$BLUE" "Assignment Requirements Covered:"
    echo "  ✅ CRUD endpoints for tasks and users"
    echo "  ✅ Task filtering by status"
    echo "  ✅ Task ordering by due_date (asc/desc)"
    echo "  ✅ Task pagination (limit, offset)"
    echo "  ✅ Fetch tasks for specific user"
    echo "  ✅ Idempotency with idempotency_key"
    echo "  ✅ Summary endpoint (task counts by status)"
    echo "  ✅ Unit tests (run: uv run pytest)"
}

interactive_workflow() {
    print_colored "$BLUE" "🎯 Starting interactive workflow..."
    
    print_step "1" "Get first user details"
    bash "$SCRIPT_DIR/user_crud.sh" get-first
    
    print_step "2" "Create a task for this user"
    bash "$SCRIPT_DIR/task_crud.sh" create
    
    print_step "3" "List tasks for this user"
    bash "$SCRIPT_DIR/task_crud.sh" user-tasks
    
    print_step "4" "Test idempotency"
    bash "$SCRIPT_DIR/task_crud.sh" idempotency
    
    print_step "5" "Get updated task summary"
    bash "$SCRIPT_DIR/task_crud.sh" summary
    
    print_step "6" "Test advanced filtering and pagination"
    echo "Filtering pending tasks:"
    bash "$SCRIPT_DIR/task_crud.sh" filter-pending
    echo ""
    echo "Pagination example:"
    bash "$SCRIPT_DIR/task_crud.sh" paginated
    echo ""
    echo "Ordering example:"
    bash "$SCRIPT_DIR/task_crud.sh" ordered
    
    echo ""
    print_colored "$GREEN" "✅ Interactive workflow complete!"
}

crud_showcase() {
    print_colored "$BLUE" "🎪 Starting CRUD operations showcase..."
    
    print_step "1" "User CRUD Operations"
    echo "Creating user..."
    bash "$SCRIPT_DIR/user_crud.sh" create
    echo ""
    echo "Getting first user..."
    bash "$SCRIPT_DIR/user_crud.sh" get-first
    echo ""
    echo "Updating first user..."
    bash "$SCRIPT_DIR/user_crud.sh" update-first
    
    print_step "2" "Task CRUD Operations"
    echo "Creating task..."
    bash "$SCRIPT_DIR/task_crud.sh" create
    echo ""
    echo "Getting first task..."
    bash "$SCRIPT_DIR/task_crud.sh" get-first
    echo ""
    echo "Updating first task..."
    bash "$SCRIPT_DIR/task_crud.sh" update-first
    
    print_step "3" "Advanced Features"
    echo "Task summary:"
    bash "$SCRIPT_DIR/task_crud.sh" summary
    echo ""
    echo "User's tasks:"
    bash "$SCRIPT_DIR/task_crud.sh" user-tasks
    echo ""
    echo "Idempotency test:"
    bash "$SCRIPT_DIR/task_crud.sh" idempotency
    
    echo ""
    print_colored "$GREEN" "✅ CRUD showcase complete!"
}

# Main function
main() {
    # Check if server is running
    if ! check_server; then
        print_colored "$RED" "API server is not running. Start with: make run"
        exit 1
    fi
    
    case "${1:-full}" in
        "full")
            full_workflow
            ;;
        "interactive")
            interactive_workflow
            ;;
        "crud")
            crud_showcase
            ;;
        *)
            echo "Usage: $0 {full|interactive|crud}"
            echo ""
            echo "Workflows:"
            echo "  full        - Complete workflow demonstration"
            echo "  interactive - Interactive workflow with detailed steps"
            echo "  crud        - CRUD operations showcase"
            exit 1
            ;;
    esac
}

main "$@"
