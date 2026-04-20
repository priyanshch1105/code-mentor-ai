from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import desc
from datetime import datetime, timezone
import re

from db import get_db
from models.user import User
from models.code_session import CodeSession
from routers.auth import get_current_user
from services.grok_service import GrokService

router = APIRouter(prefix="/code")

# ✅ Singleton LLM
llm_service = GrokService()

def get_llm():
    return llm_service


# ---------------- MODELS ---------------- #

class CodeBody(BaseModel):
    code: str
    language: str = "python"


class CodeSessionResponse(BaseModel):
    session_id: int
    response: str
    session_name: str
    has_error: bool
    error_message: Optional[str] = None


# ---------------- UTIL ---------------- #

def generate_session_name(code: str, language: str) -> str:
    first = code.strip().split("\n")[0]

    if "def " in first:
        m = re.search(r"def\s+(\w+)", first)
        if m:
            return f"{language} function: {m.group(1)}"

    if "class " in first:
        m = re.search(r"class\s+(\w+)", first)
        if m:
            return f"{language} class: {m.group(1)}"

    return f"{language} code snippet"


# ---------------- DEBUG ---------------- #

@router.post("/debug", response_model=CodeSessionResponse)
def debug_code(
    body: CodeBody,
    llm: GrokService = Depends(get_llm),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        if not body.code.strip():
            raise HTTPException(400, "Code cannot be empty")

        session_name = generate_session_name(body.code, body.language)

        # ✅ Grok prompt (clean + structured)
        prompt = f"""
Analyze this {body.language} code.

Return:
1. Errors
2. Fix
3. Explanation

Code:
{body.code}
"""

        try:
            response = llm.generate_response(prompt)
            has_error = "error" in response.lower()
            error_message = None
        except Exception as e:
            response = f"Analysis failed: {str(e)}"
            has_error = True
            error_message = str(e)

        # Save session
        session = CodeSession(
            user_id=current_user.id,
            name=session_name,
            code_input=body.code,
            response=response,
            language=body.language,
            created_at=datetime.now(timezone.utc)
        )

        db.add(session)
        db.commit()
        db.refresh(session)

        return CodeSessionResponse(
            session_id=session.id,
            response=response,
            session_name=session_name,
            has_error=has_error,
            error_message=error_message
        )

    except Exception as e:
        db.rollback()
        raise HTTPException(500, str(e))


# ---------------- HISTORY ---------------- #

@router.get("/sessions")
def get_sessions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    sessions = db.query(CodeSession).filter(
        CodeSession.user_id == current_user.id
    ).order_by(desc(CodeSession.created_at)).all()

    return [
        {
            "id": s.id,
            "name": s.name,
            "language": s.language,
            "created_at": s.created_at
        }
        for s in sessions
    ]


@router.get("/sessions/{session_id}")
def get_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    s = db.query(CodeSession).filter(
        CodeSession.id == session_id,
        CodeSession.user_id == current_user.id
    ).first()

    if not s:
        raise HTTPException(404, "Not found")

    return {
        "id": s.id,
        "code": s.code_input,
        "response": s.response
    }


@router.delete("/sessions/{session_id}")
def delete_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    s = db.query(CodeSession).filter(
        CodeSession.id == session_id,
        CodeSession.user_id == current_user.id
    ).first()

    if not s:
        raise HTTPException(404, "Not found")

    db.delete(s)
    db.commit()

    return {"msg": "deleted"}