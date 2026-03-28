"""crud/recycler.py — Recycler company CRUD."""
import json as _json
from sqlalchemy.orm import Session
from app.crud.base import CRUDBase
from app.models.recycler import Recycler
from app.schemas.recycler import RecyclerCreate, RecyclerUpdate


def _serialize(data: dict) -> dict:
    """Convert list fields to JSON strings for SQLite Text columns."""
    v = data.get('waste_types_handled')
    if isinstance(v, list):
        data['waste_types_handled'] = _json.dumps(v)
    return data


class CRUDRecycler(CRUDBase[Recycler, RecyclerCreate, RecyclerUpdate]):

    def create(self, db: Session, *, obj_in: RecyclerCreate, **extra) -> Recycler:
        data = obj_in.model_dump(exclude_unset=True)
        data.update(extra)
        _serialize(data)
        db_obj = Recycler(**data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update(self, db: Session, *, db_obj: Recycler, obj_in: RecyclerUpdate | dict) -> Recycler:
        update_data = obj_in if isinstance(obj_in, dict) else obj_in.model_dump(exclude_unset=True)
        _serialize(update_data)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_by_user(self, db: Session, user_id: int) -> Recycler | None:
        return db.query(Recycler).filter(Recycler.user_id == user_id).first()

    def get_verified(self, db: Session, *, skip: int = 0, limit: int = 20) -> list[Recycler]:
        return (db.query(Recycler)
                .filter(Recycler.is_verified == True)
                .offset(skip).limit(limit).all())

    def update_fleet_count(self, db: Session, recycler_id: int, count: int) -> Recycler | None:
        rec = db.query(Recycler).filter(Recycler.id == recycler_id).first()
        if rec:
            rec.fleet_size = count
            db.commit()
            db.refresh(rec)
        return rec

    def increment_collection_count(self, db: Session, recycler_id: int) -> None:
        """No-op placeholder — collection count derived from relationship."""
        pass


crud_recycler = CRUDRecycler(Recycler)
