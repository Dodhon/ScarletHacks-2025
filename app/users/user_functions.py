from app.models.user_models import UserPublic, User, UserInDB
from typing import List
from app.config.db import get_mongo_client, get_database
import logging

mongo_client = get_mongo_client()
db = get_database(mongo_client, "match_cause_db")


def get_user(username: str):
    """Fetches the user from the MongoDB database by username."""
    if db is None:
        logging.error("Database connection is unavailable.")
        return None
    try:
        user_data = db["users"].find_one({"username": username})
        return UserInDB(**user_data)
    except:
        logging.error("User not found.")
        return None

def get_users() -> List[User]:
    """Fetches all users from the database."""
    if db is None:
        logging.error("Database connection is unavailable.")
        return []

    try:
        users_data = db["users"].find({})
        users = [User(**user) for user in users_data]
        return users
    except Exception as e:
        logging.error(f"Error fetching users from database: {e}")
        return []
