"""
routers/collections.py — Collection scheduling & status
"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from utils.deps import get_current_user
import models
import schemas

router = APIRouter(prefix="/api/collections", tags=["collections"])


@router.post("/", response_model=schemas.CollectionOut, status_code=201)
def create_collection(
    payload: schemas.CollectionCreate,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    col = models.Collection(**payload.model_dump())
    db.add(col)
    db.commit()
    db.refresh(col)
    return col


@router.get("/", response_model=list[schemas.CollectionOut])
def list_collections(
    skip: int = 0,
    limit: int = 50,
    status: str | None = None,
    driver_id: int | None = None,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    q = db.query(models.Collection)
    if status:
        q = q.filter(models.Collection.status == status)
    if driver_id:
        q = q.filter(models.Collection.driver_id == driver_id)
    return q.order_by(models.Collection.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{col_id}", response_model=schemas.CollectionOut)
def get_collection(
    col_id: int,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    col = db.query(models.Collection).filter(models.Collection.id == col_id).first()
    if not col:
        raise HTTPException(status_code=404, detail="Collection not found")
    return col


@router.patch("/{col_id}/status", response_model=schemas.CollectionOut)
def update_collection_status(
    col_id: int,
    payload: schemas.CollectionStatusUpdate,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    col = db.query(models.Collection).filter(models.Collection.id == col_id).first()
    if not col:
        raise HTTPException(status_code=404, detail="Collection not found")
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(col, field, value)
    if payload.status == "completed" and not col.completed_at:
        col.completed_at = datetime.utcnow()
        _ensure_payment_for_collection(col, db, current_user)
    db.commit()
    db.refresh(col)
    return col


@router.put("/{col_id}/status", response_model=schemas.CollectionOut)
def update_collection_status_compat(
    col_id: int,
    payload: schemas.CollectionStatusUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return update_collection_status(col_id=col_id, payload=payload, db=db, _=current_user)


def _ensure_payment_for_collection(
    col: models.Collection,
    db: Session,
    current_user: models.User,
):
    existing = db.query(models.Payment).filter(models.Payment.collection_id == col.id).first()
    if existing:
        return

    payee_id = col.driver_id or current_user.id
    payment = models.Payment(
        user_id=payee_id,
        collection_id=col.id,
        amount=col.earnings,
        currency="RWF",
        status=models.PaymentStatus.completed,
        payment_method="mobile_money",
        completed_at=col.completed_at,
    )
    db.add(payment)


@router.delete("/{col_id}", status_code=204)
def delete_collection(
    col_id: int,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    col = db.query(models.Collection).filter(models.Collection.id == col_id).first()
    if not col:
        raise HTTPException(status_code=404, detail="Collection not found")
    db.delete(col)
    db.commit()
