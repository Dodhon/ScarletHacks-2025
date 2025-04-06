from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.event_models import EventCreate, EventInDB
import logging
from fastapi import HTTPException
import datetime # Potentially for created_at/updated_at

# Assuming EventCreate has fields: name, description, vector, date, location
# Assuming EventInDB inherits EventCreate and adds 'id' (mapped from '_id')

async def create_event(db: AsyncIOMotorDatabase, event_data: EventCreate) -> EventInDB:
    """Inserts a new event document into the database."""
    try:
        event_dict = event_data.model_dump()
        
        # Example: Add server-side timestamp if needed
        # event_dict["created_at"] = datetime.datetime.utcnow()
        
        result = await db.events.insert_one(event_dict)
        
        # Retrieve the full document to get the _id and ensure insertion worked
        created_event = await db.events.find_one({"_id": result.inserted_id})
        
        if not created_event:
            logging.error(f"Failed to retrieve created event after insertion (ID: {result.inserted_id}).")
            raise HTTPException(status_code=500, detail="Failed to create event properly.")

        # Convert ObjectId to string before validation
        created_event["_id"] = str(created_event["_id"])

        # Validate and return using EventInDB model
        return EventInDB(**created_event)

    except Exception as e:
        # Log the actual exception
        logging.exception(f"Error creating event '{event_data.name}': {e}")
        # Re-raise as a generic 500 error for the client
        raise HTTPException(status_code=500, detail=f"Error creating event.") 