"""WSGI module path expected by `gunicorn your_application.wsgi`."""

from main import app as application

# Optional alias for tools that look for `app`.
app = application
