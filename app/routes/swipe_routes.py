from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from pymongo.database import Database # Import Database type

from ..services import swiping 
from ..models.event_models import EventResponse # Import the correct response model
from ..config.db import get_db # Import the DB dependency
from ..middleware.auth import get_current_user # Import the user dependency
from ..models.user_models import UserPublic # Import UserPublic instead

router = APIRouter(
    prefix="/swipe",
    tags=["swipe"],
    dependencies=[Depends(get_current_user)] # Add authentication dependency
)

class SwipeAction(BaseModel):
    current_event_id: str # Renamed for clarity
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
    db: Database = Depends(get_db), # Get DB connection
    current_user: UserPublic = Depends(get_current_user) # Get user object from auth
):
    # user_id = "temp_user_id" # Replace with actual user from auth
    user_id = current_user.id # Use the user ID from the authenticated user

    if swipe_data.direction not in ["left", "right"]:
        raise HTTPException(status_code=400, detail="Invalid swipe direction. Must be 'left' or 'right'.")

    # Call the service function with db, user_id, current_event_id, direction
    # Note: We renamed event_id in SwipeAction to current_event_id for clarity
    next_event = await swiping.get_next_event(
        db=db, 
        user_id_str=user_id, 
        current_event_id_str=swipe_data.current_event_id, 
        direction=swipe_data.direction
    ) 
    
    # The service function now raises HTTPExceptions directly, 
    # so we don't need to check for None or wrap in a try/except here.
    
    return next_event

# Removed helper function placeholder
# def get_current_user_id(...): ... 