from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import desc
from db import get_db
from models import User, Session as DBSession, Message
from routers.auth import get_current_user
from services.grok_service import GrokService
from datetime import datetime, timezone

router = APIRouter(prefix="/sessions")

# ✅ Singleton LLM (better performance)
llm_service = GrokService()

def get_llm_service():
    return llm_service


# ------------------ SCHEMAS ------------------ #

class SessionCreate(BaseModel):
    subject: str

class MessageAdd(BaseModel):
    session_id: int
    prompt: str


# ------------------ ROUTES ------------------ #

@router.post("/create")
def create_session(
    body: SessionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        current_user.current_subject = body.subject
        db.commit()
        db.refresh(current_user)

        new_session = DBSession(
            user_id=current_user.id,
            subject=body.subject,
            created_at=datetime.now(timezone.utc),
            name="Untitled Session"
        )

        db.add(new_session)
        db.commit()
        db.refresh(new_session)

        return {
            "session_id": new_session.id,
            "msg": "Session created",
            "subject": body.subject
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/list")
def get_sessions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    sessions = db.query(DBSession)\
        .filter(DBSession.user_id == current_user.id)\
        .order_by(desc(DBSession.created_at))\
        .all()

    return [
        {
            "id": s.id,
            "name": s.name,
            "subject": s.subject,
            "created_at": s.created_at
        }
        for s in sessions
    ]


@router.get("/{session_id}")
def get_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    session = db.query(DBSession)\
        .filter(DBSession.id == session_id, DBSession.user_id == current_user.id)\
        .first()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    return {
        "id": session.id,
        "name": session.name,
        "subject": session.subject,
        "created_at": session.created_at
    }


@router.get("/messages/{session_id}")
def get_messages(
    session_id: int,
    page: int = 1,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    session = db.query(DBSession)\
        .filter(DBSession.id == session_id, DBSession.user_id == current_user.id)\
        .first()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    messages = db.query(Message)\
        .filter(Message.session_id == session_id)\
        .order_by(desc(Message.timestamp))\
        .offset((page - 1) * limit)\
        .limit(limit)\
        .all()

    return [
        {
            "role": m.role,
            "content": m.content,
            "timestamp": m.timestamp
        }
        for m in messages
    ]


@router.post("/add-message")
def add_message(
    body: MessageAdd,
    llm: GrokService = Depends(get_llm_service),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        # ✅ Validate session
        session = db.query(DBSession)\
            .filter(DBSession.id == body.session_id, DBSession.user_id == current_user.id)\
            .first()

        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        # ✅ Save user message
        user_msg = Message(
            session_id=body.session_id,
            role="user",
            content=body.prompt,
            timestamp=datetime.now(timezone.utc)
        )
        db.add(user_msg)

        # ✅ Generate AI response
        response = llm.generate_response(body.prompt, session.subject)

        # ✅ Save assistant response
        assistant_msg = Message(
            session_id=body.session_id,
            role="assistant",
            content=response,
            timestamp=datetime.now(timezone.utc)
        )
        db.add(assistant_msg)

        # ✅ Generate session name (only first message)
        msg_count = db.query(Message)\
            .filter(Message.session_id == body.session_id)\
            .count()

        if msg_count == 0:
            name_prompt = f"Generate 3-5 word title: {body.prompt}"
            session.name = llm.generate_response(name_prompt)[:50]

        # ✅ Update user history (lightweight)
        try:
            hist = current_user.history or []
            hist.append({
                "session_id": body.session_id,
                "subject": session.subject,
                "prompt": body.prompt[:200],
                "response": response[:200],
                "ts": datetime.now(timezone.utc).isoformat()
            })

            current_user.history = hist[-50:]
        except:
            pass

        # ✅ Commit everything together (atomic)
        db.commit()

        return {
            "response": response,
            "session_name": session.name if msg_count == 0 else None
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))