from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordRequestForm
from motor.motor_asyncio import AsyncIOMotorDatabase
from typing import List
import logging

from app.users.user_functions import get_user, get_users

from app.models.user_models import UserPublic, UserInDB, UserCreate

from app.middleware.auth_functions import get_password_hash
from app.config.db import get_db
from app.middleware.auth import get_current_user

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/me", response_model=UserPublic)
async def read_users_me(current_user: UserPublic = Depends(get_current_user)):
    """Fetch the profile of the currently authenticated user."""
    return current_user

@router.get("/{username}", response_model=UserPublic)
async def user_profile(username: str, db: AsyncIOMotorDatabase = Depends(get_db)):
    """Fetch a user's public profile by username."""
    user = await get_user(db=db, username=username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.get("/", response_model=List[UserPublic])
async def read_users(db: AsyncIOMotorDatabase = Depends(get_db)):
    """Fetch all users (public profiles)."""
    users_in_db = await get_users(db=db)
    return users_in_db


@router.post("/register", response_model=UserPublic)
async def register(user: UserCreate, db: AsyncIOMotorDatabase = Depends(get_db)):

    """Register a new user."""
    existing_user = await get_user(db=db, username=user.username)
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    if not hasattr(user, 'password') or not user.password:
        raise HTTPException(status_code=400, detail="Password is required")

    hashed_password = get_password_hash(user.password)
    
    user_data_for_db = user.model_dump(exclude={"password"})
    user_data_for_db["hashed_password"] = hashed_password
    user_data_for_db["disabled"] = False
    user_data_for_db["profile_vector"] = []

    try:
        result = await db["users"].insert_one(user_data_for_db)
        response_data = user_data_for_db.copy()
        del response_data['hashed_password']
        if 'profile_vector' in response_data:
            del response_data['profile_vector']
        response_data["id"] = str(result.inserted_id)
        return UserPublic(**response_data)
    except Exception as e:
        logging.exception(f"Error registering user '{user.username}': {e}")
        raise HTTPException(status_code=500, detail="Error registering user")
