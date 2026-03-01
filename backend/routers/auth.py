"""
routers/auth.py — Authentication routes
 POST /api/auth/register  — create a new account
 POST /api/auth/login     — authenticate with email + password
"""
import json
import os
import shutil
from pathlib import Path
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from database import get_db
from models import DriverProfile, HotelProfile, RecyclerProfile, User, UserRole, UserStatus
from schemas import RegisterResponse, UserOut, Token
from utils.security import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/api/auth", tags=["Auth"])

UPLOAD_DIR = Path(os.getenv("UPLOAD_DIR", "uploads"))
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def _save_upload(file: UploadFile, subfolder: str) -> str:
    """Save an uploaded file and return the relative path."""
    dest = UPLOAD_DIR / subfolder
    dest.mkdir(parents=True, exist_ok=True)
    file_path = dest / file.filename
    with file_path.open("wb") as buf:
        shutil.copyfileobj(file.file, buf)
    return str(file_path)


def _get_user_by_email(db: Session, email: str) -> Optional[User]:
    return db.query(User).filter(User.email == email).first()


# ---------------------------------------------------------------------------
# POST /api/auth/register
# ---------------------------------------------------------------------------
# Uses multipart/form-data so drivers can attach licence & insurance images.
# Non-driver roles just send JSON fields as form fields (or call the JSON
# variant below — same logic, two endpoints for convenience).
# ---------------------------------------------------------------------------

@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new account (hotel / recycler / driver)",
)
async def register(
    # -------- role & common --------
    role: str = Form(..., description="hotel | recycler | driver"),
    full_name: str = Form(...),
    email: str = Form(...),
    phone: Optional[str] = Form(None),
    password: str = Form(...),
    confirm_password: str = Form(...),

    # -------- hotel fields --------
    business_name: Optional[str] = Form(None),
    registration_number: Optional[str] = Form(None),
    tax_id: Optional[str] = Form(None),
    contact_person: Optional[str] = Form(None),
    position: Optional[str] = Form(None),

    # -------- recycler fields --------
    company_name: Optional[str] = Form(None),
    license_number: Optional[str] = Form(None),
    waste_types: Optional[str] = Form(None, description="JSON array e.g. [\"UCO\",\"Glass\"]"),
    facility_address: Optional[str] = Form(None),
    processing_capacity: Optional[float] = Form(None),

    # -------- driver fields --------
    national_id: Optional[str] = Form(None),
    vehicle_type: Optional[str] = Form(None),
    vehicle_plate: Optional[str] = Form(None),
    license_image: Optional[UploadFile] = File(None),
    insurance_image: Optional[UploadFile] = File(None),

    # -------- location --------
    latitude: Optional[float] = Form(None),
    longitude: Optional[float] = Form(None),
    service_radius: Optional[float] = Form(None),
    operating_hours: Optional[str] = Form(None),

    db: Session = Depends(get_db),
):
    # ── validation ──────────────────────────────────────────────────────────
    allowed_roles = {"hotel", "recycler", "driver", "individual"}
    if role not in allowed_roles:
        raise HTTPException(status_code=400, detail=f"role must be one of {allowed_roles}")

    if password != confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    if len(password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

    if role == "hotel" and not business_name:
        raise HTTPException(status_code=400, detail="business_name is required for hotel accounts")

    if role == "recycler" and not company_name:
        raise HTTPException(status_code=400, detail="company_name is required for recycler accounts")

    # ── duplicate check ──────────────────────────────────────────────────────
    if _get_user_by_email(db, email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )

    # ── create base user ─────────────────────────────────────────────────────
    user = User(
        full_name=full_name,
        email=email,
        phone=phone,
        hashed_password=hash_password(password),
        role=UserRole(role),
        status=UserStatus.pending,
        is_verified=False,
        latitude=latitude,
        longitude=longitude,
    )
    db.add(user)
    db.flush()  # get user.id before sub-profile insert

    # ── role-specific sub-profile ────────────────────────────────────────────
    if role == "hotel":
        db.add(HotelProfile(
            user_id=user.id,
            business_name=business_name,
            registration_number=registration_number,
            tax_id=tax_id,
            contact_person=contact_person,
            position=position,
        ))

    elif role == "recycler":
        # waste_types arrives as JSON string from the form
        wt_parsed: Optional[list] = None
        if waste_types:
            try:
                wt_parsed = json.loads(waste_types)
            except json.JSONDecodeError:
                # fallback: comma-separated
                wt_parsed = [w.strip() for w in waste_types.split(",") if w.strip()]

        db.add(RecyclerProfile(
            user_id=user.id,
            company_name=company_name,
            license_number=license_number,
            waste_types=json.dumps(wt_parsed) if wt_parsed else None,
            facility_address=facility_address,
            processing_capacity=processing_capacity,
            service_radius=service_radius,
            operating_hours=operating_hours,
        ))

    elif role == "driver":
        license_path: Optional[str] = None
        insurance_path: Optional[str] = None

        if license_image and license_image.filename:
            license_path = _save_upload(license_image, subfolder="driver_licenses")
        if insurance_image and insurance_image.filename:
            insurance_path = _save_upload(insurance_image, subfolder="driver_insurance")

        db.add(DriverProfile(
            user_id=user.id,
            national_id=national_id,
            vehicle_type=vehicle_type,
            vehicle_plate=vehicle_plate,
            license_image_path=license_path,
            insurance_image_path=insurance_path,
            service_radius=service_radius,
            operating_hours=operating_hours,
        ))

    db.commit()
    db.refresh(user)

    return RegisterResponse(
        message=f"Account created successfully. Your account is pending review.",
        user=UserOut.model_validate(user),
    )


# ---------------------------------------------------------------------------
# POST /api/auth/login
# ---------------------------------------------------------------------------

from pydantic import BaseModel

class LoginRequest(BaseModel):
    email: str
    password: str


@router.post(
    "/login",
    response_model=Token,
    status_code=status.HTTP_200_OK,
    summary="Login with email and password — returns a JWT access token",
)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    # ── look up user ────────────────────────────────────────────────────────
    user = _get_user_by_email(db, payload.email)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )

    # ── verify password ──────────────────────────────────────────────────────
    if not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )

    # ── check account is not suspended ──────────────────────────────────────
    if user.status.value == "suspended":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account has been suspended. Contact support@ecotrade.rw",
        )

    # ── issue JWT ────────────────────────────────────────────────────────────
    token = create_access_token(
        data={"sub": str(user.id), "role": user.role.value, "email": user.email}
    )

    return Token(access_token=token, token_type="bearer", user=UserOut.model_validate(user))
