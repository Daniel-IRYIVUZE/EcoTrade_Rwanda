"""
routers/insights.py — Green score and analytics endpoints
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from utils.deps import get_current_user
import models

router = APIRouter(prefix="/api", tags=["insights"])


@router.get("/green-score")
def green_score(current_user: models.User = Depends(get_current_user)):
    score = 0.0
    if current_user.hotel_profile:
        score = float(current_user.hotel_profile.green_score or 0.0)
    return {
        "score": score,
        "level": "Gold" if score >= 700 else "Silver" if score >= 400 else "Bronze",
        "breakdown": {
            "collections": 0,
            "listings": 0,
            "ratings": 0,
        },
    }


@router.get("/analytics")
def analytics(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    role = current_user.role

    listings_q = db.query(models.WasteListing)
    bids_q = db.query(models.Bid)
    collections_q = db.query(models.Collection)
    payments_q = db.query(models.Payment)

    if role == models.UserRole.hotel:
        listings_q = listings_q.filter(models.WasteListing.hotel_id == current_user.id)
        bids_q = bids_q.join(models.WasteListing).filter(models.WasteListing.hotel_id == current_user.id)
        collections_q = collections_q.join(models.WasteListing).filter(models.WasteListing.hotel_id == current_user.id)
        payments_q = payments_q.join(models.Collection).join(models.WasteListing).filter(
            models.WasteListing.hotel_id == current_user.id
        )
    elif role == models.UserRole.recycler:
        bids_q = bids_q.filter(models.Bid.recycler_id == current_user.id)
        payments_q = payments_q.filter(models.Payment.user_id == current_user.id)
    elif role == models.UserRole.driver:
        collections_q = collections_q.filter(models.Collection.driver_id == current_user.id)
        payments_q = payments_q.filter(models.Payment.user_id == current_user.id)

    listings_count = listings_q.count()
    bids_count = bids_q.count()
    collections_count = collections_q.count()
    payments_total = payments_q.with_entities(models.Payment.amount).all()
    total_earnings = sum(p[0] for p in payments_total if p[0] is not None)

    return {
        "listings": listings_count,
        "bids": bids_count,
        "collections": collections_count,
        "earnings": total_earnings,
    }
