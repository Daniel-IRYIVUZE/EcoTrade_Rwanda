"""services/assignment_service.py
Auto-assignment of waste-collection locations to the nearest available driver.

Algorithm
---------
1.  For every unassigned, geo-coded collection in a recycler's queue, calculate
    the geodesic distance (Haversine formula, metres) to every available driver
    that has current GPS coordinates.
2.  Assign the nearest driver greedily.
3.  Optional load-balancing mode adds a small penalty per already-assigned
    location, so that the workload is spread more evenly across drivers.
4.  If `apply=True` the assignments are written back to the database.

No third-party geo library is required – the standard `math` module is used.
"""
from __future__ import annotations

import math
from typing import NamedTuple

from sqlalchemy.orm import Session

# ── Constants ──────────────────────────────────────────────────────────────────
EARTH_RADIUS_M = 6_371_000          # WGS-84 mean radius in metres
BALANCE_PENALTY_M = 500.0           # extra "virtual metres" per assigned location


# ── Pure data types (no DB, easy to unit-test) ─────────────────────────────────

class LocationPoint(NamedTuple):
    """A waste-collection location with an internal reference id."""
    id: int
    lat: float
    lng: float
    label: str = ""


class CollectorPoint(NamedTuple):
    """A waste collector (driver) with a current position."""
    id: int
    lat: float
    lng: float
    label: str = ""


class AssignmentResult(NamedTuple):
    location_id: int
    location_lat: float
    location_lng: float
    location_label: str
    collector_id: int
    collector_lat: float
    collector_lng: float
    collector_label: str
    distance_m: float       # straight-line geodesic distance in metres
    workload: int           # total locations assigned to this collector so far


# ── Core distance function ─────────────────────────────────────────────────────

def haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Return the geodesic (great-circle) distance in **metres** between two
    WGS-84 coordinate pairs using the Haversine formula.

    Accuracy is within ~0.3 % for distances relevant to urban logistics.
    """
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lng2 - lng1)

    a = (math.sin(dphi / 2) ** 2
         + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2)
    return 2 * EARTH_RADIUS_M * math.asin(math.sqrt(a))


# ── Pure assignment algorithm ──────────────────────────────────────────────────

def assign_nearest(
    locations: list[LocationPoint],
    collectors: list[CollectorPoint],
    *,
    balance_load: bool = False,
) -> list[AssignmentResult]:
    """Assign each location to the nearest collector.

    Parameters
    ----------
    locations:
        Waste-collection stops that need a driver.
    collectors:
        Available drivers with known GPS positions.
    balance_load:
        When *True* a soft workload-balance heuristic is applied: each
        already-assigned location adds ``BALANCE_PENALTY_M`` (500 m) to the
        effective distance for that collector.  This spreads assignments more
        evenly while still honouring proximity.

    Returns
    -------
    list[AssignmentResult]
        One result per location, in the same order as *locations*.

    Raises
    ------
    ValueError
        If *collectors* is empty.
    """
    if not collectors:
        raise ValueError(
            "No collectors with GPS coordinates available for assignment."
        )
    if not locations:
        return []

    workload: dict[int, int] = {c.id: 0 for c in collectors}
    results: list[AssignmentResult] = []

    for loc in locations:
        best: CollectorPoint | None = None
        best_score = math.inf

        for col in collectors:
            raw_dist = haversine_m(loc.lat, loc.lng, col.lat, col.lng)
            score = (
                raw_dist + workload[col.id] * BALANCE_PENALTY_M
                if balance_load
                else raw_dist
            )
            if score < best_score:
                best_score = score
                best = col

        assert best is not None  # guaranteed because collectors is non-empty
        workload[best.id] += 1
        results.append(
            AssignmentResult(
                location_id=loc.id,
                location_lat=loc.lat,
                location_lng=loc.lng,
                location_label=loc.label,
                collector_id=best.id,
                collector_lat=best.lat,
                collector_lng=best.lng,
                collector_label=best.label,
                distance_m=haversine_m(loc.lat, loc.lng, best.lat, best.lng),
                workload=workload[best.id],
            )
        )

    return results


# ── DB-integrated auto-assignment ──────────────────────────────────────────────

def auto_assign_collections(
    db: Session,
    *,
    recycler_id: int,
    balance_load: bool = False,
    apply: bool = False,
) -> list[dict]:
    """Query the DB for unassigned collections and available drivers, run the
    assignment algorithm, and optionally persist the results.

    Parameters
    ----------
    db:
        Active SQLAlchemy session.
    recycler_id:
        Only collections and drivers belonging to this recycler are considered.
    balance_load:
        Forward to :func:`assign_nearest`.
    apply:
        If *True*, write the driver assignments back to the database.

    Returns
    -------
    list[dict]
        JSON-serialisable list describing each assignment::

            {
              "collection_id": 42,
              "location": {
                "lat": -1.94, "lng": 30.06,
                "label": "Kigali Serena Hotel",
                "waste_type": "UCO", "volume": 120.0
              },
              "assigned_driver": {
                "id": 7, "name": "Jean Bosco",
                "lat": -1.95, "lng": 30.07,
                "status": "available",
                "vehicle_type": "Truck", "plate_number": "RAB 123A"
              },
              "distance_m": 1423.5,
              "workload": 2
            }
    """
    # Lazy imports to avoid circular dependencies
    from app.models.collection import Collection, CollectionStatus
    from app.models.driver import Driver, DriverStatus
    from app.models.listing import WasteListing

    # ── 1. Unassigned collections with geo-coded listings ──────────────────────
    unassigned: list[Collection] = (
        db.query(Collection)
        .join(WasteListing, Collection.listing_id == WasteListing.id)
        .filter(
            Collection.recycler_id == recycler_id,
            Collection.driver_id.is_(None),
            Collection.status.in_(
                [CollectionStatus.scheduled, CollectionStatus.pending]
            ),
            WasteListing.latitude.isnot(None),
            WasteListing.longitude.isnot(None),
        )
        .all()
    )

    # ── 2. Available drivers with GPS coordinates ──────────────────────────────
    available_drivers: list[Driver] = (
        db.query(Driver)
        .filter(
            Driver.recycler_id == recycler_id,
            Driver.status == DriverStatus.available,
            Driver.current_lat.isnot(None),
            Driver.current_lng.isnot(None),
        )
        .all()
    )

    # ── 3. Build pure data inputs ──────────────────────────────────────────────
    locations: list[LocationPoint] = [
        LocationPoint(
            id=col.id,
            lat=col.listing.latitude,
            lng=col.listing.longitude,
            label=(col.listing.address or f"Listing #{col.listing_id}"),
        )
        for col in unassigned
        if col.listing is not None
    ]

    collectors: list[CollectorPoint] = [
        CollectorPoint(
            id=d.id,
            lat=d.current_lat,
            lng=d.current_lng,
            label=(
                (d.user.full_name if d.user else None)
                or f"Driver #{d.id}"
            ),
        )
        for d in available_drivers
    ]

    # ── 4. Run algorithm ───────────────────────────────────────────────────────
    assignments = assign_nearest(locations, collectors, balance_load=balance_load)

    # ── 5. Optionally persist ──────────────────────────────────────────────────
    if apply:
        from app.crud.collection import crud_collection
        for a in assignments:
            drv = next((d for d in available_drivers if d.id == a.collector_id), None)
            if drv:
                crud_collection.assign_driver(
                    db,
                    collection_id=a.location_id,
                    driver_id=drv.id,
                    vehicle_id=drv.vehicle_id,
                )

    # ── 6. Build JSON-safe response ────────────────────────────────────────────
    col_map = {col.id: col for col in unassigned}
    drv_map = {d.id: d for d in available_drivers}

    output: list[dict] = []
    for a in assignments:
        col = col_map.get(a.location_id)
        drv = drv_map.get(a.collector_id)
        output.append(
            {
                "collection_id": a.location_id,
                "location": {
                    "lat": a.location_lat,
                    "lng": a.location_lng,
                    "label": a.location_label,
                    "waste_type": (
                        col.listing.waste_type.value
                        if col and col.listing
                        else None
                    ),
                    "volume": (
                        col.listing.volume if col and col.listing else None
                    ),
                },
                "assigned_driver": {
                    "id": a.collector_id,
                    "name": a.collector_label,
                    "lat": a.collector_lat,
                    "lng": a.collector_lng,
                    "status": drv.status.value if drv else None,
                    "vehicle_type": (
                        drv.vehicle.vehicle_type
                        if (drv and drv.vehicle)
                        else None
                    ),
                    "plate_number": (
                        drv.vehicle.plate_number
                        if (drv and drv.vehicle)
                        else None
                    ),
                },
                "distance_m": round(a.distance_m, 1),
                "workload": a.workload,
            }
        )

    return output
