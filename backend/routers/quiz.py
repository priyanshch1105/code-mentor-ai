from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified
from typing import List, Optional
from datetime import datetime, timezone
import json, re

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
    subject: str = Field(..., min_length=2, max_length=40)
    difficulty: str = "beginner"
    quiz_type: str = "mixed"
    total_questions: int = Field(default=10, ge=1, le=20)
    time_limit: int = Field(default=600, ge=60, le=3600)


class QuizAnswer(BaseModel):
    question_id: int
    user_answer: str
    time_taken: int = 0


class QuizSubmit(BaseModel):
    quiz_id: int
    answers: List[QuizAnswer]
    total_time_taken: Optional[int] = 0


# ---------------- AI QUESTION GENERATION ---------------- #

def generate_quiz_questions(subject, difficulty, count, llm):
    questions = []

    for i in range(count):
        prompt = f"""
    Generate a {difficulty} level Code Tutor MCQ focused on programming and coding concepts.

    Return JSON:
    {{
     "question_text": "...",
     "question_type": "multiple_choice",
     "options": ["option 1","option 2","option 3","option 4"],
     "correct_answer": "...",
     "explanation": "..."
    }}
    Rules:
    - correct_answer must exactly match one item from options.
    - Do not include markdown or text outside JSON.
    """

        try:
            res = llm.generate_response(prompt)
            match = re.search(r"\{.*\}", res, re.DOTALL)

            if match:
                q = json.loads(match.group())
                questions.append(normalize_question(q, subject))
            else:
                questions.append(fallback_question(subject, i))

        except:
            questions.append(fallback_question(subject, i))

    return questions


def normalize_subject(subject_str: str) -> str:
    s = (subject_str or '').lower().strip()
    if any(k in s for k in ('code tutor', 'code-tutor', 'coding', 'code')):
        return 'code tutor'
    # default to code tutor for all other subjects
    return 'code tutor'


def normalize_question(question, subject):
    options = question.get("options") or []
    if not isinstance(options, list):
        options = []

    options = [str(option).strip() for option in options if str(option).strip()]
    if len(options) < 2:
        return fallback_question(subject, 0)

    correct_answer = str(question.get("correct_answer") or "").strip()
    if correct_answer not in options:
        correct_answer = options[0]

    return {
        "question_text": str(question.get("question_text") or f"What is important in {subject}?").strip(),
        "question_type": "multiple_choice",
        "options": options[:4],
        "correct_answer": correct_answer,
        "explanation": str(question.get("explanation") or "Review the correct option and compare it with your answer.").strip(),
        "points": 10,
    }


def fallback_question(subject, index=0):
    fallback_questions = [
        {
            "question_text": "What is a fundamental concept in programming?",
            "options": ["Write small functions", "Ignore errors", "Copy-paste code", "Avoid testing"],
            "correct_answer": "Write small functions",
        },
        {
            "question_text": "What is a good first step when learning a new programming topic?",
            "options": ["Understand basics and practice", "Skip practice", "Memorize randomly", "Avoid examples"],
            "correct_answer": "Understand basics and practice",
        },
        {
            "question_text": "Why should you practice coding problems?",
            "options": ["To build skill", "To avoid learning", "To forget concepts", "To waste time"],
            "correct_answer": "To build skill",
        },
    ]
    selected = fallback_questions[index % len(fallback_questions)]
    return {
        "question_text": selected["question_text"],
        "question_type": "multiple_choice",
        "options": selected["options"],
        "correct_answer": selected["correct_answer"],
        "explanation": "This fallback question is used when the AI could not return valid JSON.",
        "points": 10,
    }


# ---------------- SCORING ---------------- #

def calculate_score(answers, questions, llm):
    total = 0
    max_score = 0
    results = []
    answer_map = {answer.question_id: answer for answer in answers}

    for q in questions:
        ans = answer_map.get(q.id)
        max_score += q.points
        user_answer = ans.user_answer if ans else ""
        time_taken = ans.time_taken if ans else 0

        if q.question_type == "multiple_choice":
            correct = user_answer.strip().lower() == q.correct_answer.strip().lower()
            score = q.points if correct else 0

        else:
            prompt = f"""
Score answer 0-100.

User: {user_answer}
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
            "question_text": q.question_text,
            "user_answer": user_answer,
            "correct_answer": q.correct_answer,
            "explanation": q.explanation,
            "is_correct": correct,
            "points_earned": score,
            "max_points": q.points,
            "time_taken": time_taken,
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
    difficulty = body.difficulty.lower().strip()
    if difficulty not in {"beginner", "intermediate", "advanced"}:
        raise HTTPException(status_code=422, detail="difficulty must be beginner, intermediate, or advanced")

    subject = normalize_subject(body.subject)
    quiz = Quiz(
        user_id=current_user.id,
        subject=subject,
        title=f"{difficulty.title()} Code Tutor Quiz",
        difficulty=difficulty,
        quiz_type=body.quiz_type,
        total_questions=body.total_questions,
        time_limit=body.time_limit,
    )

    db.add(quiz)
    db.flush()

    questions = generate_quiz_questions(
        subject,
        difficulty,
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
            explanation=q.get("explanation"),
            difficulty=difficulty,
            points=q["points"],
            order=i + 1
        ))

    db.commit()
    db.refresh(quiz)

    return {
        "quiz_id": quiz.id,
        "title": quiz.title,
        "subject": quiz.subject,
        "difficulty": quiz.difficulty,
        "total_questions": quiz.total_questions,
        "time_limit": quiz.time_limit,
    }


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
    ).order_by(QuizQuestion.order.asc()).all()

    return {
        "quiz_id": quiz.id,
        "title": quiz.title,
        "subject": quiz.subject,
        "difficulty": quiz.difficulty,
        "total_questions": quiz.total_questions,
        "time_limit": quiz.time_limit,
        "questions": [{
            "id": q.id,
            "question_text": q.question_text,
            "question_type": q.question_type,
            "options": q.options or [],
            "points": q.points,
            "order": q.order,
        } for q in qs],
    }


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
    ).order_by(QuizQuestion.order.asc()).all()

    if not questions:
        raise HTTPException(400, "Quiz has no questions")

    result = calculate_score(body.answers, questions, llm)

    db.query(QuizAttempt).filter(
        QuizAttempt.quiz_id == body.quiz_id,
        QuizAttempt.user_id == current_user.id
    ).delete(synchronize_session=False)
    db.query(QuizSession).filter(
        QuizSession.quiz_id == body.quiz_id,
        QuizSession.user_id == current_user.id
    ).delete(synchronize_session=False)

    for item in result["results"]:
        db.add(QuizAttempt(
            quiz_id=body.quiz_id,
            question_id=item["question_id"],
            user_id=current_user.id,
            user_answer=item["user_answer"],
            is_correct=item["is_correct"],
            points_earned=round(item["points_earned"]),
            time_taken=item["time_taken"],
        ))

    session = QuizSession(
        user_id=current_user.id,
        quiz_id=body.quiz_id,
        total_score=result["total_score"],
        max_possible_score=result["max_score"],
        percentage=result["percentage"],
        time_taken=body.total_time_taken or 0,
        status="completed",
        completed_at=datetime.now(timezone.utc)
    )

    quiz.status = "completed"
    quiz.completed_at = datetime.now(timezone.utc)

    progress = current_user.progress or {}
    current_score = float(progress.get(quiz.subject, 0) or 0)
    updated_score = round((current_score * 0.6) + (result["percentage"] * 0.4), 2)
    progress = {**progress, quiz.subject: updated_score}
    current_user.progress = progress
    flag_modified(current_user, "progress")

    db.add(session)
    db.commit()

    correct_answers = sum(1 for item in result["results"] if item["is_correct"])
    total_questions = len(questions)

    return {
        "quiz_id": body.quiz_id,
        "total_score": result["total_score"],
        "max_score": result["max_score"],
        "percentage": result["percentage"],
        "correct_answers": correct_answers,
        "wrong_answers": max(total_questions - correct_answers, 0),
        "total_questions": total_questions,
        "time_taken": body.total_time_taken or 0,
        "detailed_results": result["results"],
        "progress_updated": updated_score,
        "message": f"Your {quiz.subject} progress is now {updated_score}%.",
    }


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

    quiz_history = []
    for s in sessions:
        quiz = s.quiz
        quiz_history.append({
            "id": s.id,
            "quiz_id": s.quiz_id,
            "title": quiz.title if quiz else "Quiz",
            "subject": quiz.subject if quiz else "general",
            "difficulty": quiz.difficulty if quiz else "beginner",
            "score": s.total_score,
            "max_score": s.max_possible_score,
            "total_score": s.total_score,
            "percentage": s.percentage,
            "time_taken": s.time_taken or 0,
            "completed_at": s.completed_at.isoformat() if s.completed_at else None
        })

    return {"quiz_history": quiz_history}


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
                {"subject": "code tutor", "difficulty": "beginner", "quiz_type": "mixed", "reason": "Start with Code Tutor — programming basics"}
            ],
            "message": "Complete quizzes to get personalized recommendations"
        }
    
    # Find weakest subject
    # Prefer recommending Code Tutor; filter progress to only known Code Tutor key
    filtered_keys = [k for k in progress.keys() if 'code' in k]
    weakest_subject = filtered_keys[0] if filtered_keys else 'code tutor'
    weakest_score = progress.get(weakest_subject, 0)
    
    recommendations = []
    
    # Recommend improving weakest area
    if weakest_score < 70:
        recommendations.append({
            "subject": weakest_subject,
            "difficulty": "intermediate",
            "quiz_type": "mixed",
            "reason": f"Your score in {weakest_subject} is {weakest_score}%. Improve this first!"
        })
    
    # Recommend advancing in strong areas
    for subject, score in progress.items():
        # only surface Code Tutor related progression
        if 'code' not in subject:
            continue
        if score >= 70 and subject != weakest_subject:
            difficulty = "advanced" if score >= 85 else "intermediate"
            recommendations.append({
                "subject": subject,
                "difficulty": difficulty,
                "quiz_type": "mixed",
                "reason": f"You're doing well in {subject}. Try {difficulty} quizzes!"
            })
    
    return {
        "recommendations": recommendations,
        "progress": progress,
        "current_subject": current_user.current_subject or "general"
    }
