# Quick Reference Guide

## 🚀 Quick Start (3 Steps)

```bash
# 1. Clone & setup
git clone <repo> && cd code-tutor
make setup

# 2. Configure (edit .env with your secrets)
# Add GROQ_API_KEY and other API keys

# 3. Start
make dev
```

**Then visit:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

---

## 🔧 Common Commands

### Development
```bash
make help              # Show all commands
make dev              # Start everything (Docker)
make dev-backend      # Start only backend
make dev-frontend     # Start only frontend
make test             # Run all tests
```

### Code Quality
```bash
make lint             # Check code style
make format           # Auto-format code
make test-backend     # Backend tests only
make test-frontend    # Frontend tests only
```

### Maintenance
```bash
make docker-up        # Start Docker services
make docker-down      # Stop Docker services
make clean            # Remove build artifacts
```

---

## 📁 Where to Find Things

| Looking for... | Location |
|---|---|
| **Authentication Logic** | `backend/services/auth_service.py` |
| **Database Models** | `backend/models/` |
| **API Endpoints** | `backend/routers/` |
| **Chat Component** | `frontend/src/features/chat/` |
| **Quiz Logic** | `frontend/src/features/quiz/` |
| **API Calls** | `frontend/src/services/` |
| **API Documentation** | `docs/API.md` |
| **Setup Instructions** | `docs/SETUP.md` |
| **Contribution Rules** | `docs/CONTRIBUTING.md` |
| **Code Standards** | `docs/GUIDELINES.md` |

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check PostgreSQL is running
# Verify DATABASE_URL in .env
# Run migrations: python -m alembic upgrade head
```

### Frontend won't load
```bash
# Clear node_modules: rm -rf frontend/node_modules
# Reinstall: cd frontend && npm install
# Check VITE_API_URL in .env.local
```

### Port already in use
```bash
# Backend (change 8000):
export BACKEND_PORT=8001
uvicorn main:app --reload --port 8001

# Frontend (change 5173):
export VITE_PORT=5174
npm run dev
```

### Tests failing
```bash
# Clear cache
rm -rf backend/.pytest_cache frontend/.vite

# Reinstall dependencies
pip install -r backend/requirements.txt --force-reinstall
cd frontend && npm install --force
```

---

## 🎯 Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes
- Follow `docs/GUIDELINES.md` for code standards
- Add tests for new features
- Update documentation

### 3. Test Locally
```bash
make lint     # Check code style
make test     # Run tests
make format   # Auto-format
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat(scope): description"
git push origin feature/your-feature-name
```

### 5. Create Pull Request
- GitHub Actions will run tests automatically
- Address any review comments
- Merge after approval

---

## 🔑 Environment Variables

### Required
```
GROQ_API_KEY=your_api_key_here
DATABASE_URL=postgresql://user:pass@localhost/db
JWT_SECRET_KEY=your_secret_key
```

### Optional
```
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
CORS_ORIGINS=http://localhost:5173
```

See `.env.example` for complete list.

---

## 📚 Documentation Map

```
README.md                    ← Start here
├── ARCHITECTURE.md          ← System design
├── PROJECT_STRUCTURE.md     ← Folder layout
├── RESTRUCTURING_SUMMARY.md ← What changed
└── docs/
    ├── SETUP.md            ← How to setup
    ├── API.md              ← API endpoints
    ├── CONTRIBUTING.md     ← How to contribute
    └── GUIDELINES.md       ← Code standards
```

---

## 🔗 Useful Links

- **API Docs**: http://localhost:8000/docs (when running)
- **Frontend**: http://localhost:5173
- **Repository**: Check README.md for links
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

## ✅ Pre-PR Checklist

- [ ] Code follows style guide (`make lint`)
- [ ] Tests pass (`make test`)
- [ ] Tests added for new features
- [ ] `.env` not committed
- [ ] No console.log/print statements
- [ ] Documentation updated
- [ ] No hardcoded values/secrets
- [ ] Branch name follows convention

---

## 🆘 Need Help?

1. **Setup issues** → Read `docs/SETUP.md`
2. **Code standards** → Read `docs/GUIDELINES.md`
3. **API questions** → Check `docs/API.md`
4. **Contributing** → Read `docs/CONTRIBUTING.md`
5. **Still stuck** → Check existing GitHub Issues

---

**For detailed information, see the main documentation files in `/docs`**
