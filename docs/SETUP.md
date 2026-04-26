# Local Development Setup

## Prerequisites

- Python 3.10+
- Node.js 18+
- PostgreSQL 13+
- Git

## Quick Start with Docker (Recommended)

```bash
# Clone repository
git clone <repo-url>
cd code-tutor

# Copy environment file
cp .env.example .env

# Update .env with your credentials
# Add GROQ_API_KEY and other secrets

# Start all services
docker-compose up --build

# Backend: http://localhost:8000
# Frontend: http://localhost:5173
# API Docs: http://localhost:8000/docs
```

## Manual Setup

### Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv .venv

# Activate virtual environment
# Windows:
.\.venv\Scripts\Activate.ps1
# macOS/Linux:
source .venv/bin/activate

# Install dependencies
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Set up environment
cp ../.env.example .env
# Edit .env with your settings

# Run migrations
python -m alembic upgrade head

# Start server
uvicorn main:app --reload --port 8000
```

### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Create environment file
cp ../.env.example .env.local

# Start development server
npm run dev

# Browser: http://localhost:5173
```

## Database Setup

```bash
# Create database (if using local PostgreSQL)
createdb code_mentor

# Run migrations
cd backend
python -m alembic upgrade head
```

## Environment Variables

See `.env.example` for all available options:

Key variables:
- `GROQ_API_KEY`: Your Groq AI API key
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET_KEY`: Secret for token generation
- `CORS_ORIGINS`: Allowed frontend origins

## Testing

### Backend Tests
```bash
cd backend
pytest
pytest --cov  # With coverage
```

### Frontend Tests
```bash
cd frontend
npm test
npm run test:coverage
```

## Verification

Backend API health check:
```bash
curl http://localhost:8000/docs
```

Frontend running:
```
http://localhost:5173
```

## Troubleshooting

**Port Already in Use:**
```bash
# Change port in .env or use different ports
# Backend: BACKEND_PORT=8001
# Frontend: VITE_PORT=5174
```

**Database Connection Error:**
- Ensure PostgreSQL is running
- Check DATABASE_URL in .env
- Verify user permissions

**Missing Dependencies:**
```bash
# Backend
python -m pip install --upgrade pip
python -m pip install --upgrade -r requirements.txt

# Frontend
npm install --force
```

**Windows Launcher Error (`Fatal error in launcher`)**
```powershell
cd backend
deactivate 2>$null
Remove-Item -Recurse -Force .venv
py -3 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

## IDE Setup

### VS Code Extensions
- Python
- Pylance
- ES7+ React/Redux/React-Native snippets
- Tailwind CSS IntelliSense
- Thunder Client (API testing)

### PyCharm
- Configure Python interpreter from `.venv`
- Enable code inspections
- Set up run configurations
