"""
database.py — SQLAlchemy engine, session factory and Base declarative class.
"""
import logging
from sqlalchemy import create_engine, event, text
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from sqlalchemy.pool import StaticPool
from app.config import settings

logger = logging.getLogger(__name__)

# ── Engine ────────────────────────────────────────────────────────────────────
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args = {
        "check_same_thread": False,
        # Wait up to 30 s when the database is locked by another connection/
        # process instead of raising "database is locked" immediately.
        "timeout": 30,
    }

engine = create_engine(
    settings.DATABASE_URL,
    connect_args=connect_args,
    echo=settings.DATABASE_ECHO,
    poolclass=StaticPool if "memory" in settings.DATABASE_URL else None,
    # Limit SQLite file-based connections to avoid concurrent-write corruption.
    pool_pre_ping=True,   # discard stale connections automatically
)

# Enable WAL mode, foreign keys and durability pragmas for SQLite
if settings.DATABASE_URL.startswith("sqlite"):
    @event.listens_for(engine, "connect")
    def set_sqlite_pragma(dbapi_connection, _connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        # WAL allows concurrent reads while a write is in progress.
        cursor.execute("PRAGMA journal_mode=WAL")
        # FULL fsync on every commit — slower but guards against OS-crash corruption.
        cursor.execute("PRAGMA synchronous=FULL")
        # Automatically checkpoint the WAL when it reaches 1000 pages (~4 MB).
        cursor.execute("PRAGMA wal_autocheckpoint=1000")
        # Return SQLITE_BUSY after 30 s instead of failing immediately.
        cursor.execute("PRAGMA busy_timeout=30000")
        cursor.close()


def check_db_integrity() -> bool:
    """Run SQLite integrity_check; return True if the database is healthy."""
    if not settings.DATABASE_URL.startswith("sqlite"):
        return True
    try:
        with engine.connect() as conn:
            result = conn.execute(text("PRAGMA integrity_check")).fetchone()
            ok = result and result[0] == "ok"
            if not ok:
                logger.error("SQLite integrity check FAILED: %s", result[0] if result else "no result")
            return bool(ok)
    except Exception as exc:
        logger.error("SQLite integrity check raised an exception: %s", exc)
        return False


def try_recover_db() -> bool:
    """
    Attempt an in-place WAL recovery by forcing a checkpoint.
    Returns True if the database is healthy afterwards.
    """
    if not settings.DATABASE_URL.startswith("sqlite"):
        return True
    try:
        with engine.connect() as conn:
            conn.execute(text("PRAGMA wal_checkpoint(TRUNCATE)"))
        return check_db_integrity()
    except Exception as exc:
        logger.error("WAL checkpoint/recovery failed: %s", exc)
        return False


# ── Session ────────────────────────────────────────────────────────────────────
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# ── Base ────────────────────────────────────────────────────────────────────────
class Base(DeclarativeBase):
    pass


# ── Dependency ────────────────────────────────────────────────────────────────
def get_db():
    """FastAPI dependency that yields a database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
