from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.user_models import UserPublic, UserInDB
from typing import List
import logging


async def get_user(db: AsyncIOMotorDatabase, username: str) -> UserInDB | None:
    """Fetches a user from the DB by username."""
    if db is None:
        logging.error("DB connection is None in get_user.")
        return None
    try:
        user_data = await db["users"].find_one({"username": username})
        if user_data:
            # Convert _id before Pydantic validation
            user_data["_id"] = str(user_data["_id"])
            return UserInDB(**user_data)
        else:
            # It's okay if user not found, return None
            return None
    except Exception as e:
        logging.exception(f"Error fetching user '{username}': {e}")
        return None # Return None on error

async def get_users(db: AsyncIOMotorDatabase) -> List[UserInDB]:
    """Fetches all users from the database."""
    if db is None:
        logging.error("DB connection is None in get_users.")
        return []

    users = []
    try:
        users_data_cursor = db["users"].find({})
        async for user_data in users_data_cursor:
            try:
                # Convert _id before Pydantic validation
                user_data["_id"] = str(user_data["_id"])
                users.append(UserInDB(**user_data))
            except Exception as parse_e:
                logging.error(f"Error parsing user data for _id {user_data.get('_id')}: {parse_e}")
                # Optionally skip this user or raise an error
        return users
    except Exception as e:
        logging.exception(f"Error fetching users from database: {e}")
        return [] # Return empty list on error
