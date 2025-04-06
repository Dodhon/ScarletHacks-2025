from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from bson import ObjectId

class EventBase(BaseModel):
    name: str
    description: str
    vector: List[float]
    date: Optional[datetime] = None
    location: Optional[str] = None

class EventInDB(EventBase):
    id: str = Field(..., alias="_id")

    class Config:
        json_encoders = {
            ObjectId: str
        }
        validate_by_name = True 

# Input model for creating an event
class EventCreate(EventBase):
    pass # Inherits all fields from EventBase

# Response model for the swipe endpoint
class EventResponse(BaseModel):
    event_id: str
    name: str
    description: str
    similarity: float

    class Config:
        json_encoders = {
            ObjectId: str
        } 