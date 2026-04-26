#!/bin/bash

# Code Mentor AI - Development Setup Script

set -e

echo "🚀 Code Mentor AI - Setup Script"
echo "=================================="

# Check prerequisites
echo "✓ Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.10+"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Create environment file
echo "✓ Creating environment configuration..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "  - Created .env (update with your secrets)"
else
    echo "  - .env already exists"
fi

# Backend setup
echo "✓ Setting up backend..."
cd backend

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "  - Created virtual environment"
fi

source .venv/bin/activate 2>/dev/null || .venv\Scripts\activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
echo "  - Installed dependencies"

# Frontend setup
echo "✓ Setting up frontend..."
cd ../frontend

if [ ! -d "node_modules" ]; then
    npm install
    echo "  - Installed dependencies"
else
    echo "  - Dependencies already installed"
fi

cd ..

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your API keys (especially GROQ_API_KEY)"
echo "2. For Docker: make dev"
echo "3. For manual: make dev-backend (in one terminal) + make dev-frontend (another)"
echo ""
