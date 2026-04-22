# Contributing Guide

## Code Style

### Python (Backend)

- Follow PEP 8
- Use type hints
- Max line length: 100
- Use black formatter

```bash
# Format code
black backend/

# Check style
flake8 backend/
mypy backend/
```

### JavaScript (Frontend)

- Use ES6+ syntax
- Follow Airbnb style guide
- Use Prettier for formatting

```bash
# Format code
npm run format

# Check linting
npm run lint
```

## Git Workflow

1. Create feature branch
```bash
git checkout -b feature/description
```

2. Make commits with clear messages
```bash
git commit -m "feat: add new feature"
git commit -m "fix: resolve issue"
git commit -m "docs: update readme"
```

3. Push and create PR
```bash
git push origin feature/description
```

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Tests
- `chore`: Build/dependency updates

Example:
```
feat(chat): add message search functionality

Add search across chat history with filters for date and subject.

Closes #123
```

## Testing Requirements

- All features must have tests
- Minimum coverage: 80%
- Run tests before PR submission

```bash
# Backend
pytest --cov

# Frontend
npm run test:coverage
```

## Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change

## Testing Done
- [ ] Tested locally
- [ ] Added tests
- [ ] Updated tests

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review complete
- [ ] Comments added
- [ ] Documentation updated
```

## Code Review Checklist

- [ ] Code follows project standards
- [ ] Tests are comprehensive
- [ ] No performance issues
- [ ] Error handling is proper
- [ ] Security implications checked
- [ ] Documentation is clear

## Deployment

1. Staging deployment: Automatic on PR merge to `develop`
2. Production deployment: Manual from `main` branch

See CI/CD configuration in `.github/workflows/`
