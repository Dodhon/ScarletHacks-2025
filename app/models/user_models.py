from typing import List, Optional
from pydantic import BaseModel, Field
from app.models.event_models import EventBase

# Updated UserPublic to include relevant fields for a logged-in user context
class UserPublic(BaseModel):
    id: str = Field(..., alias="_id")
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None

    disabled: Optional[bool] = None


    class Config:
        populate_by_name = True

class Event(EventBase):
    pass

class EventInDB(EventBase):
    id: str = Field(..., alias="_id")

    class Config:
        populate_by_name = True

class UserCreate(BaseModel):
    username: str
    password: str 
    email: Optional[str] = None
    full_name: Optional[str] = None 

# Add UserInDB model
class UserInDB(UserPublic):
    hashed_password: str


    class Config:
        populate_by_name = True 

