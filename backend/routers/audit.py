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


@router.post("/", response_model=schemas.AuditLogOut, status_code=201)
def create_log_compat(
    payload: schemas.AuditLogCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return create_log(payload=payload, db=db, current_user=current_user)


@router.get("/logs", response_model=list[schemas.AuditLogOut])
def list_logs(
    skip: int = 0,
    limit: int = 100,
    action: str | None = None,
    target: str | None = None,
    db: Session = Depends(get_db),
    _: models.User = Depends(require_admin),
):
    q = db.query(models.AuditLog)
    if action:
        q = q.filter(models.AuditLog.action == action)
    if target:
        q = q.filter(models.AuditLog.target == target)
    return q.order_by(models.AuditLog.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/", response_model=list[schemas.AuditLogOut])
def list_logs_compat(
    skip: int = 0,
    limit: int = 100,
    action: str | None = None,
    target: str | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(require_admin),
):
    return list_logs(skip=skip, limit=limit, action=action, target=target, db=db, _=current_user)
