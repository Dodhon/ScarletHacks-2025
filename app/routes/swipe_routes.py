from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
# Use async database type
from motor.motor_asyncio import AsyncIOMotorDatabase
# from pymongo.database import Database # Remove sync type

# Use absolute imports
from app.services import swiping 
from app.models.event_models import EventResponse 
from app.config.db import get_db 
from app.middleware.auth import get_current_user 
from app.models.user_models import UserPublic 

router = APIRouter(
    prefix="/swipe",
    tags=["swipe"],
    dependencies=[Depends(get_current_user)] # Require authentication
)

class SwipeAction(BaseModel):
    current_event_id: str 
    direction: str # "left" or "right"

# Remove the placeholder NextEventResponse
# class NextEventResponse(BaseModel):
#     event_id: str
#     name: str # Example field
#     description: str # Example field
#     similarity: float

@router.post("/", response_model=EventResponse)
async def handle_swipe_action(
    swipe_data: SwipeAction,
    db: AsyncIOMotorDatabase = Depends(get_db), # Correct DB type hint
    current_user: UserPublic = Depends(get_current_user)
):
    user_id = current_user.id 

    if swipe_data.direction not in ["left", "right"]:
        raise HTTPException(status_code=400, detail="Invalid swipe direction. Must be 'left' or 'right'.")

    # Call the service function 
    next_event = await swiping.get_next_event(
        db=db, 
        user_id_str=user_id, 
        current_event_id_str=swipe_data.current_event_id, 
        direction=swipe_data.direction
    ) 
    
    # Service function handles errors and not found cases
    return next_event

# Removed helper function placeholder
# def get_current_user_id(...): ... 