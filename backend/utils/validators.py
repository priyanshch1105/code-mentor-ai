"""
Utility functions and validators
"""
import re
import logging
from typing import Optional

logger = logging.getLogger(__name__)


def validate_email(email: str) -> bool:
    """
    Validate email format
    
    Args:
        email: Email address to validate
        
    Returns:
        True if valid, False otherwise
    """
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return re.match(pattern, email) is not None


def validate_password(password: str) -> tuple[bool, Optional[str]]:
    """
    Validate password strength
    
    Args:
        password: Password to validate
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    
    if not re.search(r"[A-Z]", password):
        return False, "Password must contain uppercase letter"
    
    if not re.search(r"[a-z]", password):
        return False, "Password must contain lowercase letter"
    
    if not re.search(r"[0-9]", password):
        return False, "Password must contain number"
    
    return True, None


def sanitize_input(text: str, max_length: int = 1000) -> str:
    """
    Sanitize user input
    
    Args:
        text: Input text to sanitize
        max_length: Maximum allowed length
        
    Returns:
        Sanitized text
    """
    # Remove leading/trailing whitespace
    text = text.strip()
    
    # Truncate if too long
    if len(text) > max_length:
        text = text[:max_length]
    
    # Remove potentially harmful characters
    text = text.replace("\x00", "")
    
    return text
