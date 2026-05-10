"""WSGI entrypoint compatibility shim for Render default startup command."""

from pathlib import Path
import sys

# Ensure backend modules (main.py, routers/, models/, etc.) are importable.
ROOT_DIR = Path(__file__).resolve().parent.parent
BACKEND_DIR = ROOT_DIR / "backend"
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from main import app as application  # noqa: E402

# Optional alias for tooling that expects `app`.
app = application
