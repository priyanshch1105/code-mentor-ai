from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List, Dict, Optional
from datetime import datetime, timezone
import json, re, random

from db import get_db
from models.user import User
from models.quiz import Quiz, QuizQuestion, QuizAttempt, QuizSession
from routers.auth import get_current_user
from services.grok_service import GrokService

router = APIRouter(prefix="/quiz")

# ✅ Singleton LLM
llm_service = GrokService()

def get_llm_service():
    return llm_service


# ---------------- MODELS ---------------- #

class QuizCreate(BaseModel):
    subject: str
    difficulty: str = "beginner"
    quiz_type: str = "mixed"
    total_questions: int = 5


class QuizAnswer(BaseModel):
    question_id: int
    user_answer: str
    time_taken: int = 0


class QuizSubmit(BaseModel):
    quiz_id: int
    answers: List[QuizAnswer]


# ---------------- AI QUESTION GENERATION ---------------- #

def generate_quiz_questions(subject, difficulty, count, llm):
    questions = []

    for i in range(count):
        prompt = f"""
Generate a {difficulty} level {subject} MCQ.

Return JSON:
{{
 "question_text": "...",
 "question_type": "multiple_choice",
 "options": ["A","B","C","D"],
 "correct_answer": "...",
 "explanation": "..."
}}
"""

        try:
            res = llm.generate_response(prompt)
            match = re.search(r"\{.*\}", res, re.DOTALL)

            if match:
                q = json.loads(match.group())
                q["points"] = 10
                questions.append(q)
            else:
                questions.append(fallback_question(subject))

        except:
            questions.append(fallback_question(subject))

    return questions


def fallback_question(subject):
    return {
        "question_text": "What is Python?",
        "question_type": "multiple_choice",
        "options": ["Language", "Animal", "Car", "Game"],
        "correct_answer": "Language",
        "points": 10
    }


# ---------------- SCORING ---------------- #

def calculate_score(answers, questions, llm):
    total = 0
    max_score = 0
    results = []

    for ans in answers:
        q = next((x for x in questions if x.id == ans.question_id), None)
        if not q:
            continue

        max_score += q.points

        if q.question_type == "multiple_choice":
            correct = ans.user_answer.strip().lower() == q.correct_answer.strip().lower()
            score = q.points if correct else 0

        else:
            prompt = f"""
Score answer 0-100.

User: {ans.user_answer}
Correct: {q.correct_answer}
"""
            try:
                res = llm.generate_response(prompt)
                val = int(re.search(r"\d+", res).group())
                score = (val / 100) * q.points
                correct = val >= 70
            except:
                score = 0
                correct = False

        total += score

        results.append({
            "question_id": q.id,
            "is_correct": correct,
            "points": score
        })

    return {
        "total_score": total,
        "max_score": max_score,
        "percentage": (total / max_score * 100) if max_score else 0,
        "results": results
    }


# ---------------- CREATE QUIZ ---------------- #

@router.post("/create")
def create_quiz(
    body: QuizCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    llm: GrokService = Depends(get_llm_service)
):
    quiz = Quiz(
        user_id=current_user.id,
        subject=body.subject,
        title=f"{body.subject} Quiz",
        difficulty=body.difficulty,
        total_questions=body.total_questions
    )

    db.add(quiz)
    db.flush()

    questions = generate_quiz_questions(
        body.subject,
        body.difficulty,
        body.total_questions,
        llm
    )

    for i, q in enumerate(questions):
        db.add(QuizQuestion(
            quiz_id=quiz.id,
            question_text=q["question_text"],
            question_type=q["question_type"],
            options=q.get("options"),
            correct_answer=q["correct_answer"],
            points=q["points"],
            order=i + 1
        ))

    db.commit()

    return {"quiz_id": quiz.id}


# ---------------- GET QUESTIONS ---------------- #

@router.get("/{quiz_id}/questions")
def get_questions(
    quiz_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    quiz = db.query(Quiz).filter(
        Quiz.id == quiz_id,
        Quiz.user_id == current_user.id
    ).first()

    if not quiz:
        raise HTTPException(404, "Quiz not found")

    qs = db.query(QuizQuestion).filter(
        QuizQuestion.quiz_id == quiz_id
    ).all()

    return [{
        "id": q.id,
        "question_text": q.question_text,
        "options": q.options,
        "type": q.question_type
    } for q in qs]


# ---------------- SUBMIT QUIZ ---------------- #

@router.post("/submit")
def submit_quiz(
    body: QuizSubmit,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    llm: GrokService = Depends(get_llm_service)
):
    quiz = db.query(Quiz).filter(
        Quiz.id == body.quiz_id,
        Quiz.user_id == current_user.id
    ).first()

    if not quiz:
        raise HTTPException(404, "Quiz not found")

    questions = db.query(QuizQuestion).filter(
        QuizQuestion.quiz_id == body.quiz_id
    ).all()

    result = calculate_score(body.answers, questions, llm)

    session = QuizSession(
        user_id=current_user.id,
        quiz_id=body.quiz_id,
        total_score=result["total_score"],
        percentage=result["percentage"],
        completed_at=datetime.now(timezone.utc)
    )

    db.add(session)
    db.commit()

    return result


# ---------------- QUIZ HISTORY ---------------- #

@router.get("/history")
def get_quiz_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all quiz sessions for the current user"""
    sessions = db.query(QuizSession).filter(
        QuizSession.user_id == current_user.id
    ).order_by(QuizSession.completed_at.desc()).all()

    return [{
        "id": s.id,
        "quiz_id": s.quiz_id,
        "total_score": s.total_score,
        "percentage": s.percentage,
        "completed_at": s.completed_at.isoformat() if s.completed_at else None
    } for s in sessions]


# ---------------- QUIZ RECOMMENDATIONS ---------------- #

@router.get("/recommendations")
def get_quiz_recommendations(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get personalized quiz recommendations based on user progress"""
    progress = current_user.progress or {}
    
    if not progress:
        return {
            "recommendations": [
                {"subject": "math", "reason": "Start with Basic Math"},
                {"subject": "coding", "reason": "Start with Coding Basics"},
                {"subject": "physics", "reason": "Start with Physics Basics"},
                {"subject": "ielts", "reason": "Start with IELTS Preparation"}
            ],
            "message": "Complete quizzes to get personalized recommendations"
        }
    
    # Find weakest subject
    weakest_subject = min(progress, key=progress.get) if progress else "general"
    weakest_score = progress.get(weakest_subject, 0)
    
    recommendations = []
    
    # Recommend improving weakest area
    if weakest_score < 70:
        recommendations.append({
            "subject": weakest_subject,
            "difficulty": "intermediate",
            "reason": f"Your score in {weakest_subject} is {weakest_score}%. Improve this first!"
        })
    
    # Recommend advancing in strong areas
    for subject, score in progress.items():
        if score >= 70 and subject != weakest_subject:
            difficulty = "advanced" if score >= 85 else "intermediate"
            recommendations.append({
                "subject": subject,
                "difficulty": difficulty,
                "reason": f"You're doing well in {subject}. Try {difficulty} quizzes!"
            })
    
    return {
        "recommendations": recommendations,
        "progress": progress,
        "current_subject": current_user.current_subject or "general"
    }