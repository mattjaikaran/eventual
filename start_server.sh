#!/bin/bash

# Task Management API - Server Startup Script
# This script starts the FastAPI server for the task management application

echo "🚀 Starting Task Management API Server..."
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

# Start the server
echo "🌐 Starting server on http://localhost:8000"
echo "📚 API Documentation: http://localhost:8000/docs"
echo "🔍 Alternative docs: http://localhost:8000/redoc"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

uv run uvicorn eventual_backend.main:app --host 0.0.0.0 --port 8000 --reload
