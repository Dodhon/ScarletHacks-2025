from pydantic import BaseModel

class SwipeAction(BaseModel):
    event_id: str
    direction: str 

class NextEventResponse(BaseModel):
    event_id: str
    name: str 
    description: str 
    similarity: float