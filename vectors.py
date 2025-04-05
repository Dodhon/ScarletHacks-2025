from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
import os
from dotenv import load_dotenv

load_dotenv()

password = os.environ.get("DB_PASSWORD") 
if not password:
    raise ValueError("MongoDB password not found in environment variable DB_PASSWORD")

uri = os.environ.get("DB_CONNECTION_STRING")

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi('1'))

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)