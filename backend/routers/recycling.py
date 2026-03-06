"""
routers/recycling.py — Recycling events
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from utils.deps import get_current_user, require_admin
import models
import schemas

router = APIRouter(prefix="/api/recycling", tags=["recycling"])


@router.post("/events", response_model=schemas.RecyclingEventOut, status_code=201)
def create_event(
    payload: schemas.RecyclingEventCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    event = models.RecyclingEvent(
        user_id=current_user.id,
        user_name=current_user.full_name,
        **payload.model_dump(),
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@router.post("/", response_model=schemas.RecyclingEventOut, status_code=201)
def create_event_compat(
    payload: schemas.RecyclingEventCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return create_event(payload=payload, db=db, current_user=current_user)


@router.get("/events", response_model=list[schemas.RecyclingEventOut])
def list_events(
    skip: int = 0,
    limit: int = 50,
    user_id: int | None = None,
    verified: bool | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.RecyclingEvent)
    if current_user.role not in (models.UserRole.admin, models.UserRole.recycler):
        q = q.filter(models.RecyclingEvent.user_id == current_user.id)
    elif user_id:
        q = q.filter(models.RecyclingEvent.user_id == user_id)
    if verified is not None:
        q = q.filter(models.RecyclingEvent.verified == verified)
    return q.order_by(models.RecyclingEvent.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/", response_model=list[schemas.RecyclingEventOut])
def list_events_compat(
    skip: int = 0,
    limit: int = 50,
    user_id: int | None = None,
    verified: bool | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return list_events(
        skip=skip,
        limit=limit,
        user_id=user_id,
        verified=verified,
        db=db,
        current_user=current_user,
    )


@router.get("/events/{event_id}", response_model=schemas.RecyclingEventOut)
def get_event(
    event_id: int,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    event = db.query(models.RecyclingEvent).filter(models.RecyclingEvent.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.patch("/events/{event_id}/verify", response_model=schemas.RecyclingEventOut)
def verify_event(
    event_id: int,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    event = db.query(models.RecyclingEvent).filter(models.RecyclingEvent.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    event.verified = True
    db.commit()
    db.refresh(event)
    return event


@router.post("/{event_id}/verify", response_model=schemas.RecyclingEventOut)
def verify_event_compat(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(require_admin),
):
    return verify_event(event_id=event_id, db=db, _=current_user)


@router.delete("/events/{event_id}", status_code=204)
def delete_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    event = db.query(models.RecyclingEvent).filter(models.RecyclingEvent.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.user_id != current_user.id and current_user.role != models.UserRole.admin:
        raise HTTPException(status_code=403, detail="Not authorized")
    db.delete(event)
    db.commit()
