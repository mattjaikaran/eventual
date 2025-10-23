#!/bin/bash

# Task Management API - Test Runner Script
# This script runs all tests for the task management application

echo "🧪 Running Task Management API Tests..."
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "❌ Error: uv is not installed. Please install uv first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Sync dependencies
echo "📦 Syncing dependencies..."
uv sync --dev

# Run tests
echo "🔍 Running tests..."
echo ""

uv run pytest eventual_backend/tests/ -v --tb=short

echo ""
echo "✅ Tests completed!"
