#!/usr/bin/env python3
"""
API utility functions for CRUD demo scripts
"""

import json
import sys
from typing import Any

import httpx

API_BASE = "http://localhost:8000/api"


class Colors:
    BLUE = "\033[36m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    RED = "\033[31m"
    RESET = "\033[0m"


def print_colored(message: str, color: str = Colors.RESET):
    """Print a colored message"""
    print(f"{color}{message}{Colors.RESET}")


def check_server() -> bool:
    """Check if the API server is running"""
    try:
        # Use the health endpoint or root endpoint
        response = httpx.get("http://localhost:8000/health", timeout=5)
        return response.status_code == 200
    except httpx.RequestError:
        return False


def make_request(method: str, endpoint: str, data: dict[Any, Any] | None = None) -> dict[Any, Any] | None:
    """Make an API request and return JSON response"""
    url = f"{API_BASE}{endpoint}"
    headers = {"accept": "application/json", "Content-Type": "application/json"}

    try:
        if method.upper() == "GET":
            response = httpx.get(url, headers=headers)
        elif method.upper() == "POST":
            response = httpx.post(url, headers=headers, json=data)
        elif method.upper() == "PUT":
            response = httpx.put(url, headers=headers, json=data)
        elif method.upper() == "DELETE":
            response = httpx.delete(url, headers=headers)
        else:
            print_colored(f"Unsupported HTTP method: {method}", Colors.RED)
            return None

        if response.status_code in [200, 201]:
            return response.json() if response.content else {}
        elif response.status_code == 204:
            return {}  # No content for successful DELETE
        else:
            print_colored(f"API Error {response.status_code}: {response.text}", Colors.RED)
            return None

    except httpx.RequestError as e:
        print_colored(f"Request failed: {e}", Colors.RED)
        return None


def get_first_user_id() -> str | None:
    """Get the ID of the first user"""
    users = make_request("GET", "/users/?limit=1")
    if users and len(users) > 0:
        return users[0]["id"]
    return None


def get_first_task_id() -> str | None:
    """Get the ID of the first task"""
    tasks = make_request("GET", "/tasks/?limit=1")
    if tasks and len(tasks) > 0:
        return tasks[0]["id"]
    return None


def get_user_by_email(email: str) -> dict[Any, Any] | None:
    """Get a user by email address"""
    users = make_request("GET", "/users/")
    if users:
        for user in users:
            if user.get("email") == email:
                return user
    return None


def pretty_print_json(data: Any):
    """Pretty print JSON data"""
    print(json.dumps(data, indent=2, default=str))


def main():
    """Main function for command line usage"""
    if len(sys.argv) < 2:
        print("Usage: python api_utils.py <command> [args...]")
        print("Commands:")
        print("  check-server")
        print("  get-first-user-id")
        print("  get-first-task-id")
        print("  get-user-by-email <email>")
        sys.exit(1)

    command = sys.argv[1]

    if command == "check-server":
        if check_server():
            print_colored("✓ API server is running", Colors.GREEN)
            sys.exit(0)
        else:
            print_colored("✗ API server is not running", Colors.RED)
            sys.exit(1)

    elif command == "get-first-user-id":
        user_id = get_first_user_id()
        if user_id:
            print(user_id)
        else:
            print_colored("No users found", Colors.RED)
            sys.exit(1)

    elif command == "get-first-task-id":
        task_id = get_first_task_id()
        if task_id:
            print(task_id)
        else:
            print_colored("No tasks found", Colors.RED)
            sys.exit(1)

    elif command == "get-user-by-email":
        if len(sys.argv) < 3:
            print_colored("Email address required", Colors.RED)
            sys.exit(1)
        email = sys.argv[2]
        user = get_user_by_email(email)
        if user:
            print(user["id"])
        else:
            print_colored(f"User with email {email} not found", Colors.RED)
            sys.exit(1)

    else:
        print_colored(f"Unknown command: {command}", Colors.RED)
        sys.exit(1)


if __name__ == "__main__":
    main()
