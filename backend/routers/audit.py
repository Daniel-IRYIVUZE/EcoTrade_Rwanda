"""
routers/audit.py — Audit log endpoints (admin only)
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from utils.deps import get_current_user, require_admin
import models
import schemas

router = APIRouter(prefix="/api/audit", tags=["audit"])


@router.post("/logs", response_model=schemas.AuditLogOut, status_code=201)
def create_log(
    payload: schemas.AuditLogCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    log = models.AuditLog(
        admin_user_id=current_user.id,
        admin_name=current_user.full_name,
        **payload.model_dump(),
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


@router.get("/logs", response_model=list[schemas.AuditLogOut])
def list_logs(
    skip: int = 0,
    limit: int = 100,
    action: str | None = None,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    q = db.query(models.AuditLog)
    if action:
        q = q.filter(models.AuditLog.action == action)
    return q.order_by(models.AuditLog.created_at.desc()).offset(skip).limit(limit).all()
