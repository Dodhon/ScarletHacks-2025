from pydantic import BaseModel
from typing import List

class Cause(BaseModel):
    name: str
    location: str
    data: str
    time: str
    description: str
    category: List[str]
    link: str
    
class Coordinates(BaseModel):
    lat: float
    lng: float
    
class DistanceRequest(BaseModel):
    coords: Coordinates
    address: str

class VectorSearchRequest(BaseModel):
    user_embedding: List[float]
