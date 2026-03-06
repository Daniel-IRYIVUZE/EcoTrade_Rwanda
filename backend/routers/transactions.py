"""
routers/transactions.py — Transaction CRUD
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from utils.deps import get_current_user, require_admin
import models
import schemas

router = APIRouter(prefix="/api/transactions", tags=["transactions"])


@router.post("/", response_model=schemas.TransactionOut, status_code=201)
def create_transaction(
    payload: schemas.TransactionCreate,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    txn = models.Transaction(**payload.model_dump())
    db.add(txn)
    db.commit()
    db.refresh(txn)
    return txn


@router.get("/", response_model=list[schemas.TransactionOut])
def list_transactions(
    skip: int = 0,
    limit: int = 50,
    status: str | None = None,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    q = db.query(models.Transaction)
    if status:
        q = q.filter(models.Transaction.status == status)
    return q.order_by(models.Transaction.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{txn_id}", response_model=schemas.TransactionOut)
def get_transaction(
    txn_id: int,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    txn = db.query(models.Transaction).filter(models.Transaction.id == txn_id).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return txn


@router.patch("/{txn_id}/status", response_model=schemas.TransactionOut)
def update_transaction_status(
    txn_id: int,
    payload: schemas.TransactionUpdate,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    txn = db.query(models.Transaction).filter(models.Transaction.id == txn_id).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(txn, field, value)
    db.commit()
    db.refresh(txn)
    return txn


@router.put("/{txn_id}", response_model=schemas.TransactionOut)
def update_transaction_status_compat(
    txn_id: int,
    payload: schemas.TransactionUpdate,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    return update_transaction_status(txn_id=txn_id, payload=payload, db=db, _=_)
