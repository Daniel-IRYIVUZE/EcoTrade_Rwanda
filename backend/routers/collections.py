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
    db.commit()
    db.refresh(col)
    return col


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
