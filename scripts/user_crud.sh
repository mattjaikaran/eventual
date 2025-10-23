#!/bin/bash
#
# User CRUD operations demo script
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
DEMO_USER_EMAIL="demo-user@example.com"
DEMO_USER_NAME="Demo User"
DEMO_USER_PHONE="+1-555-DEMO"

# Helper functions
print_colored() {
    echo -e "${1}${2}${RESET}"
}

check_server() {
    uv run python "$SCRIPT_DIR/api_utils.py" check-server
}

# User operations
list_users() {
    print_colored "$BLUE" "📋 Listing all users..."
    curl -s -X GET "$API_BASE/users/" -H "accept: application/json" | python3 -m json.tool
}

create_demo_user() {
    print_colored "$BLUE" "➕ Creating a new demo user..."
    curl -s -X POST "$API_BASE/users/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$DEMO_USER_NAME\", \"email\": \"$DEMO_USER_EMAIL\", \"phone_number\": \"$DEMO_USER_PHONE\"}" | python3 -m json.tool
}

get_first_user() {
    print_colored "$BLUE" "👤 Getting first user details..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Run 'make seed' to create sample data."
        exit 1
    fi
    
    print_colored "$YELLOW" "Using User ID: $USER_ID"
    curl -s -X GET "$API_BASE/users/$USER_ID" -H "accept: application/json" | python3 -m json.tool
}

update_first_user() {
    print_colored "$BLUE" "✏️ Updating first user..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Run 'make seed' to create sample data."
        exit 1
    fi
    
    print_colored "$YELLOW" "Using User ID: $USER_ID"
    curl -s -X PUT "$API_BASE/users/$USER_ID" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{"name": "Updated User Name", "email": "updated@example.com", "phone_number": "+1-555-UPDATED"}' | python3 -m json.tool
}

delete_first_user() {
    print_colored "$BLUE" "🗑️ Deleting first user..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "No users found. Nothing to delete."
        exit 1
    fi
    
    print_colored "$YELLOW" "Deleting User ID: $USER_ID"
    curl -s -X DELETE "$API_BASE/users/$USER_ID" -H "accept: application/json"
    print_colored "$GREEN" "User deleted successfully"
}

get_demo_user() {
    print_colored "$BLUE" "👤 Getting demo user details..."
    USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-user-by-email "$DEMO_USER_EMAIL" 2>/dev/null)
    
    if [ -z "$USER_ID" ]; then
        print_colored "$RED" "Demo user not found. Run 'make demo-user-create' first."
        exit 1
    fi
    
    print_colored "$YELLOW" "Using Demo User ID: $USER_ID"
    curl -s -X GET "$API_BASE/users/$USER_ID" -H "accept: application/json" | python3 -m json.tool
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
            list_users
            ;;
        "create")
            create_demo_user
            ;;
        "get-first")
            get_first_user
            ;;
        "update-first")
            update_first_user
            ;;
        "delete-first")
            delete_first_user
            ;;
        "get-demo")
            get_demo_user
            ;;
        *)
            echo "Usage: $0 {list|create|get-first|update-first|delete-first|get-demo}"
            echo ""
            echo "Commands:"
            echo "  list         - List all users"
            echo "  create       - Create a demo user"
            echo "  get-first    - Get the first user"
            echo "  update-first - Update the first user"
            echo "  delete-first - Delete the first user"
            echo "  get-demo     - Get the demo user by email"
            exit 1
            ;;
    esac
}

main "$@"
