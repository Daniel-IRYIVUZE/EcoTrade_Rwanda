"""
schemas.py — Pydantic v2 request / response models  (complete)
"""
from __future__ import annotations
import json
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator


# ---------------------------------------------------------------------------
# Registration request
# ---------------------------------------------------------------------------
class RegisterRequest(BaseModel):
    # role tells the server which sub-profile to create
    role: str  # "hotel" | "recycler" | "driver"

    # Common
    full_name: str = Field(alias="fullName")
    email: EmailStr
    phone: Optional[str] = None
    password: str
    confirm_password: str = Field(alias="confirmPassword")

    # Hotel
    business_name: Optional[str] = Field(default=None, alias="businessName")
    registration_number: Optional[str] = Field(default=None, alias="registrationNumber")
    tax_id: Optional[str] = Field(default=None, alias="taxId")
    contact_person: Optional[str] = Field(default=None, alias="contactPerson")
    position: Optional[str] = None

    # Recycler
    company_name: Optional[str] = Field(default=None, alias="companyName")
    license_number: Optional[str] = Field(default=None, alias="licenseNumber")
    waste_types: Optional[List[str]] = Field(default=None, alias="wasteTypes")
    facility_address: Optional[str] = Field(default=None, alias="facilityAddress")
    processing_capacity: Optional[float] = Field(default=None, alias="processingCapacity")

    # Driver
    national_id: Optional[str] = Field(default=None, alias="nationalId")
    vehicle_type: Optional[str] = Field(default=None, alias="vehicleType")
    vehicle_plate: Optional[str] = Field(default=None, alias="vehiclePlate")

    # Location (shared)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    service_radius: Optional[float] = Field(default=None, alias="serviceRadius")
    operating_hours: Optional[str] = Field(default=None, alias="operatingHours")

    model_config = {"populate_by_name": True}

    @field_validator("role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        allowed = {"hotel", "recycler", "driver", "individual"}
        if v not in allowed:
            raise ValueError(f"role must be one of {allowed}")
        return v

    @model_validator(mode="after")
    def passwords_match(self) -> "RegisterRequest":
        if self.password != self.confirm_password:
            raise ValueError("Passwords do not match")
        if len(self.password) < 6:
            raise ValueError("Password must be at least 6 characters")
        return self

    @model_validator(mode="after")
    def role_required_fields(self) -> "RegisterRequest":
        if self.role == "hotel" and not self.business_name:
            raise ValueError("business_name is required for hotel accounts")
        if self.role == "recycler" and not self.company_name:
            raise ValueError("company_name is required for recycler accounts")
        return self


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


# ---------------------------------------------------------------------------
# Sub-profile responses (nested inside UserResponse)
# ---------------------------------------------------------------------------
class HotelProfileOut(BaseModel):
    business_name: str
    registration_number: Optional[str] = None
    tax_id: Optional[str] = None
    contact_person: Optional[str] = None
    position: Optional[str] = None

    model_config = {"from_attributes": True}


class RecyclerProfileOut(BaseModel):
    company_name: str
    license_number: Optional[str] = None
    waste_types: Optional[List[str]] = None
    facility_address: Optional[str] = None
    processing_capacity: Optional[float] = None
    service_radius: Optional[float] = None
    operating_hours: Optional[str] = None

    @field_validator("waste_types", mode="before")
    @classmethod
    def parse_waste_types(cls, v):
        """waste_types is stored as JSON string in DB; decode it."""
        if isinstance(v, str):
            try:
                return json.loads(v)
            except Exception:
                return []
        return v

    model_config = {"from_attributes": True}


class DriverProfileOut(BaseModel):
    national_id: Optional[str] = None
    vehicle_type: Optional[str] = None
    vehicle_plate: Optional[str] = None
    license_image_path: Optional[str] = None
    insurance_image_path: Optional[str] = None
    service_radius: Optional[float] = None
    operating_hours: Optional[str] = None

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# User response
# ---------------------------------------------------------------------------
class UserOut(BaseModel):
    id: int
    full_name: str
    email: str
    phone: Optional[str] = None
    role: str
    status: str
    is_verified: bool
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    created_at: datetime

    hotel_profile: Optional[HotelProfileOut] = None
    recycler_profile: Optional[RecyclerProfileOut] = None
    driver_profile: Optional[DriverProfileOut] = None

    model_config = {"from_attributes": True}


# ---------------------------------------------------------------------------
# Register response
# ---------------------------------------------------------------------------
class RegisterResponse(BaseModel):
    message: str
    user: UserOut


# ---------------------------------------------------------------------------
# Token (for future login endpoint)
# ---------------------------------------------------------------------------
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class TokenData(BaseModel):
    user_id: Optional[int] = None
    role: Optional[str] = None


# ===========================================================
# Waste Listings
# ===========================================================

class WasteListingCreate(BaseModel):
    waste_type: str
    volume: float
    unit: str = "kg"
    quality: str = "A"
    min_bid: float
    reserve_price: Optional[float] = None
    auction_duration: str = "24h"
    auto_accept_above: Optional[float] = None
    special_instructions: Optional[str] = None
    contact_person: Optional[str] = None
    location: Optional[str] = None
    collection_date: Optional[str] = None
    collection_time: Optional[str] = None


class WasteListingUpdate(BaseModel):
    waste_type: Optional[str] = None
    volume: Optional[float] = None
    unit: Optional[str] = None
    quality: Optional[str] = None
    min_bid: Optional[float] = None
    reserve_price: Optional[float] = None
    status: Optional[str] = None
    assigned_recycler: Optional[str] = None
    assigned_driver: Optional[str] = None
    collection_date: Optional[str] = None
    collection_time: Optional[str] = None
    actual_weight: Optional[float] = None


class WasteListingOut(BaseModel):
    id: int
    hotel_id: int
    hotel_name: str
    waste_type: str
    volume: float
    unit: str
    quality: str
    min_bid: float
    reserve_price: Optional[float] = None
    auction_duration: str
    auto_accept_above: Optional[float] = None
    special_instructions: Optional[str] = None
    contact_person: Optional[str] = None
    status: str
    location: Optional[str] = None
    assigned_recycler: Optional[str] = None
    assigned_driver: Optional[str] = None
    collection_date: Optional[str] = None
    collection_time: Optional[str] = None
    actual_weight: Optional[float] = None
    created_at: datetime
    expires_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


# ===========================================================
# Bids
# ===========================================================

class BidCreate(BaseModel):
    amount: float
    note: Optional[str] = None
    collection_preference: Optional[str] = None


class BidUpdate(BaseModel):
    amount: Optional[float] = None
    note: Optional[str] = None
    status: Optional[str] = None


class BidOut(BaseModel):
    id: int
    listing_id: int
    recycler_id: int
    recycler_name: str
    amount: float
    note: Optional[str] = None
    collection_preference: Optional[str] = None
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


# ===========================================================
# Transactions
# ===========================================================

class TransactionCreate(BaseModel):
    listing_id: Optional[int] = None
    from_user: str
    to_user: str
    waste_type: str
    volume: float
    amount: float
    fee: float = 0.0


class TransactionUpdate(BaseModel):
    status: Optional[str] = None
    receipt: Optional[str] = None


class TransactionOut(BaseModel):
    id: int
    listing_id: Optional[int] = None
    from_user: str
    to_user: str
    waste_type: str
    volume: float
    amount: float
    fee: float
    status: str
    created_at: datetime
    receipt: Optional[str] = None

    model_config = {"from_attributes": True}


# ===========================================================
# Collections
# ===========================================================

class CollectionCreate(BaseModel):
    listing_id: Optional[int] = None
    hotel_name: str
    recycler_name: str
    driver_name: str
    driver_id: Optional[int] = None
    waste_type: str
    volume: float
    scheduled_date: str
    scheduled_time: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None
    earnings: float = 0.0


class CollectionStatusUpdate(BaseModel):
    status: str
    actual_weight: Optional[float] = None
    rating: Optional[float] = None
    notes: Optional[str] = None


class CollectionOut(BaseModel):
    id: int
    listing_id: Optional[int] = None
    hotel_name: str
    recycler_name: str
    driver_name: str
    driver_id: Optional[int] = None
    waste_type: str
    volume: float
    status: str
    scheduled_date: str
    scheduled_time: Optional[str] = None
    completed_at: Optional[datetime] = None
    actual_weight: Optional[float] = None
    rating: Optional[float] = None
    notes: Optional[str] = None
    location: Optional[str] = None
    earnings: float
    created_at: datetime

    model_config = {"from_attributes": True}


# ===========================================================
# Support Tickets
# ===========================================================

class SupportTicketCreate(BaseModel):
    subject: str
    message: str
    priority: str = "medium"


class TicketResponseCreate(BaseModel):
    from_name: str
    message: str


class TicketResponseOut(BaseModel):
    id: int
    ticket_id: int
    from_name: str
    message: str
    created_at: datetime

    model_config = {"from_attributes": True}


class SupportTicketOut(BaseModel):
    id: int
    user_id: int
    user_name: str
    subject: str
    message: str
    status: str
    priority: str
    created_at: datetime
    updated_at: datetime
    responses: List[TicketResponseOut] = []

    model_config = {"from_attributes": True}


class SupportTicketUpdate(BaseModel):
    status: Optional[str] = None
    priority: Optional[str] = None


# ===========================================================
# Messages
# ===========================================================

class MessageCreate(BaseModel):
    to_user_id: int
    to_name: str
    subject: str
    body: str


class MessageReplyCreate(BaseModel):
    body: str


class MessageReplyOut(BaseModel):
    id: int
    message_id: int
    from_user_id: int
    from_name: str
    body: str
    created_at: datetime

    model_config = {"from_attributes": True}


class MessageOut(BaseModel):
    id: int
    from_user_id: int
    from_name: str
    to_user_id: int
    to_name: str
    subject: str
    body: str
    is_read: bool
    created_at: datetime
    replies: List[MessageReplyOut] = []

    model_config = {"from_attributes": True}


# ===========================================================
# Driver Routes & Stops
# ===========================================================

class RouteStopCreate(BaseModel):
    hotel_name: str
    location: Optional[str] = None
    waste_type: Optional[str] = None
    volume: Optional[float] = None
    eta: Optional[str] = None
    contact_person: Optional[str] = None
    contact_phone: Optional[str] = None
    special_instructions: Optional[str] = None


class RouteStopStatusUpdate(BaseModel):
    status: str
    actual_weight: Optional[float] = None


class RouteStopOut(BaseModel):
    id: int
    route_id: int
    hotel_name: str
    location: Optional[str] = None
    waste_type: Optional[str] = None
    volume: Optional[float] = None
    eta: Optional[str] = None
    status: str
    contact_person: Optional[str] = None
    contact_phone: Optional[str] = None
    special_instructions: Optional[str] = None
    actual_weight: Optional[float] = None
    completed_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class DriverRouteCreate(BaseModel):
    date: str
    total_distance: float = 0.0
    estimated_earnings: float = 0.0
    start_time: Optional[str] = None
    stops: List[RouteStopCreate] = []


class DriverRouteUpdate(BaseModel):
    status: Optional[str] = None
    end_time: Optional[str] = None
    actual_earnings: Optional[float] = None


class DriverRouteOut(BaseModel):
    id: int
    driver_id: int
    date: str
    status: str
    total_distance: float
    estimated_earnings: float
    actual_earnings: Optional[float] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    created_at: datetime
    stops: List[RouteStopOut] = []

    model_config = {"from_attributes": True}


# ===========================================================
# Recycling Events
# ===========================================================

class RecyclingEventCreate(BaseModel):
    date: str
    waste_type: str
    weight: float
    location: Optional[str] = None
    points: int = 0
    notes: Optional[str] = None


class RecyclingEventOut(BaseModel):
    id: int
    user_id: int
    user_name: str
    date: str
    waste_type: str
    weight: float
    location: Optional[str] = None
    points: int
    notes: Optional[str] = None
    verified: bool
    created_at: datetime

    model_config = {"from_attributes": True}


# ===========================================================
# Audit Logs
# ===========================================================

class AuditLogCreate(BaseModel):
    action: str
    target: str
    details: Optional[str] = None
    status: str = "success"


class AuditLogOut(BaseModel):
    id: int
    admin_user_id: Optional[int] = None
    admin_name: Optional[str] = None
    action: str
    target: str
    details: Optional[str] = None
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


# ===========================================================
# User management (admin)
# ===========================================================

class UserUpdateAdmin(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None
    is_verified: Optional[bool] = None
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class CollectionRatingCreate(BaseModel):
    rating: float
    comment: Optional[str] = None


class LocationUpdate(BaseModel):
    latitude: float
    longitude: float
    address: Optional[str] = None


# ===========================================================
# Drivers
# ===========================================================

class LocationOut(BaseModel):
    latitude: float
    longitude: float
    address: Optional[str] = None


class DriverOut(BaseModel):
    id: str
    user_id: str
    full_name: str
    phone: str
    email: str
    photo_url: Optional[str] = None
    license_plate: str
    vehicle_type: str
    is_available: bool
    rating: float
    total_collections: int
    total_earnings: float
    current_location: Optional[LocationOut] = None
    recycler_id: Optional[str] = None
    is_verified: bool


class DriverLocationOut(BaseModel):
    driver_id: str
    current_location: Optional[LocationOut] = None


# ===========================================================
# Payments
# ===========================================================

class PaymentCreate(BaseModel):
    user_id: int
    collection_id: Optional[int] = None
    amount: float
    currency: str = "RWF"
    payment_method: str = "mobile_money"
    transaction_id: Optional[str] = None


class PaymentUpdate(BaseModel):
    status: Optional[str] = None
    transaction_id: Optional[str] = None


class PaymentOut(BaseModel):
    id: int
    user_id: int
    collection_id: Optional[int] = None
    amount: float
    currency: str
    status: str
    payment_method: str
    transaction_id: Optional[str] = None
    created_at: datetime
    completed_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


# ===========================================================
# Notifications
# ===========================================================

class NotificationCreate(BaseModel):
    user_id: int
    title: str
    body: str
    type: str = "system"
    data: Optional[dict] = None


class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None


class NotificationOut(BaseModel):
    id: int
    user_id: int
    title: str
    body: str
    type: str
    data: Optional[dict] = None
    is_read: bool
    created_at: datetime

    @field_validator("data", mode="before")
    @classmethod
    def parse_data(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except Exception:
                return None
        return v

    model_config = {"from_attributes": True}
