"""
main.py — EcoTrade Rwanda FastAPI application entry point

Run:
    uvicorn main:app --reload --port 8000

Docs:
    http://localhost:8000/docs      (Swagger UI)
    http://localhost:8000/redoc     (ReDoc)
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path

from database import Base, engine
import models  # ensure all models are registered before create_all
from routers import auth
from routers import users, listings, transactions, collections, support, messages, routes, recycling, audit

# ---------------------------------------------------------------------------
# Create all tables on startup
# ---------------------------------------------------------------------------
Base.metadata.create_all(bind=engine)

# ---------------------------------------------------------------------------
# FastAPI app
# ---------------------------------------------------------------------------
app = FastAPI(
    title="EcoTrade Rwanda API",
    description="Backend API for the EcoTrade Rwanda waste-to-resource marketplace platform.",
    version="1.0.0",
    contact={
        "name": "EcoTrade Rwanda",
        "email": "contact@ecotrade.rw",
        "url": "https://ecotrade-rwanda.netlify.app",
    },
    license_info={"name": "MIT"},
)

# ---------------------------------------------------------------------------
# CORS — allow the Vite dev server and production frontend
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",   # Vite dev
        "http://localhost:3000",
        "https://ecotrade-rwanda.netlify.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Serve uploaded files at /uploads/<path>
# ---------------------------------------------------------------------------
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(listings.router)
app.include_router(transactions.router)
app.include_router(collections.router)
app.include_router(support.router)
app.include_router(messages.router)
app.include_router(routes.router)
app.include_router(recycling.router)
app.include_router(audit.router)


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------
@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "message": "EcoTrade Rwanda API is running 🌿"}


@app.get("/health", tags=["Health"])
def health():
    return {"status": "healthy", "version": "1.0.0"}
