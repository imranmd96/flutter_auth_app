from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import analytics
from .database.mongodb import mongodb
from .config import settings

app = FastAPI(
    title="Analytics Service",
    description="Service for tracking and analyzing restaurant performance metrics",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(
    analytics.router,
    prefix=f"{settings.API_V1_STR}/analytics",
    tags=["analytics"]
)

@app.on_event("startup")
async def startup_db_client():
    await mongodb.connect_to_mongodb()

@app.on_event("shutdown")
async def shutdown_db_client():
    await mongodb.close_mongodb_connection()

@app.get("/")
async def root():
        return {
        "message": "Welcome to the Analytics Service API",
        "version": "1.0.0",
        "docs_url": f"{settings.API_V1_STR}/docs"
    } 