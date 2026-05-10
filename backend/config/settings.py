import os
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from dotenv import load_dotenv

load_dotenv()


class Settings(BaseSettings):
    """Application settings - centralized configuration"""

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=False,
        extra="ignore",
    )
    
    # Environment
    environment: str = os.getenv("ENVIRONMENT") or os.getenv("ENV", "development")
    debug: bool = os.getenv("DEBUG", "true").lower() == "true"
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    
    # Database
    database_url: str = os.getenv("DATABASE_URL", "")
    
    # JWT
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY") or os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # API
    api_prefix: str = "/api"
    
    # CORS
    cors_origins: list = os.getenv(
        "CORS_ORIGINS", 
        "http://localhost:5173,https://code-mentor-ai-beta.vercel.app"
    ).split(",")
    
    # AI Service
    groq_api_key: str = os.getenv("GROQ_API_KEY", "")
    ai_model: str = os.getenv("AI_MODEL", "mixtral-8x7b-32768")
    
    # App
    app_name: str = "Code Mentor AI"
    app_version: str = "1.0.0"
    api_description: str = "REST API for AI-powered learning platform"
    cors_origin_regex: str | None = os.getenv("CORS_ORIGIN_REGEX")
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    groq_base_url: str = os.getenv("GROQ_BASE_URL", "https://api.groq.com/openai/v1")
    access_token_expire_weeks: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_WEEKS", "1"))
    
    # Features
    max_chat_history: int = 50
    max_file_upload_size: int = 10 * 1024 * 1024  # 10MB

    # Backward-compatible aliases for legacy uppercase usage across the codebase.
    @property
    def ENV(self) -> str:
        return self.environment

    @property
    def DEBUG(self) -> bool:
        return self.debug

    @property
    def LOG_LEVEL(self) -> str:
        return self.log_level

    @property
    def DATABASE_URL(self) -> str:
        return self.database_url

    @property
    def SECRET_KEY(self) -> str:
        return self.jwt_secret_key

    @property
    def ALGORITHM(self) -> str:
        return self.jwt_algorithm

    @property
    def ACCESS_TOKEN_EXPIRE_WEEKS(self) -> int:
        return self.access_token_expire_weeks

    @property
    def API_TITLE(self) -> str:
        return self.app_name

    @property
    def API_DESCRIPTION(self) -> str:
        return self.api_description

    @property
    def API_VERSION(self) -> str:
        return self.app_version

    @property
    def CORS_ORIGINS(self) -> list:
        return self.cors_origins

    @property
    def CORS_ORIGIN_REGEX(self) -> str | None:
        return self.cors_origin_regex

    @property
    def GROQ_API_KEY(self) -> str:
        return self.groq_api_key

    @property
    def GROQ_BASE_URL(self) -> str:
        return self.groq_base_url

    @property
    def GROK_MODEL(self) -> str:
        return self.ai_model

    @property
    def REDIS_URL(self) -> str:
        return self.redis_url

    @field_validator("database_url")
    @classmethod
    def validate_database_url(cls, value: str) -> str:
        if not value:
            raise ValueError("DATABASE_URL is required and must point to PostgreSQL")

        postgres_prefixes = (
            "postgresql://",
            "postgresql+psycopg2://",
            "postgresql+psycopg://",
            "postgres://",
        )
        if not value.startswith(postgres_prefixes):
            raise ValueError("Only PostgreSQL DATABASE_URL is supported")

        return value
    
settings = Settings()
