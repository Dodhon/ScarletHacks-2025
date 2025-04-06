from pydantic import BaseModel
from typing import List


class Event(BaseModel):
    """
    Represents the data structure of a Event.
    """

    name: str
    location: str
    date: str
    time: str
    description: str
    category: List[str]
    link: str