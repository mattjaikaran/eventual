#!/bin/bash

# Task Management API - Quick Start Script
# This script sets up everything needed to run the application

echo "⚡ Task Management API - Quick Start Setup"
echo "========================================"
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "❌ Error: uv is not installed. Please install uv first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Check if PostgreSQL is running
if ! pgrep -x "postgres" > /dev/null; then
    echo "❌ PostgreSQL is not running. Please start PostgreSQL first:"
    echo "   macOS: brew services start postgresql"
    echo "   Linux: sudo systemctl start postgresql"
    exit 1
fi

# Make scripts executable
chmod +x start_server.sh
chmod +x run_tests.sh
chmod +x setup_database.sh

# Setup databases
echo "🗄️  Setting up databases..."
./setup_database.sh

# Sync dependencies
echo ""
echo "📦 Installing dependencies..."
uv sync --dev

# Create seed data
echo ""
echo "🌱 Creating seed data..."
uv run python seed_data.py

echo ""
echo "🎉 Setup complete!"
echo ""
echo "🚀 Ready to go! Choose an option:"
echo "   1. Start the server: ./start_server.sh"
echo "   2. Run tests: ./run_tests.sh"
echo "   3. View API docs: http://localhost:8000/docs (after starting server)"
echo ""
