from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.models.cause_models import Coordinates, DistanceRequest
from app.config.db import get_mongo_client, get_database
from app.services.maps_api import geocode_address, calculate_distance


router = APIRouter()

@router.get("/geocode", response_model=Coordinates, tags=["causes"])
async def geocode(address: str):
    """
    Geocode an address and return its latitude and longitude.
    """
    try:
        location = geocode_address(address)
        return location
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/distance", tags=["causes"])
async def calculate_distance_from_model(payload: DistanceRequest):
    """
    Calculate the distance (in miles) between the given coordinates and a destination address.

    Body Parameters (JSON):
        - **current_lat**: Latitude of the current location
        - **current_lng**: Longitude of the current location
        - **address**: Destination address
    """
    try:
        current_coords = {"lat": payload.current_lat, "lng": payload.current_lng}
        destination_coords = geocode_address(payload.address)
        distance = calculate_distance(current_coords, destination_coords)
        return {"distance_miles": round(distance, 2)}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))