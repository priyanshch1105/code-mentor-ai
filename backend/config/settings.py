import os
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Application settings - centralized configuration"""
    
    # Environment
    environment: str = os.getenv("ENVIRONMENT", "development")
    debug: bool = os.getenv("DEBUG", "true").lower() == "true"
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    
    # Database
    database_url: str = os.getenv(
        "DATABASE_URL", 
        "postgresql://user:password@localhost/code_mentor"
    )
    
    # JWT
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY", "your-secret-key-change-in-production")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # API
    api_prefix: str = "/api"
    
    # CORS
    cors_origins: list = os.getenv(
        "CORS_ORIGINS", 
        "http://localhost:5173,http://localhost:3000"
    ).split(",")
    
    # AI Service
    groq_api_key: str = os.getenv("GROQ_API_KEY", "")
    ai_model: str = os.getenv("AI_MODEL", "mixtral-8x7b-32768")
    
    # App
    app_name: str = "Code Mentor AI"
    app_version: str = "1.0.0"
    
    # Features
    max_chat_history: int = 50
    max_file_upload_size: int = 10 * 1024 * 1024  # 10MB
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
