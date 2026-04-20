"""
Configuration Management
Handles environment variables and app settings
"""
import os
from dotenv import load_dotenv
from enum import Enum

load_dotenv()


def _parse_cors_origins() -> list[str]:
    """Parse comma-separated CORS origins and normalize trailing slashes."""
    raw_origins = os.getenv("CORS_ORIGINS")
    default_origins = [
        "http://localhost:5173",
        "http://localhost:5174",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:5174",
        "http://localhost:3000",
        "https://ai-tutor-ruby-two.vercel.app",
    ]

    origins = raw_origins.split(",") if raw_origins else default_origins
    return [origin.strip().rstrip("/") for origin in origins if origin.strip()]


def _parse_cors_origin_regex() -> str | None:
    """Support local dev ports and Vercel preview domains for browser preflight."""
    return os.getenv(
        "CORS_ORIGIN_REGEX",
        r"https?://(localhost|127\.0\.0\.1)(:\d+)?$|^https://ai-tutor.*\.vercel\.app$",
    )


class Environment(str, Enum):
    """Supported environments"""
    DEVELOPMENT = "development"
    PRODUCTION = "production"
    TESTING = "testing"


class Settings:
    """Application settings from environment variables"""
    
    ENV: str = os.getenv("ENV", "development")
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    API_TITLE: str = "AI Tutor Platform API"
    API_VERSION: str = "1.0.0"
    API_DESCRIPTION: str = "REST API for AI-powered learning platform"
    
    DATABASE_URL: str = os.getenv("DATABASE_URL")
    if not DATABASE_URL:
        raise ValueError(
            "DATABASE_URL environment variable not set. "
            "Expected format: postgresql://user:password@host:port/dbname"
        )
    
    SECRET_KEY: str = os.getenv("SECRET_KEY")
    if not SECRET_KEY:
        raise ValueError("SECRET_KEY environment variable not set")
    
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_WEEKS: int = 1
    
    # External APIs
    GROQ_API_KEY: str = os.getenv("GROQ_API_KEY")
    if not GROQ_API_KEY:
        raise ValueError("GROQ_API_KEY environment variable not set")
    
    GROQ_BASE_URL: str = "https://api.groq.com/openai/v1"
    GROK_MODEL: str = "llama-3.1-8b-instant"  # Using Llama 3.1 8B Instant model
    
    # CORS
    CORS_ORIGINS: list[str] = _parse_cors_origins()
    CORS_ORIGIN_REGEX: str | None = _parse_cors_origin_regex()
    
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO" if ENV == "production" else "DEBUG")
    
    @classmethod
    def validate(cls) -> bool:
        """Validate all required settings are present"""
        required = ["SECRET_KEY", "GROQ_API_KEY", "DATABASE_URL"]
        missing = [attr for attr in required if not os.getenv(attr)]
        
        if missing:
            raise ValueError(f"Missing required environment variables: {', '.join(missing)}")
        
        return True


# Create settings instance
settings = Settings()
