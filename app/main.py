from fastapi import FastAPI
from .routes import user_routes, cause_routes
from .middleware import auth
from fastapi.middleware.cors import CORSMiddleware
from .services import functions
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(functions.router)
app.include_router(cause_routes.router)
app.include_router(user_routes.router)
app.include_router(auth.router)


@app.get("/")
async def root():
    return {"message": "Hello World"}