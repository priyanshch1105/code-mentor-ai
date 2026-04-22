# Project Architecture

## Project Structure

```
code-tutor/
├── backend/                      # FastAPI Backend
│   ├── models/                   # SQLAlchemy models
│   ├── routers/                  # API routes
│   ├── services/                 # Business logic
│   ├── config/                   # Configuration
│   ├── middleware/               # Custom middleware
│   ├── utils/                    # Helper functions
│   ├── tests/                    # Unit tests
│   ├── main.py                   # Application entry
│   ├── requirements.txt          # Dependencies
│   └── Dockerfile                # Docker config
│
├── frontend/                     # React + Vite Frontend
│   ├── src/
│   │   ├── components/           # Reusable UI components
│   │   ├── features/             # Feature modules
│   │   ├── services/             # API services
│   │   ├── hooks/                # Custom React hooks
│   │   ├── utils/                # Helper functions
│   │   ├── styles/               # Global styles
│   │   ├── App.jsx               # Root component
│   │   └── main.jsx              # Entry point
│   ├── public/                   # Static assets
│   ├── tests/                    # Component tests
│   ├── package.json              # Dependencies
│   ├── vite.config.js            # Vite config
│   └── Dockerfile.dev            # Dev Docker config
│
├── scripts/                      # Utilities & scripts
│   ├── migrations/               # Database migrations
│   ├── setup/                    # Setup scripts
│   └── monitoring/               # Monitoring utilities
│
├── docs/                         # Documentation
│   ├── API.md                    # API documentation
│   ├── SETUP.md                  # Setup guide
│   └── CONTRIBUTING.md           # Contributing guide
│
├── .github/                      # GitHub workflows
│   └── workflows/                # CI/CD pipelines
│
├── docker-compose.yml            # Docker Compose
├── .env.example                  # Environment template
├── .gitignore                    # Git ignore rules
├── ARCHITECTURE.md               # This file
├── README.md                     # Project overview
└── LICENSE                       # License
```

## Architecture Layers

### Backend Architecture

```
Routes (HTTP Handlers)
    ↓
Middleware (Auth, Logging, CORS)
    ↓
Services (Business Logic)
    ↓
Models (Database Layer)
    ↓
Database (PostgreSQL)
```

### Frontend Architecture

```
main.jsx (Entry)
    ↓
App.jsx (Root)
    ↓
Features (Feature Modules)
    ├── auth/
    ├── chat/
    ├── quiz/
    └── code-debug/
    ↓
Components (UI)
    ├── Shared
    └── Feature-Specific
    ↓
API Services
    ↓
External APIs
```

## Key Design Patterns

- **Separation of Concerns**: Models, Services, Routes
- **Feature-Based Organization**: Each feature self-contained
- **Middleware Pattern**: Centralized cross-cutting concerns
- **Service Layer**: All business logic isolated
- **API Client Pattern**: Single source of truth for API calls

## Development Workflow

1. Create feature branch: `git checkout -b feature/feature-name`
2. Make changes following structure
3. Run tests: `pytest` (backend) / `npm test` (frontend)
4. Create pull request for review
5. Merge after approval

## Environment Configuration

- Development: `.env`
- Production: Environment variables (Docker secrets)
- Test: `.env.test`

See `.env.example` for all available options.
