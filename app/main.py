from fastapi import FastAPI

from app.routes import user_routes, swipe_routes, event_routes
from app.middleware import auth

from fastapi.middleware.cors import CORSMiddleware
from app.config.db import connect_to_mongo, close_mongo_connection

# Setup FastAPI app with startup/shutdown events for DB connection
app = FastAPI(
    title="Event Swipe API",
    description="API for event recommendations via swiping.",
    on_startup=[connect_to_mongo],
    on_shutdown=[close_mongo_connection],
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include application routers

app.include_router(user_routes.router)
app.include_router(auth.router)
app.include_router(swipe_routes.router)
app.include_router(event_routes.router)

# Root endpoint for basic health check/info
@app.get("/")
async def root():
    return {"message": "Welcome to the Event Swipe API!"}