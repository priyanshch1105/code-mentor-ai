# Backend - Code Mentor AI

Production-grade FastAPI backend for Code Mentor AI.

## Structure

```
backend/
├── config/          # Configuration management
├── models/          # SQLAlchemy database models  
├── routers/         # API endpoint handlers
├── services/        # Business logic
├── middleware/      # Custom middleware
├── utils/           # Helper functions
├── tests/           # Unit tests
└── main.py          # Application entry
```

## Key Files

- `main.py` - FastAPI application initialization
- `config/settings.py` - Environment configuration
- `requirements.txt` - Python dependencies
- `Dockerfile` - Container configuration

## Running

### Local Development

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # or .\.venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Docker

```bash
docker build -t code-mentor-backend .
docker run -p 8000:8000 code-mentor-backend
```

## API Documentation

Once running, visit `http://localhost:8000/docs` for interactive API docs.

## Testing

```bash
pytest                          # Run all tests
pytest --cov                   # With coverage
pytest -v                      # Verbose output
pytest backend/tests/test_auth.py::test_login  # Single test
```

## Configuration

See `.env.example` for all available environment variables.

Key variables:
- `DATABASE_URL` - PostgreSQL connection string
- `GROQ_API_KEY` - AI service API key
- `JWT_SECRET_KEY` - Secret for token signing
- `ENVIRONMENT` - dev/staging/production

See [Main README](../README.md) for more info.
- **Professional Logging**: Structured logging with rotation
- **Database**: PostgreSQL with SQLAlchemy ORM
- **API Documentation**: Auto-generated Swagger & ReDoc docs

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- PostgreSQL 12+
- X.AI API Key

### Setup

1. **Create virtual environment**
```bash
python -m venv .venv
source .venv/Scripts/activate  # Windows
# or
source .venv/bin/activate      # Linux/Mac
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure environment**
```bash
# Copy and edit .env file
cp .env.example .env
```

Required `.env` variables:
```env
SECRET_KEY=your-secret-key-here
XAI_API_KEY=your-xai-key-here
DB_USER=postgres
DB_PASSWORD=your-db-password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=aitutor
```

4. **Run development server**
```bash
uvicorn main:app --reload
```

Server runs on: `http://localhost:8000`
- API Docs: `http://localhost:8000/api/docs`
- Health Check: `http://localhost:8000/health`

## 📁 Project Structure

```
backend/
├── main.py                 # FastAPI app entry point
├── config.py              # Configuration management
├── logger.py              # Logging setup
├── db.py                  # Database connection
├── requirements.txt       # Python dependencies
├── .env                   # Environment variables
├── models/                # Database models
│   ├── base.py
│   ├── user.py
│   ├── session.py
│   ├── message.py
│   ├── quiz.py
│   └── code_session.py
├── routers/               # API endpoints
│   ├── auth.py           # Authentication
│   ├── qa.py             # Q&A endpoint
│   ├── quiz.py           # Quiz management
│   ├── code_debug.py     # Code analysis
│   ├── recommend.py      # Recommendations
│   └── sessions.py       # Session management
└── services/              # Business logic
    ├── grok_service.py   # Grok AI integration
    └── emotion_analyzer.py
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login and get JWT token
- `GET /api/auth/me` - Get current user info
- `POST /api/auth/select-subject` - Set learning subject

### Q&A
- `POST /api/qa` - Ask a question

### Quiz
- `POST /api/quiz/create` - Create new quiz
- `GET /api/quiz/{quiz_id}/questions` - Get quiz questions
- `POST /api/quiz/submit` - Submit quiz answers
- `GET /api/quiz/history` - Get user's quiz history
- `GET /api/quiz/recommendations` - Get personalized recommendations

### Code Debug
- `POST /api/debug` - Analyze and debug code

### Recommendations
- `GET /api/recommend` - Get learning recommendations

## 🔐 Security

- Passwords hashed with bcrypt
- JWT tokens with 1-week expiration
- CORS configured
- Environment variables for sensitive data
- HTTPS ready (configure in deployment)

## 📊 Testing

```bash
# Run tests
pytest

# With coverage
pytest --cov=.

# Specific test file
pytest tests/test_auth.py
```

## 🛠️ Development

### Adding a new endpoint
1. Create in `routers/your_router.py`
2. Import in `main.py`
3. Include router: `app.include_router(your_router, prefix="/api")`

### Database changes
1. Update model in `models/`
2. SQLAlchemy will auto-create tables on startup

### Logging
```python
from logger import get_logger

logger = get_logger(__name__)
logger.info("Your message")
logger.error("Error message")
```

## 📝 Configuration

### Environment Settings
Edit `config.py` for centralized configuration:
- `ENV`: development/production
- `DEBUG`: Enable debug mode
- `LOG_LEVEL`: Logging verbosity
- `CORS_ORIGINS`: Allowed frontend domains

### Database
Configured in `.env`:
```env
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=aitutor
```

## 🚀 Deployment

### Production Setup
1. Set `ENV=production` in `.env`
2. Set `DEBUG=False`
3. Update `SECRET_KEY` to random value
4. Configure `CORS_ORIGINS` for frontend domain
5. Use production database
6. Set up HTTPS

### Docker (Optional)
```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]
```

## 📚 Documentation

- Full API docs: `/api/docs` (Swagger UI)
- ReDoc alternative: `/api/redoc`
- Health check: `/health`

## 🐛 Troubleshooting

### Database Connection Error
```
Error: DB_PASSWORD environment variable not set
```
Solution: Add `DB_PASSWORD` to `.env` file

### Model Not Found (Grok-2)
```
Error: Model not found: grok-2-latest
```
Solution: Using correct model `grok-2` (already configured)

### CORS Error
Update `CORS_ORIGINS` in `config.py` with your frontend URL

## 📧 Support

For issues or questions:
1. Check logs: `logs/app.log`
2. Review API docs: `/api/docs`
3. Health check: `GET /health`

## 📄 License

[Your License Here]
