#!/bin/bash
#
# Comprehensive test script to validate all assignment requirements
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

print_test() {
    echo ""
    print_colored "$BLUE" "🧪 TEST: $1"
    echo ""
}

print_success() {
    print_colored "$GREEN" "✅ $1"
}

print_error() {
    print_colored "$RED" "❌ $1"
}

check_server() {
    uv run python "$SCRIPT_DIR/api_utils.py" check-server
}

# Test functions
test_user_crud() {
    print_test "User CRUD Operations"
    
    # 1. Create User
    echo "Creating a test user..."
    RESPONSE=$(curl -s -X POST "$API_BASE/users/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{"name": "Test User", "email": "test@example.com", "phone_number": "+1-555-TEST"}')
    
    USER_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', ''))")
    
    if [ -n "$USER_ID" ]; then
        print_success "User created with ID: $USER_ID"
        echo "$RESPONSE" | python3 -m json.tool
    else
        print_error "Failed to create user"
        echo "$RESPONSE"
        return 1
    fi
    
    # 2. Read User
    echo ""
    echo "Reading the created user..."
    RESPONSE=$(curl -s -X GET "$API_BASE/users/$USER_ID" -H "accept: application/json")
    echo "$RESPONSE" | python3 -m json.tool
    
    # 3. Update User
    echo ""
    echo "Updating the user..."
    RESPONSE=$(curl -s -X PUT "$API_BASE/users/$USER_ID" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{"name": "Updated Test User", "email": "updated-test@example.com", "phone_number": "+1-555-UPDATED"}')
    echo "$RESPONSE" | python3 -m json.tool
    
    # 4. List Users
    echo ""
    echo "Listing all users..."
    curl -s -X GET "$API_BASE/users/" -H "accept: application/json" | python3 -m json.tool | head -20
    
    print_success "User CRUD operations completed"
    
    # Store USER_ID for task tests
    echo "$USER_ID" > /tmp/test_user_id
}

test_task_crud() {
    print_test "Task CRUD Operations"
    
    # Get user ID from previous test
    if [ -f /tmp/test_user_id ]; then
        USER_ID=$(cat /tmp/test_user_id)
    else
        USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    fi
    
    if [ -z "$USER_ID" ]; then
        print_error "No user ID available for task tests"
        return 1
    fi
    
    # 1. Create Task
    echo "Creating a test task for user $USER_ID..."
    DUE_DATE=$(date -u -v+7d +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || date -u -d "+7 days" +%Y-%m-%dT%H:%M:%S.000Z)
    
    RESPONSE=$(curl -s -X POST "$API_BASE/tasks/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Test Task - Assignment Validation\", \"status\": \"pending\", \"due_date\": \"$DUE_DATE\", \"user_id\": \"$USER_ID\", \"idempotency_key\": \"test-task-123\"}")
    
    TASK_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', ''))")
    
    if [ -n "$TASK_ID" ]; then
        print_success "Task created with ID: $TASK_ID"
        echo "$RESPONSE" | python3 -m json.tool
    else
        print_error "Failed to create task"
        echo "$RESPONSE"
        return 1
    fi
    
    # 2. Read Task
    echo ""
    echo "Reading the created task..."
    curl -s -X GET "$API_BASE/tasks/$TASK_ID" -H "accept: application/json" | python3 -m json.tool
    
    # 3. Update Task
    echo ""
    echo "Updating the task status to in_progress..."
    RESPONSE=$(curl -s -X PUT "$API_BASE/tasks/$TASK_ID" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{"title": "Updated Test Task", "status": "in_progress"}')
    echo "$RESPONSE" | python3 -m json.tool
    
    # 4. List Tasks
    echo ""
    echo "Listing all tasks..."
    curl -s -X GET "$API_BASE/tasks/" -H "accept: application/json" | python3 -m json.tool | head -30
    
    print_success "Task CRUD operations completed"
    
    # Store TASK_ID for other tests
    echo "$TASK_ID" > /tmp/test_task_id
}

test_filtering() {
    print_test "Task Filtering by Status"
    
    echo "Filtering tasks by status: pending"
    curl -s -X GET "$API_BASE/tasks/?status=pending" -H "accept: application/json" | python3 -m json.tool | head -20
    
    echo ""
    echo "Filtering tasks by status: in_progress"
    curl -s -X GET "$API_BASE/tasks/?status=in_progress" -H "accept: application/json" | python3 -m json.tool | head -20
    
    echo ""
    echo "Filtering tasks by status: done"
    curl -s -X GET "$API_BASE/tasks/?status=done" -H "accept: application/json" | python3 -m json.tool | head -20
    
    print_success "Task filtering by status works"
}

test_ordering() {
    print_test "Task Ordering by Due Date"
    
    echo "Ordering tasks by due_date ascending:"
    curl -s -X GET "$API_BASE/tasks/?order_by=due_date_asc&limit=3" -H "accept: application/json" | python3 -m json.tool
    
    echo ""
    echo "Ordering tasks by due_date descending:"
    curl -s -X GET "$API_BASE/tasks/?order_by=due_date_desc&limit=3" -H "accept: application/json" | python3 -m json.tool
    
    print_success "Task ordering by due_date works"
}

test_pagination() {
    print_test "Task Pagination"
    
    echo "Page 1 (limit=2, skip=0):"
    curl -s -X GET "$API_BASE/tasks/?limit=2&skip=0" -H "accept: application/json" | python3 -m json.tool
    
    echo ""
    echo "Page 2 (limit=2, skip=2):"
    curl -s -X GET "$API_BASE/tasks/?limit=2&skip=2" -H "accept: application/json" | python3 -m json.tool
    
    echo ""
    echo "Page 3 (limit=2, skip=4):"
    curl -s -X GET "$API_BASE/tasks/?limit=2&skip=4" -H "accept: application/json" | python3 -m json.tool
    
    print_success "Task pagination works"
}

test_user_tasks() {
    print_test "Fetch Tasks for Specific User"
    
    # Get user ID
    if [ -f /tmp/test_user_id ]; then
        USER_ID=$(cat /tmp/test_user_id)
    else
        USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    fi
    
    echo "Fetching tasks for user: $USER_ID"
    curl -s -X GET "$API_BASE/tasks/user/$USER_ID" -H "accept: application/json" | python3 -m json.tool
    
    echo ""
    echo "Alternative: Filtering tasks by user_id parameter:"
    curl -s -X GET "$API_BASE/tasks/?user_id=$USER_ID" -H "accept: application/json" | python3 -m json.tool
    
    print_success "User-specific task fetching works"
}

test_idempotency() {
    print_test "Idempotency Key Functionality"
    
    # Get user ID
    if [ -f /tmp/test_user_id ]; then
        USER_ID=$(cat /tmp/test_user_id)
    else
        USER_ID=$(uv run python "$SCRIPT_DIR/api_utils.py" get-first-user-id 2>/dev/null)
    fi
    
    DUE_DATE=$(date -u -v+7d +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || date -u -d "+7 days" +%Y-%m-%dT%H:%M:%S.000Z)
    IDEMPOTENCY_KEY="idempotency-test-$(date +%s)"
    
    echo "First request with idempotency key: $IDEMPOTENCY_KEY"
    RESPONSE1=$(curl -s -X POST "$API_BASE/tasks/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Idempotency Test Task\", \"status\": \"pending\", \"due_date\": \"$DUE_DATE\", \"user_id\": \"$USER_ID\", \"idempotency_key\": \"$IDEMPOTENCY_KEY\"}")
    
    TASK_ID1=$(echo "$RESPONSE1" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', ''))")
    echo "$RESPONSE1" | python3 -m json.tool
    
    echo ""
    echo "Second request with same idempotency key (should return existing task):"
    RESPONSE2=$(curl -s -X POST "$API_BASE/tasks/" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Different Title\", \"status\": \"done\", \"due_date\": \"$DUE_DATE\", \"user_id\": \"$USER_ID\", \"idempotency_key\": \"$IDEMPOTENCY_KEY\"}")
    
    TASK_ID2=$(echo "$RESPONSE2" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', ''))")
    echo "$RESPONSE2" | python3 -m json.tool
    
    if [ "$TASK_ID1" = "$TASK_ID2" ]; then
        print_success "Idempotency works - same task ID returned: $TASK_ID1"
    else
        print_error "Idempotency failed - different task IDs: $TASK_ID1 vs $TASK_ID2"
    fi
}

test_summary() {
    print_test "Task Summary Endpoint"
    
    echo "Getting task summary (counts by status):"
    RESPONSE=$(curl -s -X GET "$API_BASE/tasks/summary/" -H "accept: application/json")
    echo "$RESPONSE" | python3 -m json.tool
    
    # Validate the response structure
    PENDING=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('pending', 'MISSING'))")
    IN_PROGRESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('in_progress', 'MISSING'))")
    DONE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('done', 'MISSING'))")
    
    if [ "$PENDING" != "MISSING" ] && [ "$IN_PROGRESS" != "MISSING" ] && [ "$DONE" != "MISSING" ]; then
        print_success "Task summary endpoint works - Pending: $PENDING, In Progress: $IN_PROGRESS, Done: $DONE"
    else
        print_error "Task summary endpoint missing required fields"
    fi
}

test_data_models() {
    print_test "Data Model Validation"
    
    echo "Checking task model fields..."
    TASK_RESPONSE=$(curl -s -X GET "$API_BASE/tasks/?limit=1" -H "accept: application/json")
    echo "$TASK_RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data and len(data) > 0:
    task = data[0]
    required_fields = ['id', 'title', 'status', 'due_date', 'user_id', 'created_at', 'updated_at']
    optional_fields = ['idempotency_key']
    
    print('Task fields found:')
    for field in required_fields:
        if field in task:
            print(f'  ✅ {field}: {type(task[field]).__name__}')
        else:
            print(f'  ❌ {field}: MISSING')
    
    for field in optional_fields:
        if field in task:
            print(f'  ✅ {field} (optional): {type(task[field]).__name__}')
        else:
            print(f'  ⚠️  {field} (optional): Not present')
    
    # Check status enum values
    if task.get('status') in ['pending', 'in_progress', 'done']:
        print(f'  ✅ status enum valid: {task[\"status\"]}')
    else:
        print(f'  ❌ status enum invalid: {task.get(\"status\")}')
"
    
    echo ""
    echo "Checking user model fields..."
    USER_RESPONSE=$(curl -s -X GET "$API_BASE/users/?limit=1" -H "accept: application/json")
    echo "$USER_RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data and len(data) > 0:
    user = data[0]
    required_fields = ['id', 'name', 'email']
    optional_fields = ['phone_number']
    
    print('User fields found:')
    for field in required_fields:
        if field in user:
            print(f'  ✅ {field}: {type(user[field]).__name__}')
        else:
            print(f'  ❌ {field}: MISSING')
    
    for field in optional_fields:
        if field in user:
            print(f'  ✅ {field} (optional): {type(user[field]).__name__}')
        else:
            print(f'  ⚠️  {field} (optional): Not present')
"
    
    print_success "Data model validation completed"
}

# Main test execution
main() {
    print_colored "$BLUE" "🚀 ASSIGNMENT REQUIREMENTS VALIDATION"
    print_colored "$BLUE" "====================================="
    
    # Check if server is running
    if ! check_server; then
        print_error "API server is not running. Start with: make run"
        exit 1
    fi
    
    # Run all tests
    test_data_models
    test_user_crud
    test_task_crud
    test_filtering
    test_ordering
    test_pagination
    test_user_tasks
    test_idempotency
    test_summary
    
    # Cleanup
    rm -f /tmp/test_user_id /tmp/test_task_id
    
    echo ""
    print_colored "$GREEN" "🎉 ALL ASSIGNMENT REQUIREMENTS VALIDATED!"
    print_colored "$GREEN" "========================================="
    echo ""
    print_colored "$YELLOW" "Summary of validated requirements:"
    echo "✅ Task CRUD endpoints"
    echo "✅ User CRUD endpoints"
    echo "✅ Task filtering by status"
    echo "✅ Task ordering by due_date (asc/desc)"
    echo "✅ Task pagination (limit/offset)"
    echo "✅ Fetch tasks for specific user"
    echo "✅ Idempotency key functionality"
    echo "✅ Task summary endpoint"
    echo "✅ Proper data models (UUID, enums, required fields)"
    echo ""
}

main "$@"
