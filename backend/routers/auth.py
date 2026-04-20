"""
Authentication Router
Handles user registration, login, and JWT token management
"""
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from sqlalchemy.orm import Session
from db import get_db
from models.user import User
import bcrypt
import jwt
from config import settings
from datetime import datetime, timedelta, timezone
from logger import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["authentication"])

ALGORITHM = "HS256"

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


class UserCreate(BaseModel):
    """User registration schema"""
    username: str
    email: str
    password: str


class SubjectUpdate(BaseModel):
    """Subject update schema"""
    subject: str


@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user account"""
    # Check if user already exists
    existing_user = db.query(User).filter((User.username == user.username) | (User.email == user.email)).first()
    if existing_user:
        logger.warning(f"Registration attempt with existing username/email: {user.username}")
        raise HTTPException(status_code=400, detail="Username or email already exists")
    
    # Hash password and create user
    hashed_pw = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    db_user = User(username=user.username, email=user.email, password=hashed_pw.decode('utf-8'))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    logger.info(f"New user registered: {db_user.username}")
    return {"message": "User created successfully", "user_id": db_user.id}


@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Authenticate user and receive JWT token"""
    user = db.query(User).filter(User.username == form_data.username).first()
    
    if not user:
        logger.warning(f"Login attempt for non-existent user: {form_data.username}")
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    try:
        stored_hash = user.password.encode('utf-8')
        incoming_password = form_data.password.encode('utf-8')
        password_match = bcrypt.checkpw(incoming_password, stored_hash)
        
        if not password_match:
            logger.warning(f"Failed login attempt for user: {user.username}")
            raise HTTPException(status_code=401, detail="Invalid credentials")
    except Exception as e:
        logger.error(f"Password verification error: {e}")
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token_expires = timedelta(weeks=settings.ACCESS_TOKEN_EXPIRE_WEEKS)
    token = jwt.encode({
        "sub": str(user.id),
        "exp": datetime.now(timezone.utc) + token_expires
    }, settings.SECRET_KEY, algorithm=ALGORITHM)
    
    logger.info(f"User logged in: {user.username}")
    return {"access_token": token, "token_type": "bearer"}


@router.get("/login")
def login_method_help():
    """Return usage instructions when login URL is opened in a browser."""
    return {
        "message": "Login endpoint requires POST",
        "endpoint": "/api/auth/login",
        "method": "POST",
        "content_type": "application/x-www-form-urlencoded",
        "required_fields": ["username", "password"],
    }


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Validate JWT token and return current authenticated user"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        user = db.query(User).filter(User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user
    except jwt.ExpiredSignatureError:
        logger.warning("Expired token used")
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        logger.warning("Invalid token used")
        raise HTTPException(status_code=401, detail="Invalid token")
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid user ID")


@router.get("/me")
def get_me(current_user: User = Depends(get_current_user)):
    """Get current authenticated user's information"""
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "current_subject": current_user.current_subject,
        "progress": current_user.progress
    }


@router.post("/select-subject")
def select_subject(body: SubjectUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Update user's current subject of study"""
    valid_subjects = ["math", "coding", "ielts", "physics"]
    normalized_subject = body.subject.lower()
    if normalized_subject not in valid_subjects:
        raise HTTPException(status_code=400, detail="Invalid subject")
    current_user.current_subject = normalized_subject
    db.commit()
    db.refresh(current_user)
    logger.info(f"User {current_user.id} selected subject: {normalized_subject}")
    return {"message": f"Subject set to {normalized_subject}"}
