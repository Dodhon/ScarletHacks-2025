from motor.motor_asyncio import AsyncIOMotorDatabase
from fastapi import APIRouter, Depends, HTTPException
from typing import List

from app.config.db import get_db
from app.models.event_models import EventCreate, EventInDB, EventResponse
from app.services import event_service
from app.services.swiping import get_initial_recommendation
from app.middleware.auth import get_current_user
from app.models.user_models import UserPublic

router = APIRouter(
    prefix="/events",
    tags=["events"]
    # Auth dependency applied per-route below
)

# Requires authentication
@router.post("/", response_model=EventInDB, dependencies=[Depends(get_current_user)])
async def create_new_event(event: EventCreate, db: AsyncIOMotorDatabase = Depends(get_db)):
    """Create a new event."""
    return await event_service.create_event(db=db, event_data=event)

# Requires authentication
@router.get("/next", response_model=EventResponse | None, dependencies=[Depends(get_current_user)])
async def get_next_recommended_event(
    db: AsyncIOMotorDatabase = Depends(get_db),
    current_user: UserPublic = Depends(get_current_user) # Injected by dependency
):
    """Fetches the next recommended event for the authenticated user."""
    recommendation = await get_initial_recommendation(db=db, user_id_str=current_user.id)
    return recommendation


# Example GET routes (commented out)
# @router.get("/", response_model=List[EventInDB])
# async def get_all_events(db: AsyncIOMotorDatabase = Depends(get_db)):
#     events = await db.events.find().to_list(1000) 
#     # TODO: Convert _id to id string for model validation
#     return events

# @router.get("/{event_id}", response_model=EventInDB)
# async def get_event_by_id(event_id: str, db: AsyncIOMotorDatabase = Depends(get_db)):
#     # TODO: Convert event_id string to ObjectId, find event, handle not found, convert _id
#     pass 