#!/bin/bash

# Task Management API - Database Setup Script
# This script sets up the PostgreSQL databases for the application

echo "🗄️  Setting up Task Management API Databases..."
echo ""

# Check if PostgreSQL is running
if ! pgrep -x "postgres" > /dev/null; then
    echo "❌ PostgreSQL is not running. Please start PostgreSQL first:"
    echo "   macOS: brew services start postgresql"
    echo "   Linux: sudo systemctl start postgresql"
    exit 1
fi

# Create main database
echo "📊 Creating main database 'taskdb'..."
createdb taskdb 2>/dev/null || echo "   (Database 'taskdb' already exists)"

# Create test database
echo "🧪 Creating test database 'test_taskdb'..."
createdb test_taskdb 2>/dev/null || echo "   (Database 'test_taskdb' already exists)"

echo ""
echo "✅ Databases created successfully!"
echo ""
echo "💡 Next steps:"
echo "   1. Run seed data: uv run python seed_data.py"
echo "   2. Start server: ./start_server.sh"
echo "   3. Run tests: ./run_tests.sh"
