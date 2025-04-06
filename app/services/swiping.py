import numpy as np
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId
import datetime
import logging
from fastapi import HTTPException

# Corrected import path
from app.models.event_models import EventResponse
from app.services.functions import calculate_cosine_similarity, calculate_new_user_info

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def get_next_event(db: AsyncIOMotorDatabase, user_id_str: str, current_event_id_str: str, direction: str) -> EventResponse:
    """Handles swipe logic: update profile (if left), find next most similar event."""
    
    try:
        user_oid = ObjectId(user_id_str)
        current_event_oid = ObjectId(current_event_id_str)
    except Exception:
        logger.error(f"Invalid ObjectId format for user '{user_id_str}' or event '{current_event_id_str}'")
        raise HTTPException(status_code=400, detail="Invalid user or event ID format")

    users_collection = db.users
    events_collection = db.events
    swipes_collection = db.swipes

    try:
        # Fetch user profile (vector)
        user = await users_collection.find_one({"_id": user_oid})
        if not user:
            logger.error(f"User not found for user_id: {user_id_str}")
            raise HTTPException(status_code=404, detail=f"User not found: {user_id_str}")

        # Allow using older 'embedding' field if 'profile_vector' doesn't exist yet.
        if "profile_vector" in user:
            user_profile_vector_data = user["profile_vector"]
        elif "embedding" in user:
            user_profile_vector_data = user["embedding"]
            logger.warning(f"User {user_id_str} using fallback 'embedding' field for profile vector in get_next_event.")
        else:
            logger.error(f"User profile vector ('profile_vector' or 'embedding') not found for user_id: {user_id_str}")
            raise HTTPException(status_code=404, detail=f"User profile vector not found for user {user_id_str}")

        # Ensure vector data is not None before conversion
        if user_profile_vector_data is None: 
             logger.error(f"User profile vector data is None for user_id: {user_id_str}")
             raise HTTPException(status_code=500, detail="User profile vector data is invalid")

        try:
             user_profile_vector = np.array(user_profile_vector_data)
        except Exception as np_err:
            logger.exception(f"Error converting profile vector data to numpy array for user {user_id_str}: {np_err}")
            raise HTTPException(status_code=500, detail="Error processing user profile vector")

        # Fetch current event (vector)
        current_event = await events_collection.find_one({"_id": current_event_oid})
        if not current_event or "vector" not in current_event:
            logger.error(f"Event or vector not found for event_id: {current_event_id_str}")
            raise HTTPException(status_code=404, detail=f"Event not found: {current_event_id_str}")
        current_event_vector = np.array(current_event["vector"])

        # Record swipe 
        swipe_record = {
            "user_id": user_oid,
            "event_id": current_event_oid,
            "direction": direction,
            "timestamp": datetime.datetime.utcnow()
        }
        await swipes_collection.insert_one(swipe_record)
        logger.info(f"Recorded swipe: User {user_id_str} swiped {direction} on Event {current_event_id_str}")

        # If swipe left, update user profile
        if direction == "left":
            # Initialize profile if empty, otherwise combine vectors.
            if user_profile_vector.shape == (0,):
                logger.info(f"Initializing profile vector for user {user_id_str} with event {current_event_id_str} vector.")
                updated_profile = current_event_vector
            elif user_profile_vector.shape == current_event_vector.shape:
                try:
                    updated_profile = calculate_new_user_info(user_profile_vector, current_event_vector)
                    logger.info(f"Calculated updated profile vector for user {user_id_str}")
                except Exception as calc_e:
                    logger.exception(f"Error calculating new profile vector for user {user_id_str}: {calc_e}")
                    raise HTTPException(status_code=500, detail="Error calculating user profile update")
            else: # Dimension mismatch
                logger.error(f"Dimension mismatch: User vector {user_profile_vector.shape}, Event vector {current_event_vector.shape}")
                raise HTTPException(status_code=500, detail="Internal error: Vector dimension mismatch during profile update")
            
            # Update the user document with the new or initialized profile vector
            try:
                await users_collection.update_one(
                    {"_id": user_oid},
                    {"$set": {"profile_vector": updated_profile.tolist()}}
                )
                user_profile_vector = updated_profile # Use updated profile for the subsequent event search
                logger.info(f"Successfully updated profile vector in DB for user {user_id_str}")
            except Exception as update_e:
                logger.exception(f"Error updating profile vector in DB for user {user_id_str}: {update_e}")
                # Decide if we should still proceed to find next event or raise error
                raise HTTPException(status_code=500, detail="Error saving updated user profile")

        # Fetch IDs of events already swiped by this user
        swiped_event_docs = swipes_collection.find({"user_id": user_oid}, {"event_id": 1})
        swiped_event_ids = [doc["event_id"] async for doc in swiped_event_docs]
        # Also exclude the event just swiped on, even if it wasn't in the DB before (e.g., first swipe)
        swiped_event_ids.append(current_event_oid) 

        # Fetch all potential events (not already swiped)
        potential_events_cursor = events_collection.find({"_id": {"$nin": swiped_event_ids}})
        potential_events = []
        async for event_doc in potential_events_cursor:
            if "vector" in event_doc and event_doc["vector"]:
                 # Convert ObjectId to string for consistency
                 event_doc["_id"] = str(event_doc["_id"])
                 potential_events.append(event_doc)
            else:
                logger.warning(f"Event {event_doc.get('_id', 'N/A')} missing or empty vector, skipping.")

        if not potential_events:
            logger.info(f"No more potential events for user {user_id_str}")
            raise HTTPException(status_code=404, detail="No more events available")

        # Calculate similarities
        similarities = []
        for event in potential_events:
             # Basic check for dimension match before calculation
            event_vector = np.array(event['vector'])
            if user_profile_vector.shape != event_vector.shape:
                logger.warning(f"Skipping event {event.get('_id')} due to vector dimension mismatch.")
                continue
            try:
                similarity = calculate_cosine_similarity(user_profile_vector, event_vector)
                similarities.append((event, similarity))
            except Exception as sim_e:
                 logger.error(f"Error calculating similarity for event {event.get('_id')}: {sim_e}")
                 continue # Skip this event if vectors mismatch or other error

        # Find event with max similarity
        if not similarities:
             logger.warning(f"No valid events left after similarity calculation and filtering for user {user_id_str}")
             raise HTTPException(status_code=404, detail="No suitable events found")
             
        best_match = max(similarities, key=lambda item: item[1])
        next_event_data, highest_similarity = best_match

        # Return the details of the next best event using the EventResponse model
        response_data = {
            "event_id": str(next_event_data["_id"]), 
            "name": next_event_data.get("name", "Unknown Event"), # Provide default
            "description": next_event_data.get("description", "No description"), # Provide default
            "similarity": highest_similarity
        }
        return EventResponse(**response_data)

    except HTTPException: # Re-raise specific HTTP exceptions
        raise
    except Exception as e:
        logger.exception(f"Unexpected error processing swipe for user {user_id_str}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error processing swipe")

# Function to get the initial recommendation without a swipe action
async def get_initial_recommendation(db: AsyncIOMotorDatabase, user_id_str: str) -> EventResponse | None:
    """Fetches the most similar event the user hasn't swiped on yet."""
    try:
        user_oid = ObjectId(user_id_str)
    except Exception:
        logger.error(f"Invalid ObjectId format for user '{user_id_str}'")
        raise HTTPException(status_code=400, detail="Invalid user ID format")

    users_collection = db.users
    events_collection = db.events
    swipes_collection = db.swipes

    try:
        # Fetch user profile (vector) - with fallback for 'embedding'
        user = await users_collection.find_one({"_id": user_oid})
        if not user:
            logger.error(f"User not found for user_id: {user_id_str}")
            raise HTTPException(status_code=404, detail=f"User not found: {user_id_str}")

        # Allow using older 'embedding' field if 'profile_vector' doesn't exist yet.
        if "profile_vector" in user:
            user_profile_vector_data = user["profile_vector"]
        elif "embedding" in user:
            user_profile_vector_data = user["embedding"]
            logger.warning(f"User {user_id_str} using fallback 'embedding' field for initial recommendation.")
        else:
            logger.error(f"User profile vector ('profile_vector' or 'embedding') not found for user_id: {user_id_str}")
            # Can't recommend if no profile vector exists.
            raise HTTPException(status_code=404, detail=f"User profile vector not found, cannot provide initial recommendation.")

        if user_profile_vector_data is None:
             logger.error(f"User profile vector data is None for user_id: {user_id_str}")
             raise HTTPException(status_code=500, detail="User profile vector data is invalid")

        try:
             user_profile_vector = np.array(user_profile_vector_data)
        except Exception as np_err:
            logger.exception(f"Error converting profile vector data to numpy array for user {user_id_str}: {np_err}")
            raise HTTPException(status_code=500, detail="Error processing user profile vector")
        
        # Can't calculate similarity with an empty profile.
        if user_profile_vector.shape == (0,):
            logger.info(f"User {user_id_str} has an empty profile vector. No personalized initial recommendation possible.")
            raise HTTPException(status_code=404, detail="Swipe left on an event first to get personalized recommendations.")

        # Fetch IDs of events already swiped by this user
        swiped_event_docs = swipes_collection.find({"user_id": user_oid}, {"event_id": 1})
        swiped_event_ids = [doc["event_id"] async for doc in swiped_event_docs] 

        # Fetch all potential events (not already swiped)
        potential_events_cursor = events_collection.find({"_id": {"$nin": swiped_event_ids}})
        potential_events = []
        async for event_doc in potential_events_cursor:
            if "vector" in event_doc and event_doc["vector"]:
                 event_doc["_id"] = str(event_doc["_id"]) # Use string ID for consistency
                 potential_events.append(event_doc)
            else:
                logger.warning(f"Event {event_doc.get('_id', 'N/A')} missing or empty vector, skipping.")

        if not potential_events:
            logger.info(f"No potential events found for initial recommendation for user {user_id_str}")
            raise HTTPException(status_code=404, detail="No more events available")

        # Calculate similarities
        similarities = []
        for event in potential_events:
            event_vector = np.array(event['vector'])
            if user_profile_vector.shape != event_vector.shape:
                logger.warning(f"Skipping event {event.get('_id')} due to vector dimension mismatch (User: {user_profile_vector.shape}, Event: {event_vector.shape}).")
                continue
            try:
                similarity = calculate_cosine_similarity(user_profile_vector, event_vector)
                similarities.append((event, similarity))
            except Exception as sim_e:
                 logger.error(f"Error calculating similarity for event {event.get('_id')}: {sim_e}")
                 continue

        # Find event with max similarity
        if not similarities:
             logger.warning(f"No valid events left after similarity calculation for user {user_id_str}")
             raise HTTPException(status_code=404, detail="No suitable events found")
             
        best_match = max(similarities, key=lambda item: item[1])
        next_event_data, highest_similarity = best_match

        # Return the details using EventResponse model
        response_data = {
            "event_id": str(next_event_data["_id"]), 
            "name": next_event_data.get("name", "Unknown Event"),
            "description": next_event_data.get("description", "No description"),
            "similarity": highest_similarity
        }
        return EventResponse(**response_data)

    except HTTPException: # Re-raise specific HTTP exceptions
        raise
    except Exception as e:
        logger.exception(f"Unexpected error getting initial recommendation for user {user_id_str}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error getting recommendation")
