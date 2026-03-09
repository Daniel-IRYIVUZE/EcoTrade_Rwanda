"""models/driver.py — Driver profile and Vehicle models."""
import enum
from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.database import Base


def utc_now():
    return datetime.now(timezone.utc)


class VehicleStatus(str, enum.Enum):
    active      = "active"
    maintenance = "maintenance"
    inactive    = "inactive"


class DriverStatus(str, enum.Enum):
    available  = "available"
    on_route   = "on_route"
    off_duty   = "off_duty"


class Vehicle(Base):
    __tablename__ = "vehicles"

    id              = Column(Integer, primary_key=True, index=True)
    recycler_id     = Column(Integer, ForeignKey("recyclers.id", ondelete="CASCADE"), nullable=False)
    plate_number    = Column(String(20), unique=True, nullable=False)
    vehicle_type    = Column(String(100), nullable=False)   # e.g. "Truck", "Van"
    make            = Column(String(100), nullable=True)
    model           = Column(String(100), nullable=True)
    year            = Column(Integer, nullable=True)
    capacity_kg     = Column(Float, nullable=False)
    status          = Column(SAEnum(VehicleStatus), default=VehicleStatus.active)
    insurance_url   = Column(String(500), nullable=True)
    last_service    = Column(DateTime(timezone=True), nullable=True)
    created_at      = Column(DateTime(timezone=True), default=utc_now)
    updated_at      = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    # Relationships
    recycler    = relationship("Recycler", back_populates="vehicles")
    driver      = relationship("Driver", back_populates="vehicle", uselist=False)
    collections = relationship("Collection", back_populates="vehicle")


class Driver(Base):
    __tablename__ = "drivers"

    id              = Column(Integer, primary_key=True, index=True)
    user_id         = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    recycler_id     = Column(Integer, ForeignKey("recyclers.id"), nullable=True)
    vehicle_id      = Column(Integer, ForeignKey("vehicles.id"), nullable=True)
    license_number  = Column(String(100), nullable=True)
    license_url     = Column(String(500), nullable=True)
    phone           = Column(String(20), nullable=True)
    status          = Column(SAEnum(DriverStatus), default=DriverStatus.available)
    current_lat     = Column(Float, nullable=True)
    current_lng     = Column(Float, nullable=True)
    rating          = Column(Float, default=0.0)
    review_count    = Column(Integer, default=0)
    total_trips     = Column(Integer, default=0)
    total_distance  = Column(Float, default=0.0)    # km
    is_verified     = Column(Boolean, default=False)
    created_at      = Column(DateTime(timezone=True), default=utc_now)
    updated_at      = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    # Relationships
    user        = relationship("User", back_populates="driver", lazy="joined")
    vehicle     = relationship("Vehicle", back_populates="driver")
    recycler    = relationship("Recycler", foreign_keys=[recycler_id])
    collections = relationship("Collection", back_populates="driver")
    routes      = relationship("Route", back_populates="driver")
