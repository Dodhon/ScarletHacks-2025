from datetime import timedelta
from typing import Annotated
from fastapi import Depends, APIRouter, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.utils.load_env import get_JWT_key, get_algo
from app.models.token_models import Token
from app.models.user_models import UserPublic
from app.config.db import get_db
from app.middleware.auth_functions import create_access_token, authenticate_user, SECRET_KEY, ALGORITHM
from app.users.user_functions import get_user
import jwt
import logging

ACCESS_TOKEN_EXPIRE_MINUTES = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

router = APIRouter(
    tags=["authentication"]
)

@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: AsyncIOMotorDatabase = Depends(get_db)
):
    user = await authenticate_user(db=db, username=form_data.username, password=form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)], db: AsyncIOMotorDatabase = Depends(get_db)) -> UserPublic:
    """Dependency to get the current user from JWT token."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str | None = payload.get("sub")
        if username is None:
            raise credentials_exception
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )       
    except jwt.PyJWTError as decode_error:
        logging.warning(f"JWT Decode Error: {decode_error}")
        raise credentials_exception
        
    user = await get_user(db=db, username=username)
    if user is None:
        raise credentials_exception
    if getattr(user, 'disabled', False):
        raise HTTPException(status_code=400, detail="Inactive user")
        
    try:
        return UserPublic(**user.model_dump(exclude={'hashed_password', 'profile_vector'}))
    except Exception as model_e:
        logging.exception(f"Error creating UserPublic model for user {user.username}: {model_e}")
        raise credentials_exception
