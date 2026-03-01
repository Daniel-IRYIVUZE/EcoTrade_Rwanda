"""
routers/messages.py — Internal messaging
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from utils.deps import get_current_user
import models
import schemas

router = APIRouter(prefix="/api/messages", tags=["messages"])


@router.post("/", response_model=schemas.MessageOut, status_code=201)
def send_message(
    payload: schemas.MessageCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    msg = models.Message(
        from_user_id=current_user.id,
        from_name=current_user.full_name,
        **payload.model_dump(),
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg


@router.get("/inbox", response_model=list[schemas.MessageOut])
def get_inbox(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return (
        db.query(models.Message)
        .filter(models.Message.to_user_id == current_user.id)
        .order_by(models.Message.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


@router.get("/sent", response_model=list[schemas.MessageOut])
def get_sent(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return (
        db.query(models.Message)
        .filter(models.Message.from_user_id == current_user.id)
        .order_by(models.Message.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


@router.get("/{msg_id}", response_model=schemas.MessageOut)
def get_message(
    msg_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    msg = db.query(models.Message).filter(models.Message.id == msg_id).first()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")
    if msg.to_user_id != current_user.id and msg.from_user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    # mark as read if recipient
    if msg.to_user_id == current_user.id and not msg.is_read:
        msg.is_read = True
        db.commit()
        db.refresh(msg)
    return msg


@router.post("/{msg_id}/replies", response_model=schemas.MessageReplyOut, status_code=201)
def reply_to_message(
    msg_id: int,
    payload: schemas.MessageReplyCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    msg = db.query(models.Message).filter(models.Message.id == msg_id).first()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")
    reply = models.MessageReply(
        message_id=msg_id,
        from_user_id=current_user.id,
        from_name=current_user.full_name,
        body=payload.body,
    )
    db.add(reply)
    db.commit()
    db.refresh(reply)
    return reply


@router.patch("/{msg_id}/read", response_model=schemas.MessageOut)
def mark_read(
    msg_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    msg = db.query(models.Message).filter(
        models.Message.id == msg_id,
        models.Message.to_user_id == current_user.id,
    ).first()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")
    msg.is_read = True
    db.commit()
    db.refresh(msg)
    return msg
