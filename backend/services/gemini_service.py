"""
Compatibility shim: expose `GeminiService` for scripts/tests that expect it.
This maps to the existing `GrokService` implementation used elsewhere.
"""
from .grok_service import GrokService


class GeminiService(GrokService):
    """Thin alias for GrokService to keep older imports working."""
    pass
