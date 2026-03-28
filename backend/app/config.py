"""
config.py — Application configuration using pydantic-settings.
"""
from pydantic_settings import BaseSettings
from functools import lru_cache
import os


class Settings(BaseSettings):
    # ── Application ──────────────────────────────────────────────────────────
    APP_NAME: str = "EcoTrade Rwanda API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    ENVIRONMENT: str = "development"

    # ── Database ──────────────────────────────────────────────────────────────
    DATABASE_URL: str = "sqlite:///./ecotrade.db"
    DATABASE_ECHO: bool = False

    # ── JWT ───────────────────────────────────────────────────────────────────
    # SECRET_KEY must be set in .env for production. A stable fallback is used
    # for development so tokens survive server restarts.
    SECRET_KEY: str = os.getenv("SECRET_KEY", "ecotrade-dev-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 240
    REFRESH_TOKEN_EXPIRE_DAYS: int = 60

    # ── CORS ──────────────────────────────────────────────────────────────────
    ALLOWED_ORIGINS: list[str] = ["*"]

    # ── File uploads ──────────────────────────────────────────────────────────
    UPLOAD_DIR: str = "uploads"
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10 MB
    ALLOWED_IMAGE_TYPES: list[str] = ["image/jpeg", "image/png", "image/webp"]
    ALLOWED_DOC_TYPES: list[str] = ["application/pdf", "image/jpeg", "image/png"]

    # ── Platform fees ─────────────────────────────────────────────────────────
    PLATFORM_FEE_PERCENT: float = 5.0          # 5% platform fee on transactions

    # ── Email (SMTP) ────────────────────────────────────────────────────────────
    # All credentials are read from .env — never hardcode passwords in source.
    SMTP_HOST: str = os.getenv("SMTP_HOST", "webhost.dynadot.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USER: str = os.getenv("SMTP_USER", "")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")
    EMAIL_FROM: str = os.getenv("EMAIL_FROM", "noreply@ecotrade-rwanda.com")
    EMAIL_FROM_NAME: str = "EcoTrade Rwanda"
    EMAIL_USE_TLS: bool = True
    ADMIN_EMAIL: str = os.getenv("ADMIN_EMAIL", "admin@ecotrade-rwanda.com")

    # ── Pagination defaults ───────────────────────────────────────────────────
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100

    @property
    def is_email_configured(self) -> bool:
        """True when SMTP credentials are present and functional."""
        return bool(self.SMTP_HOST and self.SMTP_USER and self.SMTP_PASSWORD and self.EMAIL_FROM)

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()