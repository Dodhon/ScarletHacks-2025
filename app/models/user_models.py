from typing import List, Optional
from pydantic import BaseModel

class UserPublic(BaseModel):
    username: str

class User(UserPublic):
    email: Optional[str] = None
    full_name: Optional[str] = None
    embedding: List[float] = []

class UserInDB(User):
    hashed_password: str

class UserRegistering(User):
    password: str
