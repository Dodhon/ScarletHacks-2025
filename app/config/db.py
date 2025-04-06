import logging

# Change pymongo imports to motor
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase 
# from pymongo import MongoClient
# from pymongo.database import Database

from pymongo.server_api import ServerApi
from app.utils.load_env import get_db_connect, get_db_name

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variable to hold the async client
_mongo_client: AsyncIOMotorClient | None = None

def connect_to_mongo():
    """Establishes the async MongoDB client connection on startup."""
    global _mongo_client
    uri = get_db_connect()
    if not uri:
        logging.error("MongoDB connection URI not found. Set DB_CONNECTION_STRING env var.")
        return
    
    try:
        _mongo_client = AsyncIOMotorClient(uri, server_api=ServerApi('1'))
        # Add a basic check to confirm connection during startup
        # _mongo_client.admin.command('ping') # Example check
        logging.info("Successfully established async connection to MongoDB.")
    except Exception as e:
        _mongo_client = None
        logging.exception(f"Failed to connect to MongoDB asynchronously: {e}")

def close_mongo_connection():
    """Closes the async MongoDB client connection on shutdown."""
    global _mongo_client
    if _mongo_client:
        _mongo_client.close()
        logging.info("Async MongoDB connection closed.")

def get_db() -> AsyncIOMotorDatabase:
    """FastAPI dependency to yield the async database instance."""
    if not _mongo_client:
        logging.error("Async MongoDB client not initialized. Check startup logs.")
        # Should not happen if connect_to_mongo is called successfully on startup
        raise Exception("Async MongoDB client not initialized.")
    
    db_name = get_db_name()
    if not db_name:
        logging.error("Database name not found. Set DB_NAME env var.")
        raise Exception("Database name not configured.")
        
    try:

        return _mongo_client[db_name]

    except Exception as e:
        logging.exception(f"Could not get async database '{db_name}': {e}")
        raise Exception(f"Could not get async database '{db_name}'") from e

# Note: connect_to_mongo should be called in FastAPI startup event handler
# And close_mongo_connection in shutdown event handler.


# Optional: Call connect_to_mongo here if you want the connection 
# established when this module is imported, but it's better 
# practice to use FastAPI startup events.
# connect_to_mongo() 

