from typing import List, Optional
from pydantic import BaseModel

class UserPublic(BaseModel):
    username: str

class User(UserPublic):
    email: Optional[str] = None
    full_name: Optional[str] = None
    address: Optional[str] = None
    dob: Optional[str] = None
    embedding: List[float] = []

class UserInDB(User):
    hashed_password: str

class UserRegistering(User):
    password: str

class UpdateVectorRequest(BaseModel):
    username: str
    user_vector: List[float]
    event_vector: List[float]
    swipe: bool
    alpha: float = 0.1