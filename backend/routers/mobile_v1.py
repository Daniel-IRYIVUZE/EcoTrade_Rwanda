"""
routers/mobile_v1.py — Mobile v1 API endpoints (/api/v1)
"""
from __future__ import annotations

from datetime import datetime, timedelta
import json
import math
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from utils.deps import get_current_user
from utils.security import create_access_token, hash_password, verify_password
import models
import schemas

router = APIRouter(prefix="/api/v1", tags=["mobile-v1"])

_DURATION_MAP = {"24h": 1, "48h": 2, "72h": 3, "7d": 7}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def _combine_datetime(date_str: Optional[str], time_str: Optional[str]) -> str:
    if date_str:
        time_part = time_str or "00:00"
        try:
            return datetime.fromisoformat(f"{date_str}T{time_part}").isoformat()
        except ValueError:
            pass
    return datetime.utcnow().isoformat()


def _ensure_payment_for_collection(
    collection: models.Collection,
    db: Session,
    current_user: models.User,
):
    existing = db.query(models.Payment).filter(models.Payment.collection_id == collection.id).first()
    if existing:
        return

    payee_id = collection.driver_id or current_user.id
    payment = models.Payment(
        user_id=payee_id,
        collection_id=collection.id,
        amount=collection.earnings,
        currency="RWF",
        status=models.PaymentStatus.completed,
        payment_method="mobile_money",
        completed_at=collection.completed_at,
    )
    db.add(payment)

# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

@router.post("/auth/login", response_model=schemas.Token)
def mobile_login(payload: schemas.LoginRequest, db: Session = Depends(get_db)) -> schemas.Token:
    user = db.query(models.User).filter(models.User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token({"sub": str(user.id), "role": user.role.value, "email": user.email})
    return schemas.Token(access_token=token, token_type="bearer", user=schemas.UserOut.model_validate(user))


@router.post("/auth/register", response_model=schemas.RegisterResponse, status_code=status.HTTP_201_CREATED)
def mobile_register(payload: schemas.RegisterRequest, db: Session = Depends(get_db)) -> schemas.RegisterResponse:
    allowed_roles = {"hotel", "recycler", "driver", "individual"}
    if payload.role not in allowed_roles:
        raise HTTPException(status_code=400, detail=f"role must be one of {allowed_roles}")
    if payload.password != payload.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")
    if len(payload.password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

    existing = db.query(models.User).filter(models.User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="An account with this email already exists")

    user = models.User(
        full_name=payload.full_name,
        email=payload.email,
        phone=payload.phone,
        hashed_password=hash_password(payload.password),
        role=models.UserRole(payload.role),
        status=models.UserStatus.pending,
        is_verified=False,
        latitude=payload.latitude,
        longitude=payload.longitude,
    )
    db.add(user)
    db.flush()

    if payload.role == "hotel":
        if not payload.business_name:
            raise HTTPException(status_code=400, detail="businessName is required for hotel accounts")
        db.add(models.HotelProfile(
            user_id=user.id,
            business_name=payload.business_name,
            registration_number=payload.registration_number,
            tax_id=payload.tax_id,
            contact_person=payload.contact_person,
            position=payload.position,
        ))
    elif payload.role == "recycler":
        if not payload.company_name:
            raise HTTPException(status_code=400, detail="companyName is required for recycler accounts")
        db.add(models.RecyclerProfile(
            user_id=user.id,
            company_name=payload.company_name,
            license_number=payload.license_number,
            waste_types=json.dumps(payload.waste_types) if payload.waste_types else None,
            facility_address=payload.facility_address,
            processing_capacity=payload.processing_capacity,
            service_radius=payload.service_radius,
            operating_hours=payload.operating_hours,
        ))
    elif payload.role == "driver":
        db.add(models.DriverProfile(
            user_id=user.id,
            national_id=payload.national_id,
            vehicle_type=payload.vehicle_type,
            vehicle_plate=payload.vehicle_plate,
            service_radius=payload.service_radius,
            operating_hours=payload.operating_hours,
        ))

    db.commit()
    db.refresh(user)
    return schemas.RegisterResponse(
        message="Account created successfully. Your account is pending review.",
        user=schemas.UserOut.model_validate(user),
    )


@router.post("/auth/logout", response_model=dict)
def mobile_logout() -> dict:
    return {"message": "Logged out"}


@router.post("/auth/forgot-password", response_model=dict)
def mobile_forgot_password() -> dict:
    return {"message": "If the account exists, a reset email will be sent."}


@router.post("/auth/verify-email", response_model=schemas.UserOut)
def mobile_verify_email(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)) -> schemas.UserOut:
    current_user.is_verified = True
    db.commit()
    db.refresh(current_user)
    return schemas.UserOut.model_validate(current_user)


@router.post("/auth/refresh", response_model=schemas.Token)
def mobile_refresh_token(current_user: models.User = Depends(get_current_user)) -> schemas.Token:
    token = create_access_token({"sub": str(current_user.id), "role": current_user.role.value, "email": current_user.email})
    return schemas.Token(access_token=token, token_type="bearer", user=schemas.UserOut.model_validate(current_user))


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------

@router.get("/users/profile", response_model=schemas.UserOut)
def mobile_get_profile(current_user: models.User = Depends(get_current_user)) -> schemas.UserOut:
    return schemas.UserOut.model_validate(current_user)


@router.put("/users/profile", response_model=schemas.UserOut)
def mobile_update_profile(
    payload: schemas.UserUpdateAdmin,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(current_user, field, value)

    db.commit()
    db.refresh(current_user)
    return schemas.UserOut.model_validate(current_user)


# ---------------------------------------------------------------------------
# Listings
# ---------------------------------------------------------------------------

@router.get("/listings", response_model=list[schemas.WasteListingOut])
def mobile_listings(
    status: Optional[str] = None,
    waste_type: Optional[str] = None,
    hotel_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.WasteListing)
    if status:
        q = q.filter(models.WasteListing.status == status)
    if waste_type:
        q = q.filter(models.WasteListing.waste_type == waste_type)
    if hotel_id:
        q = q.filter(models.WasteListing.hotel_id == hotel_id)
    return q.order_by(models.WasteListing.created_at.desc()).all()


@router.get("/listings/{listing_id}", response_model=schemas.WasteListingOut)
def mobile_get_listing(
    listing_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    listing = db.query(models.WasteListing).filter(models.WasteListing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return listing


@router.post("/listings", response_model=schemas.WasteListingOut, status_code=201)
def mobile_create_listing(
    payload: schemas.WasteListingCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    days = _DURATION_MAP.get(payload.auction_duration, 1)
    hotel_name = current_user.hotel_profile.business_name if current_user.hotel_profile else current_user.full_name
    listing = models.WasteListing(
        hotel_id=current_user.id,
        hotel_name=hotel_name,
        expires_at=datetime.utcnow() + timedelta(days=days),
        **payload.model_dump(),
    )
    db.add(listing)
    db.commit()
    db.refresh(listing)
    return listing


@router.put("/listings/{listing_id}", response_model=schemas.WasteListingOut)
def mobile_update_listing(
    listing_id: int,
    payload: schemas.WasteListingUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    listing = db.query(models.WasteListing).filter(models.WasteListing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.hotel_id != current_user.id and current_user.role != models.UserRole.admin:
        raise HTTPException(status_code=403, detail="Not authorized")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(listing, field, value)

    db.commit()
    db.refresh(listing)
    return listing


@router.delete("/listings/{listing_id}", status_code=204)
def mobile_delete_listing(
    listing_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    listing = db.query(models.WasteListing).filter(models.WasteListing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.hotel_id != current_user.id and current_user.role != models.UserRole.admin:
        raise HTTPException(status_code=403, detail="Not authorized")
    db.delete(listing)
    db.commit()


@router.get("/listings/nearby", response_model=list[schemas.WasteListingOut])
def mobile_nearby_listings(
    lat: float,
    lng: float,
    radius: float = 5.0,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    listings = (
        db.query(models.WasteListing, models.User)
        .join(models.User, models.WasteListing.hotel_id == models.User.id)
        .filter(models.WasteListing.status == models.ListingStatus.open)
        .all()
    )

    nearby = []
    for listing, hotel in listings:
        if hotel.latitude is None or hotel.longitude is None:
            continue
        distance = _haversine_km(lat, lng, hotel.latitude, hotel.longitude)
        if distance <= radius:
            nearby.append(listing)
    return nearby


# ---------------------------------------------------------------------------
# Bids
# ---------------------------------------------------------------------------

@router.get("/bids", response_model=list[schemas.BidOut])
def mobile_list_bids(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return db.query(models.Bid).filter(models.Bid.recycler_id == current_user.id).all()


@router.post("/bids", response_model=schemas.BidOut, status_code=201)
def mobile_place_bid(
    listing_id: int,
    payload: schemas.BidCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    listing = db.query(models.WasteListing).filter(models.WasteListing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.status != models.ListingStatus.open:
        raise HTTPException(status_code=400, detail="Listing is not open for bidding")

    recycler_name = current_user.recycler_profile.company_name if current_user.recycler_profile else current_user.full_name
    bid = models.Bid(
        listing_id=listing.id,
        recycler_id=current_user.id,
        recycler_name=recycler_name,
        **payload.model_dump(),
    )
    db.add(bid)
    db.commit()
    db.refresh(bid)
    return bid


@router.get("/bids/{bid_id}", response_model=schemas.BidOut)
def mobile_get_bid(
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    bid = db.query(models.Bid).filter(models.Bid.id == bid_id).first()
    if not bid:
        raise HTTPException(status_code=404, detail="Bid not found")
    return bid


@router.patch("/bids/{bid_id}", response_model=schemas.BidOut)
def mobile_update_bid(
    bid_id: int,
    payload: schemas.BidUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    bid = db.query(models.Bid).filter(models.Bid.id == bid_id).first()
    if not bid:
        raise HTTPException(status_code=404, detail="Bid not found")
    if bid.recycler_id != current_user.id and current_user.role != models.UserRole.admin:
        raise HTTPException(status_code=403, detail="Not authorized")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(bid, field, value)

    db.commit()
    db.refresh(bid)
    return bid


@router.get("/listings/{listing_id}/bids", response_model=list[schemas.BidOut])
def mobile_listing_bids(
    listing_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    return db.query(models.Bid).filter(models.Bid.listing_id == listing_id).all()


@router.post("/listings/{listing_id}/bids/{bid_id}/accept", response_model=schemas.BidOut)
def mobile_accept_bid(
    listing_id: int,
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    listing = db.query(models.WasteListing).filter(models.WasteListing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.hotel_id != current_user.id and current_user.role != models.UserRole.admin:
        raise HTTPException(status_code=403, detail="Not authorized")

    bid = db.query(models.Bid).filter(
        models.Bid.id == bid_id, models.Bid.listing_id == listing_id
    ).first()
    if not bid:
        raise HTTPException(status_code=404, detail="Bid not found")

    bid.status = models.BidStatus.won
    db.query(models.Bid).filter(
        models.Bid.listing_id == listing_id, models.Bid.id != bid_id
    ).update({"status": models.BidStatus.lost})
    listing.status = models.ListingStatus.assigned
    listing.assigned_recycler = bid.recycler_name

    db.commit()
    db.refresh(bid)
    return bid


# ---------------------------------------------------------------------------
# Collections
# ---------------------------------------------------------------------------

@router.get("/collections", response_model=list[schemas.CollectionOut])
def mobile_list_collections(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.Collection)
    if current_user.role == models.UserRole.driver:
        q = q.filter(models.Collection.driver_id == current_user.id)
    return q.order_by(models.Collection.created_at.desc()).all()


@router.get("/collections/active", response_model=list[schemas.CollectionOut])
def mobile_active_collections(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    active_statuses = [models.CollectionStatus.scheduled, models.CollectionStatus.en_route, models.CollectionStatus.collected]
    q = db.query(models.Collection).filter(models.Collection.status.in_(active_statuses))
    if current_user.role == models.UserRole.driver:
        q = q.filter(models.Collection.driver_id == current_user.id)
    return q.order_by(models.Collection.created_at.desc()).all()


@router.get("/collections/{collection_id}", response_model=schemas.CollectionOut)
def mobile_get_collection(
    collection_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    collection = db.query(models.Collection).filter(models.Collection.id == collection_id).first()
    if not collection:
        raise HTTPException(status_code=404, detail="Collection not found")
    return collection


@router.patch("/collections/{collection_id}", response_model=schemas.CollectionOut)
def mobile_update_collection(
    collection_id: int,
    payload: schemas.CollectionStatusUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    collection = db.query(models.Collection).filter(models.Collection.id == collection_id).first()
    if not collection:
        raise HTTPException(status_code=404, detail="Collection not found")

    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(collection, field, value)
    if payload.status == "completed" and not collection.completed_at:
        collection.completed_at = datetime.utcnow()
        _ensure_payment_for_collection(collection, db, current_user)

    db.commit()
    db.refresh(collection)
    return collection


@router.post("/collections/{collection_id}/rate", response_model=dict)
def mobile_rate_collection(
    collection_id: int,
    payload: schemas.CollectionRatingCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    collection = db.query(models.Collection).filter(models.Collection.id == collection_id).first()
    if not collection:
        raise HTTPException(status_code=404, detail="Collection not found")
    collection.rating = payload.rating
    if payload.comment:
        collection.notes = payload.comment
    db.commit()
    db.refresh(collection)
    return {"message": "Rating submitted"}


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@router.get("/routes", response_model=list[schemas.DriverRouteOut])
def mobile_list_routes(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.DriverRoute)
    if current_user.role == models.UserRole.driver:
        q = q.filter(models.DriverRoute.driver_id == current_user.id)
    return q.order_by(models.DriverRoute.created_at.desc()).all()


@router.get("/routes/{route_id}", response_model=schemas.DriverRouteOut)
def mobile_get_route(
    route_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    route = db.query(models.DriverRoute).filter(models.DriverRoute.id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    return route


# ---------------------------------------------------------------------------
# Payments
# ---------------------------------------------------------------------------

@router.get("/payments", response_model=list[schemas.PaymentOut])
def mobile_list_payments(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.Payment)
    if current_user.role != models.UserRole.admin:
        q = q.filter(models.Payment.user_id == current_user.id)
    payments = q.order_by(models.Payment.created_at.desc()).all()
    return payments


@router.get("/payments/summary", response_model=dict)
def mobile_payments_summary(
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


@router.post("/payments/withdrawal", response_model=dict)
def mobile_withdrawal(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    amount = payload.get("amount")
    method = payload.get("method", "mobile_money")
    if amount is None:
        raise HTTPException(status_code=400, detail="amount is required")

    payment = models.Payment(
        user_id=current_user.id,
        collection_id=None,
        amount=float(amount),
        currency="RWF",
        status=models.PaymentStatus.pending,
        payment_method=method,
    )
    db.add(payment)

    notification = models.Notification(
        user_id=current_user.id,
        title="Withdrawal Requested",
        body=f"Withdrawal request for {amount} {payment.currency} submitted.",
        type=models.NotificationType.system,
        data=json.dumps({"amount": amount, "method": method}),
    )
    db.add(notification)

    db.commit()
    return {"message": "Withdrawal request received"}


# ---------------------------------------------------------------------------
# Drivers
# ---------------------------------------------------------------------------

@router.get("/drivers", response_model=list[schemas.DriverOut])
def mobile_list_drivers(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    drivers = db.query(models.User).filter(models.User.role == models.UserRole.driver).all()
    results = []
    for user in drivers:
        profile = user.driver_profile
        results.append({
            "id": str(profile.id) if profile else str(user.id),
            "user_id": str(user.id),
            "full_name": user.full_name,
            "phone": user.phone or "",
            "email": user.email,
            "photo_url": user.avatar,
            "license_plate": profile.vehicle_plate if profile else "",
            "vehicle_type": profile.vehicle_type if profile else "",
            "is_available": user.status == models.UserStatus.active,
            "rating": float(profile.rating if profile else 0.0),
            "total_collections": int(profile.completed_routes if profile else 0),
            "total_earnings": float(profile.total_earnings if profile else 0.0),
            "current_location": {
                "latitude": user.latitude or 0.0,
                "longitude": user.longitude or 0.0,
                "address": user.location,
            } if user.latitude is not None and user.longitude is not None else None,
            "recycler_id": None,
            "is_verified": user.is_verified,
        })
    return results


@router.get("/drivers/{driver_id}", response_model=schemas.DriverOut)
def mobile_get_driver(
    driver_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    user = db.query(models.User).filter(models.User.id == driver_id).first()
    if not user:
        profile = db.query(models.DriverProfile).filter(models.DriverProfile.id == driver_id).first()
        if profile:
            user = db.query(models.User).filter(models.User.id == profile.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Driver not found")

    profile = user.driver_profile
    return {
        "id": str(profile.id) if profile else str(user.id),
        "user_id": str(user.id),
        "full_name": user.full_name,
        "phone": user.phone or "",
        "email": user.email,
        "photo_url": user.avatar,
        "license_plate": profile.vehicle_plate if profile else "",
        "vehicle_type": profile.vehicle_type if profile else "",
        "is_available": user.status == models.UserStatus.active,
        "rating": float(profile.rating if profile else 0.0),
        "total_collections": int(profile.completed_routes if profile else 0),
        "total_earnings": float(profile.total_earnings if profile else 0.0),
        "current_location": {
            "latitude": user.latitude or 0.0,
            "longitude": user.longitude or 0.0,
            "address": user.location,
        } if user.latitude is not None and user.longitude is not None else None,
        "recycler_id": None,
        "is_verified": user.is_verified,
    }


@router.get("/drivers/location", response_model=list[schemas.DriverLocationOut])
def mobile_driver_locations(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    drivers = db.query(models.User).filter(models.User.role == models.UserRole.driver).all()
    return [
        {
            "driver_id": str(u.id),
            "current_location": {
                "latitude": u.latitude or 0.0,
                "longitude": u.longitude or 0.0,
                "address": u.location,
            } if u.latitude is not None and u.longitude is not None else None,
        }
        for u in drivers
    ]


@router.patch("/drivers/location", response_model=dict)
def mobile_update_driver_location(
    payload: schemas.LocationUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    current_user.latitude = payload.latitude
    current_user.longitude = payload.longitude
    current_user.location = payload.address
    db.commit()
    db.refresh(current_user)
    return {"message": "Location updated"}


# ---------------------------------------------------------------------------
# Notifications, Green Score, Analytics
# ---------------------------------------------------------------------------

@router.get("/notifications", response_model=list[schemas.NotificationOut])
def mobile_notifications(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
) -> list[MobileNotification]:
    notifications = (
        db.query(models.Notification)
        .filter(models.Notification.user_id == current_user.id)
        .order_by(models.Notification.created_at.desc())
        .all()
    )
    return notifications


@router.get("/notifications/{notification_id}", response_model=schemas.NotificationOut)
def mobile_get_notification(
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


@router.patch("/notifications/{notification_id}", response_model=schemas.NotificationOut)
def mobile_update_notification(
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


@router.post("/notifications/{notification_id}/read", response_model=schemas.NotificationOut)
def mobile_mark_notification_read(
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


@router.get("/green-score", response_model=dict)
def mobile_green_score(current_user: models.User = Depends(get_current_user)) -> dict:
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


@router.get("/analytics", response_model=dict)
def mobile_analytics(
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
