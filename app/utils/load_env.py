import os
from dotenv import load_dotenv

def get_db_connect():
    load_dotenv()
    return os.getenv("DB_CONNECTION_STRING")

def get_maps_key():
    load_dotenv()
    return os.getenv("MAPS_API_KEY")

def get_JWT_key():
    load_dotenv()
    return os.getenv("JWT_KEY")

def get_algo():
    load_dotenv()
    return os.getenv("ALGO")