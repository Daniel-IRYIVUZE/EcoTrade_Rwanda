"""
routers/payments.py — Payment endpoints
"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from utils.deps import get_current_user, require_admin
import models
import schemas

router = APIRouter(prefix="/api/payments", tags=["payments"])


@router.get("/", response_model=list[schemas.PaymentOut])
def list_payments(
    skip: int = 0,
    limit: int = 50,
    status: str | None = None,
    user_id: int | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.Payment)
    if current_user.role != models.UserRole.admin:
        q = q.filter(models.Payment.user_id == current_user.id)
    elif user_id:
        q = q.filter(models.Payment.user_id == user_id)
    if status:
        q = q.filter(models.Payment.status == status)
    return q.order_by(models.Payment.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/summary", response_model=dict)
def payments_summary(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.Payment)
    if current_user.role != models.UserRole.admin:
        q = q.filter(models.Payment.user_id == current_user.id)
    payments = q.all()

    today = datetime.utcnow().date()
    total = sum(p.amount for p in payments)
    today_total = sum(p.amount for p in payments if p.created_at.date() == today)
    week_total = sum(p.amount for p in payments if (today - p.created_at.date()).days <= 7)

    return {"today": today_total, "weekly": week_total, "total": total}


@router.get("/{payment_id}", response_model=schemas.PaymentOut)
def get_payment(
    payment_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    payment = db.query(models.Payment).filter(models.Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    if current_user.role != models.UserRole.admin and payment.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    return payment


@router.post("/", response_model=schemas.PaymentOut, status_code=201)
def create_payment(
    payload: schemas.PaymentCreate,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    payment = models.Payment(**payload.model_dump())
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return payment


@router.patch("/{payment_id}", response_model=schemas.PaymentOut)
def update_payment(
    payment_id: int,
    payload: schemas.PaymentUpdate,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    payment = db.query(models.Payment).filter(models.Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    if payload.status is not None:
        payment.status = payload.status
        if payload.status == models.PaymentStatus.completed.value:
            payment.completed_at = datetime.utcnow()
    if payload.transaction_id is not None:
        payment.transaction_id = payload.transaction_id

    db.commit()
    db.refresh(payment)
    return payment


@router.post("/withdrawal", response_model=dict)
def request_withdrawal(
    payload: dict,
    current_user: models.User = Depends(get_current_user),
):
    amount = payload.get("amount")
    method = payload.get("method", "mobile_money")
    if amount is None:
        raise HTTPException(status_code=400, detail="amount is required")
    return {"message": "Withdrawal request received", "amount": amount, "method": method}
