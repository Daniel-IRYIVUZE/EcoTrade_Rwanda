"""
models.py — All SQLAlchemy ORM models for EcoTrade Rwanda
"""
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Float, Boolean,
    DateTime, Text, ForeignKey, Enum as SAEnum
)
from sqlalchemy.orm import relationship
from database import Base
import enum


# ============================================================
# Enums
# ============================================================

class UserRole(str, enum.Enum):
    hotel      = "hotel"
    recycler   = "recycler"
    driver     = "driver"
    individual = "individual"
    admin      = "admin"

class UserStatus(str, enum.Enum):
    pending   = "pending"
    active    = "active"
    suspended = "suspended"

class ListingStatus(str, enum.Enum):
    open      = "open"
    assigned  = "assigned"
    collected = "collected"
    completed = "completed"
    cancelled = "cancelled"
    expired   = "expired"
    draft     = "draft"

class BidStatus(str, enum.Enum):
    active    = "active"
    won       = "won"
    lost      = "lost"
    withdrawn = "withdrawn"

class TransactionStatus(str, enum.Enum):
    pending   = "pending"
    completed = "completed"
    disputed  = "disputed"
    refunded  = "refunded"

class CollectionStatus(str, enum.Enum):
    scheduled = "scheduled"
    en_route  = "en-route"
    collected = "collected"
    verified  = "verified"
    completed = "completed"
    missed    = "missed"

class TicketStatus(str, enum.Enum):
    open        = "open"
    in_progress = "in-progress"
    resolved    = "resolved"
    closed      = "closed"

class TicketPriority(str, enum.Enum):
    low    = "low"
    medium = "medium"
    high   = "high"
    urgent = "urgent"

class RouteStatus(str, enum.Enum):
    pending     = "pending"
    in_progress = "in-progress"
    completed   = "completed"

class StopStatus(str, enum.Enum):
    pending    = "pending"
    arrived    = "arrived"
    collecting = "collecting"
    completed  = "completed"
    skipped    = "skipped"

class AuditAction(str, enum.Enum):
    create = "create"
    read   = "read"
    update = "update"
    delete = "delete"


# ============================================================
# Users & sub-profiles
# ============================================================

class User(Base):
    __tablename__ = "users"

    id              = Column(Integer, primary_key=True, index=True)
    full_name       = Column(String(120), nullable=False)
    email           = Column(String(255), unique=True, index=True, nullable=False)
    phone           = Column(String(30),  nullable=True)
    hashed_password = Column(String(256), nullable=False)
    role            = Column(SAEnum(UserRole),   nullable=False)
    status          = Column(SAEnum(UserStatus), default=UserStatus.pending, nullable=False)
    is_verified     = Column(Boolean, default=False)
    avatar          = Column(String(500), nullable=True)
    latitude        = Column(Float,       nullable=True)
    longitude       = Column(Float,       nullable=True)
    location        = Column(String(200), nullable=True)
    created_at      = Column(DateTime, default=datetime.utcnow)
    updated_at      = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    hotel_profile    = relationship("HotelProfile",    back_populates="user", uselist=False, cascade="all, delete-orphan")
    recycler_profile = relationship("RecyclerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    driver_profile   = relationship("DriverProfile",   back_populates="user", uselist=False, cascade="all, delete-orphan")
    listings         = relationship("WasteListing",    back_populates="hotel", foreign_keys="WasteListing.hotel_id")
    bids             = relationship("Bid",             back_populates="recycler", foreign_keys="Bid.recycler_id")
    sent_messages    = relationship("Message",         back_populates="sender",    foreign_keys="Message.from_user_id")
    recv_messages    = relationship("Message",         back_populates="recipient", foreign_keys="Message.to_user_id")
    support_tickets  = relationship("SupportTicket",   back_populates="user")
    recycling_events = relationship("RecyclingEvent",  back_populates="user")
    driver_routes    = relationship("DriverRoute",     back_populates="driver")
    audit_logs       = relationship("AuditLog",        back_populates="admin_user_rel", foreign_keys="AuditLog.admin_user_id")

    def __repr__(self):
        return f"<User id={self.id} email={self.email} role={self.role}>"


class HotelProfile(Base):
    __tablename__ = "hotel_profiles"

    id                  = Column(Integer, primary_key=True, index=True)
    user_id             = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    business_name       = Column(String(200), nullable=False)
    registration_number = Column(String(100), nullable=True)
    tax_id              = Column(String(100), nullable=True)
    contact_person      = Column(String(120), nullable=True)
    position            = Column(String(120), nullable=True)
    green_score         = Column(Float, default=0.0)
    monthly_waste       = Column(Float, default=0.0)
    total_revenue       = Column(Float, default=0.0)

    user = relationship("User", back_populates="hotel_profile")


class RecyclerProfile(Base):
    __tablename__ = "recycler_profiles"

    id                  = Column(Integer, primary_key=True, index=True)
    user_id             = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    company_name        = Column(String(200), nullable=False)
    license_number      = Column(String(100), nullable=True)
    waste_types         = Column(Text,        nullable=True)   # JSON list
    facility_address    = Column(String(300), nullable=True)
    processing_capacity = Column(Float,       nullable=True)
    service_radius      = Column(Float,       nullable=True)
    operating_hours     = Column(String(100), nullable=True)
    rating              = Column(Float, default=0.0)
    total_revenue       = Column(Float, default=0.0)

    user = relationship("User", back_populates="recycler_profile")


class DriverProfile(Base):
    __tablename__ = "driver_profiles"

    id                   = Column(Integer, primary_key=True, index=True)
    user_id              = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    national_id          = Column(String(20),  nullable=True)
    vehicle_type         = Column(String(50),  nullable=True)
    vehicle_plate        = Column(String(30),  nullable=True)
    license_image_path   = Column(String(500), nullable=True)
    insurance_image_path = Column(String(500), nullable=True)
    service_radius       = Column(Float,       nullable=True)
    operating_hours      = Column(String(100), nullable=True)
    rating               = Column(Float,   default=0.0)
    completed_routes     = Column(Integer, default=0)
    total_earnings       = Column(Float,   default=0.0)

    user = relationship("User", back_populates="driver_profile")


# ============================================================
# Waste Listings & Bids
# ============================================================

class WasteListing(Base):
    __tablename__ = "waste_listings"

    id                   = Column(Integer, primary_key=True, index=True)
    hotel_id             = Column(Integer, ForeignKey("users.id"), nullable=False)
    hotel_name           = Column(String(200), nullable=False)
    waste_type           = Column(String(50),  nullable=False)
    volume               = Column(Float,       nullable=False)
    unit                 = Column(String(20),  default="kg")
    quality              = Column(String(5),   default="A")
    min_bid              = Column(Float,       nullable=False)
    reserve_price        = Column(Float,       nullable=True)
    auction_duration     = Column(String(20),  default="24h")
    auto_accept_above    = Column(Float,       nullable=True)
    special_instructions = Column(Text,        nullable=True)
    contact_person       = Column(String(120), nullable=True)
    status               = Column(SAEnum(ListingStatus), default=ListingStatus.open)
    location             = Column(String(200), nullable=True)
    assigned_recycler    = Column(String(200), nullable=True)
    assigned_driver      = Column(String(200), nullable=True)
    collection_date      = Column(String(20),  nullable=True)
    collection_time      = Column(String(10),  nullable=True)
    actual_weight        = Column(Float,       nullable=True)
    created_at           = Column(DateTime,    default=datetime.utcnow)
    expires_at           = Column(DateTime,    nullable=True)

    hotel = relationship("User", back_populates="listings", foreign_keys=[hotel_id])
    bids  = relationship("Bid",  back_populates="listing",  cascade="all, delete-orphan")


class Bid(Base):
    __tablename__ = "bids"

    id                    = Column(Integer, primary_key=True, index=True)
    listing_id            = Column(Integer, ForeignKey("waste_listings.id"), nullable=False)
    recycler_id           = Column(Integer, ForeignKey("users.id"),          nullable=False)
    recycler_name         = Column(String(200), nullable=False)
    amount                = Column(Float,       nullable=False)
    note                  = Column(Text,        nullable=True)
    collection_preference = Column(String(100), nullable=True)
    status                = Column(SAEnum(BidStatus), default=BidStatus.active)
    created_at            = Column(DateTime, default=datetime.utcnow)

    listing  = relationship("WasteListing", back_populates="bids")
    recycler = relationship("User", back_populates="bids", foreign_keys=[recycler_id])


# ============================================================
# Transactions
# ============================================================

class Transaction(Base):
    __tablename__ = "transactions"

    id         = Column(Integer, primary_key=True, index=True)
    listing_id = Column(Integer, ForeignKey("waste_listings.id"), nullable=True)
    from_user  = Column(String(200), nullable=False)
    to_user    = Column(String(200), nullable=False)
    waste_type = Column(String(50),  nullable=False)
    volume     = Column(Float,       nullable=False)
    amount     = Column(Float,       nullable=False)
    fee        = Column(Float,       default=0.0)
    status     = Column(SAEnum(TransactionStatus), default=TransactionStatus.pending)
    created_at = Column(DateTime, default=datetime.utcnow)
    receipt    = Column(String(500), nullable=True)

    listing = relationship("WasteListing", foreign_keys=[listing_id])


# ============================================================
# Collections
# ============================================================

class Collection(Base):
    __tablename__ = "collections"

    id             = Column(Integer, primary_key=True, index=True)
    listing_id     = Column(Integer, ForeignKey("waste_listings.id"), nullable=True)
    hotel_name     = Column(String(200), nullable=False)
    recycler_name  = Column(String(200), nullable=False)
    driver_name    = Column(String(200), nullable=False)
    driver_id      = Column(Integer, ForeignKey("users.id"),          nullable=True)
    waste_type     = Column(String(50),  nullable=False)
    volume         = Column(Float,       nullable=False)
    status         = Column(SAEnum(CollectionStatus), default=CollectionStatus.scheduled)
    scheduled_date = Column(String(20),  nullable=False)
    scheduled_time = Column(String(10),  nullable=True)
    completed_at   = Column(DateTime,    nullable=True)
    actual_weight  = Column(Float,       nullable=True)
    rating         = Column(Float,       nullable=True)
    notes          = Column(Text,        nullable=True)
    location       = Column(String(200), nullable=True)
    earnings       = Column(Float,       default=0.0)
    created_at     = Column(DateTime,    default=datetime.utcnow)

    listing = relationship("WasteListing", foreign_keys=[listing_id])
    driver  = relationship("User",         foreign_keys=[driver_id])


# ============================================================
# Support Tickets
# ============================================================

class SupportTicket(Base):
    __tablename__ = "support_tickets"

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    user_name  = Column(String(200), nullable=False)
    subject    = Column(String(300), nullable=False)
    message    = Column(Text,        nullable=False)
    status     = Column(SAEnum(TicketStatus),   default=TicketStatus.open)
    priority   = Column(SAEnum(TicketPriority), default=TicketPriority.medium)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user      = relationship("User",           back_populates="support_tickets")
    responses = relationship("TicketResponse", back_populates="ticket", cascade="all, delete-orphan")


class TicketResponse(Base):
    __tablename__ = "ticket_responses"

    id         = Column(Integer, primary_key=True, index=True)
    ticket_id  = Column(Integer, ForeignKey("support_tickets.id"), nullable=False)
    from_name  = Column(String(200), nullable=False)
    message    = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    ticket = relationship("SupportTicket", back_populates="responses")


# ============================================================
# Messages
# ============================================================

class Message(Base):
    __tablename__ = "messages"

    id           = Column(Integer, primary_key=True, index=True)
    from_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    from_name    = Column(String(200), nullable=False)
    to_user_id   = Column(Integer, ForeignKey("users.id"), nullable=False)
    to_name      = Column(String(200), nullable=False)
    subject      = Column(String(300), nullable=False)
    body         = Column(Text,        nullable=False)
    is_read      = Column(Boolean,     default=False)
    created_at   = Column(DateTime,    default=datetime.utcnow)

    sender    = relationship("User", back_populates="sent_messages", foreign_keys=[from_user_id])
    recipient = relationship("User", back_populates="recv_messages", foreign_keys=[to_user_id])
    replies   = relationship("MessageReply", back_populates="message", cascade="all, delete-orphan")


class MessageReply(Base):
    __tablename__ = "message_replies"

    id           = Column(Integer, primary_key=True, index=True)
    message_id   = Column(Integer, ForeignKey("messages.id"), nullable=False)
    from_user_id = Column(Integer, nullable=False)
    from_name    = Column(String(200), nullable=False)
    body         = Column(Text, nullable=False)
    created_at   = Column(DateTime, default=datetime.utcnow)

    message = relationship("Message", back_populates="replies")


# ============================================================
# Driver Routes & Stops
# ============================================================

class DriverRoute(Base):
    __tablename__ = "driver_routes"

    id                 = Column(Integer, primary_key=True, index=True)
    driver_id          = Column(Integer, ForeignKey("users.id"), nullable=False)
    date               = Column(String(20), nullable=False)
    status             = Column(SAEnum(RouteStatus), default=RouteStatus.pending)
    total_distance     = Column(Float, default=0.0)
    estimated_earnings = Column(Float, default=0.0)
    actual_earnings    = Column(Float, nullable=True)
    start_time         = Column(String(10), nullable=True)
    end_time           = Column(String(10), nullable=True)
    created_at         = Column(DateTime,   default=datetime.utcnow)

    driver = relationship("User",      back_populates="driver_routes")
    stops  = relationship("RouteStop", back_populates="route", cascade="all, delete-orphan", order_by="RouteStop.id")


class RouteStop(Base):
    __tablename__ = "route_stops"

    id                   = Column(Integer, primary_key=True, index=True)
    route_id             = Column(Integer, ForeignKey("driver_routes.id"), nullable=False)
    hotel_name           = Column(String(200), nullable=False)
    location             = Column(String(200), nullable=True)
    waste_type           = Column(String(50),  nullable=True)
    volume               = Column(Float,       nullable=True)
    eta                  = Column(String(10),  nullable=True)
    status               = Column(SAEnum(StopStatus), default=StopStatus.pending)
    contact_person       = Column(String(120), nullable=True)
    contact_phone        = Column(String(30),  nullable=True)
    special_instructions = Column(Text,        nullable=True)
    actual_weight        = Column(Float,       nullable=True)
    completed_at         = Column(DateTime,    nullable=True)

    route = relationship("DriverRoute", back_populates="stops")


# ============================================================
# Recycling Events
# ============================================================

class RecyclingEvent(Base):
    __tablename__ = "recycling_events"

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"), nullable=False)
    user_name  = Column(String(200), nullable=False)
    date       = Column(String(20),  nullable=False)
    waste_type = Column(String(50),  nullable=False)
    weight     = Column(Float,       nullable=False)
    location   = Column(String(200), nullable=True)
    points     = Column(Integer,     default=0)
    notes      = Column(Text,        nullable=True)
    verified   = Column(Boolean,     default=False)
    created_at = Column(DateTime,    default=datetime.utcnow)

    user = relationship("User", back_populates="recycling_events")


# ============================================================
# Audit Logs
# ============================================================

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id            = Column(Integer, primary_key=True, index=True)
    admin_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    admin_name    = Column(String(200), nullable=True)
    action        = Column(SAEnum(AuditAction), nullable=False)
    target        = Column(String(100), nullable=False)
    details       = Column(Text,        nullable=True)
    status        = Column(String(20),  default="success")
    created_at    = Column(DateTime,    default=datetime.utcnow)

    admin_user_rel = relationship("User", back_populates="audit_logs", foreign_keys=[admin_user_id])
