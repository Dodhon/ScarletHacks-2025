from pydantic import BaseModel

class Coordinates(BaseModel):
    lat: float
    lng: float
    
class DistanceRequest(BaseModel):
    coords: Coordinates
    address: str