# Code Mentor AI - Project Guidelines

## 📂 Folder Structure Standards

### Backend (`/backend`)
```
backend/
├── __init__.py
├── main.py                 # FastAPI app initialization
├── config/                 # Configuration management
│   ├── __init__.py
│   └── settings.py        # Environment & settings
├── models/                # Database models
│   ├── __init__.py
│   ├── base.py           # Base model
│   ├── user.py
│   ├── session.py
│   └── message.py
├── routers/              # API endpoints
│   ├── __init__.py
│   ├── auth.py
│   ├── chat.py
│   ├── quiz.py
│   └── recommend.py
├── services/            # Business logic
│   ├── __init__.py
│   ├── ai_service.py
│   ├── quiz_service.py
│   └── recommend_service.py
├── middleware/          # Custom middleware
│   ├── __init__.py
│   └── auth.py
├── utils/              # Helper functions
│   ├── __init__.py
│   └── validators.py
├── tests/              # Unit tests
│   ├── __init__.py
│   ├── test_auth.py
│   ├── test_chat.py
│   └── test_quiz.py
├── requirements.txt    # Python dependencies
├── Dockerfile         # Docker config
└── .env              # Environment variables
```

### Frontend (`/frontend/src`)
```
src/
├── main.jsx               # Entry point
├── App.jsx               # Root component
├── components/          # Reusable UI components
│   ├── Button.jsx
│   ├── Card.jsx
│   └── Modal.jsx
├── features/           # Feature modules (self-contained)
│   ├── auth/
│   │   ├── components/
│   │   ├── services/
│   │   └── hooks/
│   ├── chat/
│   │   ├── components/
│   │   ├── services/
│   │   └── hooks/
│   ├── quiz/
│   │   └── ...
│   └── code-debug/
│       └── ...
├── services/          # API services
│   ├── api.js        # Axios instance
│   └── auth.js       # Auth service
├── hooks/            # Custom React hooks
│   ├── useAuth.js
│   └── useChat.js
├── utils/            # Helper functions
│   ├── formatters.js
│   └── validators.js
├── styles/           # Global styles
│   └── index.css
└── assets/          # Static assets
```

## 🎨 Naming Conventions

### Files & Folders
- **Components**: PascalCase, `.jsx` (e.g., `MessageBar.jsx`)
- **Services/Utils**: camelCase, `.js` (e.g., `apiClient.js`)
- **Folders**: kebab-case, lowercase (e.g., `code-debug`)

### Variables & Functions
- **Components**: PascalCase (e.g., `ChatHistory`)
- **Functions**: camelCase (e.g., `handleSubmit`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_MESSAGES`)
- **Types/Interfaces**: PascalCase (e.g., `User`)

### Database
- **Tables**: snake_case, lowercase (e.g., `chat_sessions`)
- **Columns**: snake_case, lowercase (e.g., `user_id`)

## 🔧 Code Quality Standards

### Python (Backend)
- Line length: Max 100 characters
- Use type hints for all functions
- Use `black` for formatting
- Use `flake8` for linting
- Min test coverage: 80%

```bash
# Format
black backend/

# Lint
flake8 backend/
mypy backend/

# Test
pytest --cov --cov-report=html
```

### JavaScript (Frontend)
- Use ES6+ syntax
- Use functional components
- Use hooks for state management
- Min test coverage: 70%

```bash
# Format
npm run format

# Lint
npm run lint

# Test
npm run test:coverage
```

## 📝 Documentation

### Code Comments
- Use docstrings for functions/classes
- Explain WHY, not WHAT
- Keep comments up-to-date

### Commit Messages
Format: `<type>(<scope>): <subject>`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code formatting
- `refactor`: Code refactoring
- `perf`: Performance
- `test`: Tests
- `chore`: Build/dependencies

Example:
```
feat(chat): add message search

- Add search input component
- Add filter by date range
- Add filter by subject
- Add tests

Closes #42
```

## 🧪 Testing

### Backend
- Place tests in `backend/tests/`
- Use pytest fixtures
- Mock external APIs
- Use parametrize for variations

### Frontend
- Place tests in `frontend/src/**/__tests__/`
- Test behavior, not implementation
- Mock API calls
- Use React Testing Library

## 🔐 Security

- Never commit `.env` files
- Use environment variables for secrets
- Validate all inputs
- Use HTTPS in production
- Sanitize user inputs
- Use CORS properly

## 📊 Performance

- Frontend: Lazy load routes & components
- Backend: Use database indexes
- Cache frequently accessed data
- Optimize API queries
- Monitor performance metrics

## 🐛 Debugging

### Backend
```bash
# Debug mode
DEBUG=true uvicorn main:app --reload

# Print logs
import logging
logger = logging.getLogger(__name__)
logger.debug("message")
```

### Frontend
```bash
# Browser DevTools
- F12 in browser
- Use React DevTools extension
- Use Network tab for API calls
```

## ✅ Pre-Commit Checklist

- [ ] Code follows style guide
- [ ] All tests pass
- [ ] No console errors/warnings
- [ ] Documentation updated
- [ ] .env not committed
- [ ] No hardcoded secrets
- [ ] Performance acceptable
- [ ] Accessibility considered
