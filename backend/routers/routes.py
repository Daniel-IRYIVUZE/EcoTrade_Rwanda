"""
routers/routes.py — Driver routes & stop status updates
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from database import get_db
from utils.deps import get_current_user
import models
import schemas

router = APIRouter(prefix="/api/routes", tags=["routes"])


@router.post("/", response_model=schemas.DriverRouteOut, status_code=201)
def create_route(
    payload: schemas.DriverRouteCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    stops_data = payload.stops
    route_data = payload.model_dump(exclude={"stops"})
    route = models.DriverRoute(driver_id=current_user.id, **route_data)
    db.add(route)
    db.flush()  # get route.id
    for stop_data in stops_data:
        stop = models.RouteStop(route_id=route.id, **stop_data.model_dump())
        db.add(stop)
    db.commit()
    db.refresh(route)
    return route


@router.get("/", response_model=list[schemas.DriverRouteOut])
def list_routes(
    skip: int = 0,
    limit: int = 50,
    driver_id: int | None = None,
    status: str | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    q = db.query(models.DriverRoute)
    if current_user.role == models.UserRole.driver:
        q = q.filter(models.DriverRoute.driver_id == current_user.id)
    elif driver_id:
        q = q.filter(models.DriverRoute.driver_id == driver_id)
    if status:
        q = q.filter(models.DriverRoute.status == status)
    return q.order_by(models.DriverRoute.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{route_id}", response_model=schemas.DriverRouteOut)
def get_route(
    route_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    route = db.query(models.DriverRoute).filter(models.DriverRoute.id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    if current_user.role == models.UserRole.driver and route.driver_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    return route


@router.patch("/{route_id}", response_model=schemas.DriverRouteOut)
def update_route(
    route_id: int,
    payload: schemas.DriverRouteUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    route = db.query(models.DriverRoute).filter(models.DriverRoute.id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    if current_user.role == models.UserRole.driver and route.driver_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(route, field, value)
    db.commit()
    db.refresh(route)
    return route


@router.patch("/{route_id}/stops/{stop_id}/status", response_model=schemas.RouteStopOut)
def update_stop_status(
    route_id: int,
    stop_id: int,
    payload: schemas.RouteStopStatusUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    stop = db.query(models.RouteStop).filter(
        models.RouteStop.id == stop_id,
        models.RouteStop.route_id == route_id,
    ).first()
    if not stop:
        raise HTTPException(status_code=404, detail="Stop not found")
    stop.status = payload.status
    if payload.actual_weight is not None:
        stop.actual_weight = payload.actual_weight
    if payload.status == "completed":
        stop.completed_at = datetime.utcnow()
    db.commit()
    db.refresh(stop)
    return stop


@router.delete("/{route_id}", status_code=204)
def delete_route(
    route_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    route = db.query(models.DriverRoute).filter(models.DriverRoute.id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    if current_user.role == models.UserRole.driver and route.driver_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    db.delete(route)
    db.commit()
