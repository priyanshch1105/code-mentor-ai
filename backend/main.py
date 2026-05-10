"""
AI Tutor Platform Backend
REST API for AI-powered learning platform
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from routers import qa, recommend, code_debug, auth, sessions, quiz
from db import engine
from models.base import Base
from models import User, Session, Message, CodeSession, Quiz, QuizQuestion, QuizAttempt, QuizSession
from sqlalchemy import text
from config.settings import settings
from logger import get_logger

logger = get_logger(__name__)

# Create all tables automatically
Base.metadata.create_all(bind=engine)

# Ensure missing columns exist (lightweight migration for 'users.history')
try:
    with engine.connect() as conn:
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS history JSON DEFAULT '[]'::json"))
        conn.execute(text("ALTER TABLE code_sessions ADD COLUMN IF NOT EXISTS response_roman TEXT"))
        conn.execute(text("ALTER TABLE quizzes ADD COLUMN IF NOT EXISTS quiz_type VARCHAR DEFAULT 'mixed'"))
        conn.execute(text("ALTER TABLE quizzes ADD COLUMN IF NOT EXISTS time_limit INTEGER DEFAULT 600"))
        conn.execute(text("ALTER TABLE quizzes ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'active'"))
        conn.execute(text("ALTER TABLE quizzes ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP"))
        conn.execute(text("ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS explanation TEXT"))
        conn.execute(text("ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS difficulty VARCHAR DEFAULT 'beginner'"))
        conn.execute(text("ALTER TABLE quiz_sessions ADD COLUMN IF NOT EXISTS max_possible_score FLOAT DEFAULT 0"))
        conn.execute(text("ALTER TABLE quiz_sessions ADD COLUMN IF NOT EXISTS time_taken INTEGER DEFAULT 0"))
        conn.execute(text("ALTER TABLE quiz_sessions ADD COLUMN IF NOT EXISTS status VARCHAR DEFAULT 'completed'"))
        conn.execute(text("ALTER TABLE quiz_sessions ADD COLUMN IF NOT EXISTS started_at TIMESTAMP"))
        conn.commit()
        logger.info("Database schema verified")
except Exception as e:
    logger.debug(f"Schema update note: {e}")

# Create FastAPI app
app = FastAPI(
    title=settings.API_TITLE,
    description=settings.API_DESCRIPTION,
    version=settings.API_VERSION,
    docs_url="/api/docs",
    openapi_url="/api/openapi.json"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_origin_regex=settings.CORS_ORIGIN_REGEX,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api")
app.include_router(qa.router, prefix="/api")
app.include_router(recommend.router, prefix="/api")
app.include_router(code_debug.router, prefix="/api")
app.include_router(sessions.router, prefix="/api")
app.include_router(quiz.router, prefix="/api")


# ==================== HEALTH CHECK ====================

@app.get("/health", tags=["health"])
def health_check():
    """
    Health check endpoint
    
    Returns status of API and database connection
    """
    try:
        # Test database connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        
        return {
            "status": "healthy",
            "api": "running",
            "database": "connected",
            "environment": settings.ENV,
            "version": settings.API_VERSION
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return JSONResponse(status_code=503, content={
            "status": "unhealthy",
            "api": "running",
            "database": "disconnected",
            "error": str(e)
        })


@app.get("/", tags=["root"])
def root():
    """API root endpoint"""
    return {
        "message": "AI Tutor Platform API",
        "version": settings.API_VERSION,
        "docs": "/api/docs",
        "health": "/health"
    }


# ==================== LIFECYCLE ====================

@app.on_event("startup")
async def startup_event():
    """Application startup event"""
    logger.info(f"Starting AI Tutor Platform API v{settings.API_VERSION}")
    logger.info(f"Environment: {settings.ENV}")
    logger.info(f"Debug mode: {settings.DEBUG}")


@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown event"""
    logger.info("Shutting down AI Tutor Platform API")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )
