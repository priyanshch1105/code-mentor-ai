# Frontend - Code Mentor AI

Production-grade React + Vite frontend for Code Mentor AI.

## Structure

```
src/
├── components/      # Reusable UI components
├── features/       # Feature modules
├── services/       # API integration
├── hooks/          # Custom React hooks
├── utils/          # Helper functions
├── styles/         # Global styles
└── App.jsx        # Root component
```

## Key Features

- **Vite** - Fast dev server & optimized builds
- **Tailwind CSS** - Utility-first styling
- **React Router** - Client-side routing
- **Axios** - HTTP client
- **React Toastify** - Notifications
- **Recharts** - Data visualization

## Running

### Local Development

```bash
cd frontend
npm install
npm run dev
```

Open `http://localhost:5173`

### Docker

```bash
docker build -f Dockerfile.dev -t code-mentor-frontend .
docker run -p 5173:5173 code-mentor-frontend
```

### Production Build

```bash
npm run build    # Create optimized bundle
npm run preview  # Preview production build
```

## Testing

```bash
npm test              # Run tests
npm run test:watch   # Watch mode
npm run test:coverage # With coverage
npm run lint         # Lint code
npm run format       # Format code
```

## Configuration

Environment variables (in `.env.local`):

```
VITE_API_URL=http://localhost:8000
VITE_APP_NAME=Code Mentor AI
```

## Project Structure

### Components
Reusable, stateless UI components:
- `Button.jsx` - Custom button component
- `Card.jsx` - Card container
- `Modal.jsx` - Modal dialog

### Features
Self-contained feature modules:
- `auth/` - Authentication
- `chat/` - Chat interface
- `quiz/` - Quiz system
- `code-debug/` - Code debugging

Each feature has:
- `components/` - UI components
- `services/` - API calls
- `hooks/` - Custom hooks

### Services
API integration:
- `api.js` - Axios instance
- `auth.js` - Auth service
- `chat.js` - Chat service

See [Main README](../README.md) for more info.

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.
