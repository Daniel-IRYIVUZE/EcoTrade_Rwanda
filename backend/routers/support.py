"""
routers/support.py — Support tickets & responses
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from utils.deps import get_current_user
import models
import schemas

router = APIRouter(prefix="/api/support", tags=["support"])


@router.post("/tickets", response_model=schemas.SupportTicketOut, status_code=201)
def create_ticket(
    payload: schemas.SupportTicketCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    ticket = models.SupportTicket(
        user_id=current_user.id,
        user_name=current_user.full_name,
        **payload.model_dump(),
    )
    db.add(ticket)
    db.commit()
    db.refresh(ticket)
    return ticket


@router.get("/tickets", response_model=list[schemas.SupportTicketOut])
def list_tickets(
    skip: int = 0,
    limit: int = 50,
    status: str | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.SupportTicket)
    if current_user.role != models.UserRole.admin:
        q = q.filter(models.SupportTicket.user_id == current_user.id)
    if status:
        q = q.filter(models.SupportTicket.status == status)
    return q.order_by(models.SupportTicket.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/tickets/{ticket_id}", response_model=schemas.SupportTicketOut)
def get_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    ticket = db.query(models.SupportTicket).filter(models.SupportTicket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    if current_user.role != models.UserRole.admin and ticket.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    return ticket


@router.patch("/tickets/{ticket_id}", response_model=schemas.SupportTicketOut)
def update_ticket(
    ticket_id: int,
    payload: schemas.SupportTicketUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    ticket = db.query(models.SupportTicket).filter(models.SupportTicket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    if current_user.role != models.UserRole.admin and ticket.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(ticket, field, value)
    db.commit()
    db.refresh(ticket)
    return ticket


@router.post("/tickets/{ticket_id}/responses", response_model=schemas.TicketResponseOut, status_code=201)
def add_response(
    ticket_id: int,
    payload: schemas.TicketResponseCreate,
    db: Session = Depends(get_db),
    _: models.User = Depends(get_current_user),
):
    ticket = db.query(models.SupportTicket).filter(models.SupportTicket.id == ticket_id).first()
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    resp = models.TicketResponse(ticket_id=ticket_id, **payload.model_dump())
    db.add(resp)
    if ticket.status == models.TicketStatus.open:
        ticket.status = models.TicketStatus.in_progress
    db.commit()
    db.refresh(resp)
    return resp
