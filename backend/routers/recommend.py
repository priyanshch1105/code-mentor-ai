from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from db import get_db
from models.user import User
from routers.auth import get_current_user
from services.grok_service import GrokService
import re

router = APIRouter(prefix="/recommend")

# ✅ Singleton LLM
llm_service = GrokService()

def get_llm_service():
    return llm_service


# ------------------ MODELS ------------------ #

class SubjectSelect(BaseModel):
    subject: str

class ProgressUpdate(BaseModel):
    subject: str
    user_answer: str
    correct_answer: str


# ------------------ RECOMMEND ------------------ #

@router.get("/")
def get_recommendations(
    subject: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    progress = current_user.progress or {}
    current_subject = subject or current_user.current_subject or "general"

    if not progress:
        return {
            "recommendations": f"Start learning {current_subject} by asking basic questions.",
            "progress": progress,
            "current_subject": current_subject
        }

    low_sub = min(progress, key=progress.get)
    score = progress[low_sub]

    if score < 50:
        rec = f"{low_sub} needs improvement ({score:.1f}%). Practice basics."
    elif score < 70:
        rec = f"Good progress in {low_sub}. Try intermediate problems."
    else:
        rec = f"Strong in {low_sub}. Move to advanced topics."

    return {
        "recommendations": rec,
        "progress": progress,
        "current_subject": current_subject
    }


# ------------------ PROGRESS ------------------ #

@router.get("/progress")
def get_progress(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return {"progress": current_user.progress or {}}


# ------------------ UPDATE PROGRESS ------------------ #

@router.post("/update-progress")
def update_progress(
    body: ProgressUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    llm: GrokService = Depends(get_llm_service),
):
    try:
        prompt = f"""
Score this answer from 0 to 100.

User Answer: {body.user_answer}
Correct Answer: {body.correct_answer}

Only return a number.
"""

        response = llm.generate_response(prompt)

        match = re.search(r"\d+", response)
        score = int(match.group(0)) if match else 50

        progress = current_user.progress or {}
        current_score = progress.get(body.subject, 0)

        new_score = (current_score + score) / 2
        progress[body.subject] = new_score

        current_user.progress = progress
        db.commit()

        return {"new_score": new_score}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ------------------ DEPRECATED ------------------ #

@router.post("/select-subject")
def select_subject():
    raise HTTPException(
        status_code=404,
        detail="Use /api/auth/select-subject instead"
    )