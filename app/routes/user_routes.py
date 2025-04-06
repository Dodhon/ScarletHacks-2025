from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
from pydantic import BaseModel
from app.users.user_functions import get_user, get_users
from app.models.user_models import User, UserPublic, UserRegistering
from app.middleware.auth_functions import get_password_hash
from app.config.db import get_mongo_client, get_database

router = APIRouter()


mongo_client = get_mongo_client()
db = get_database(mongo_client, "match_cause_db")

@router.get("/users/{username}", tags=["users"], response_model=User)
async def user_profile(username: str):
    """Fetch a user's profile by username."""
    user = get_user(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.get("/users")
async def users():
    """Fetch all users."""
    users = get_users()
    if not users:
        raise HTTPException(status_code=404, detail="User not found")
    return users


@router.post("/users/register", tags=["users"], response_model=UserPublic)
async def register(user: UserRegistering):
    """Register a new user."""
    existing_user = get_user(user.username)
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    hashed_password = get_password_hash(user.password)
    user_dict = user.model_dump()
    user_dict["hashed_password"] = hashed_password
    user_dict.pop("password")
    user_dict["disabled"] = False

    result = db["users"].insert_one(user_dict)
    user_dict["_id"] = str(result.inserted_id)
    
    return user_dict
