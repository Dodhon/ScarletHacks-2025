import numpy as np
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.models.cause_models import Coordinates, DistanceRequest, VectorSearchRequest
from app.config.db import get_mongo_client, get_database
from app.services.maps_api import geocode_address, calculate_distance
from bson import ObjectId

router = APIRouter()
client = get_mongo_client()
db = get_database(client, "match_cause_db")

def parse_object_ids(doc):
    """
    Recursively convert ObjectId instances in a document to strings.
    """
    if isinstance(doc, list):
        return [parse_object_ids(item) for item in doc]
    elif isinstance(doc, dict):
        new_doc = {}
        for key, value in doc.items():
            if isinstance(value, ObjectId):
                new_doc[key] = str(value)
            elif isinstance(value, (list, dict)):
                new_doc[key] = parse_object_ids(value)
            else:
                new_doc[key] = value
        return new_doc
    else:
        return doc

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

@router.post("/vector_search", tags=["causes"])
async def search_event_vector(payload: VectorSearchRequest):
    """
    Search for the event with the highest cosine similarity to the given user embedding.

    Body Parameters (JSON):
        - **user_embedding**: A list of float values representing the user's embedding vector

    This function retrieves up to 100 events from the "events" collection, computes the cosine similarity
    between the provided embedding and each event's 'embedded' field, and returns the closest match.
    """
    try:
        causes_collection = db["events"]
        
        docs = list(causes_collection.find().limit(100))
        if not docs:
            return {"message": "No cause found in the database."}
        
        user_embedding = np.array(payload.user_embedding)
        user_norm = np.linalg.norm(user_embedding)
        best_doc = None
        best_similarity = -1

        for doc in docs:
            candidate = doc.get("embedded")
            if candidate is None:
                continue
            
            candidate_embedding = np.array(candidate)
            candidate_norm = np.linalg.norm(candidate_embedding)
            
            if user_norm == 0 or candidate_norm == 0:
                similarity = -1
            else:
                similarity = np.dot(user_embedding, candidate_embedding) / (user_norm * candidate_norm)
            
            if similarity > best_similarity:
                best_similarity = similarity
                best_doc = doc
        
        if best_doc is None:
            return {"message": "No cause found matching the provided embedding."}
        
        return {"most_similar_cause": parse_object_ids(best_doc), "similarity": best_similarity}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
@router.get("/random", tags=["causes"])
async def get_random_cause():
    """
    Retrieve a random cause from the database.
    """
    try:
        # Select the collection. Change "events" to "causes" if needed.
        causes_collection = db["events"]
        
        # Use the $sample aggregation operator to fetch one random document.
        random_doc = list(causes_collection.aggregate([{ "$sample": { "size": 1 } }]))
        
        if not random_doc:
            return {"message": "No cause found in the database."}
        
        return {"random_cause": parse_object_ids(random_doc[0])}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))