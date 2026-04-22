"""
Authentication middleware for JWT token validation
"""
import logging
from fastapi import Request, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthCredentials
from typing import Optional
import jwt
from config.settings import settings

logger = logging.getLogger(__name__)
security = HTTPBearer()


async def verify_token(credentials: HTTPAuthCredentials) -> dict:
    """
    Verify JWT token and return decoded payload
    
    Args:
        credentials: HTTP authentication credentials
        
    Returns:
        Decoded JWT payload
        
    Raises:
        HTTPException: If token is invalid
    """
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm]
        )
        return payload
    except jwt.ExpiredSignatureError:
        logger.warning("Token expired")
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        logger.warning("Invalid token")
        raise HTTPException(status_code=401, detail="Invalid token")


async def get_current_user(request: Request) -> Optional[dict]:
    """Extract and validate user from request"""
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        return None
    
    try:
        scheme, credentials = auth_header.split()
        if scheme.lower() != "bearer":
            return None
        
        payload = jwt.decode(
            credentials,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm]
        )
        return payload
    except (ValueError, jwt.InvalidTokenError):
        return None
