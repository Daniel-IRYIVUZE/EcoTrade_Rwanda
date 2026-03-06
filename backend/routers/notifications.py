"""
routers/notifications.py — Notification endpoints
"""
import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from utils.deps import get_current_user, require_admin
import models
import schemas

router = APIRouter(prefix="/api/notifications", tags=["notifications"])


@router.get("/", response_model=list[schemas.NotificationOut])
def list_notifications(
    skip: int = 0,
    limit: int = 50,
    is_read: bool | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.Notification).filter(models.Notification.user_id == current_user.id)
    if is_read is not None:
        q = q.filter(models.Notification.is_read == is_read)
    return q.order_by(models.Notification.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{notification_id}", response_model=schemas.NotificationOut)
def get_notification(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    notification = db.query(models.Notification).filter(models.Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    if notification.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    return notification


@router.post("/", response_model=schemas.NotificationOut, status_code=201)
def create_notification(
    payload: schemas.NotificationCreate,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    data_str = json.dumps(payload.data) if payload.data is not None else None
    notification = models.Notification(
        user_id=payload.user_id,
        title=payload.title,
        body=payload.body,
        type=payload.type,
        data=data_str,
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification


@router.patch("/{notification_id}", response_model=schemas.NotificationOut)
def update_notification(
    notification_id: int,
    payload: schemas.NotificationUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    notification = db.query(models.Notification).filter(models.Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    if notification.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    if payload.is_read is not None:
        notification.is_read = payload.is_read
    db.commit()
    db.refresh(notification)
    return notification


@router.post("/{notification_id}/read", response_model=schemas.NotificationOut)
def mark_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    notification = db.query(models.Notification).filter(models.Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    if notification.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return notification
