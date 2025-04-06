from passlib.context import CryptContext
from motor.motor_asyncio import AsyncIOMotorDatabase
from datetime import datetime, timedelta, timezone
from app.utils.load_env import get_JWT_key, get_algo
from app.users.user_functions import get_user
from app.models.user_models import UserInDB
import jwt
import logging

SECRET_KEY = get_JWT_key()
ALGORITHM = get_algo()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain password against a stored hash."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Generates a hash for a given password."""
    return pwd_context.hash(password)

async def authenticate_user(db: AsyncIOMotorDatabase, username: str, password: str) -> UserInDB | bool:
    """Checks if username exists and password is correct."""
    user = await get_user(db=db, username=username)
    if not user:
        return False
    if not hasattr(user, 'hashed_password') or not user.hashed_password:
        logging.error(f"User '{username}' found but missing hashed password.")
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    """Creates a JWT access token with an optional expiration delta."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15) # Default 15 mins
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

