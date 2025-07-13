from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import List, Optional

class Settings(BaseSettings):
    MONGODB_URI: str = "mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/media-service?retryWrites=true&w=majority"
    MONGODB_DB_NAME: str = "media-service"
    REDIS_URL: str = "redis://localhost:6379"
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Media Service"
    DEBUG: bool = True
    
    # Storage settings
    STORAGE_TYPE: str = "s3"  # or "local"
    STORAGE_BUCKET: str = "restaurant-media"
    STORAGE_REGION: str = "us-east-1"
    STORAGE_ENDPOINT: Optional[str] = None
    STORAGE_ACCESS_KEY: str = "your-access-key"
    STORAGE_SECRET_KEY: str = "your-secret-key"
    
    # Upload settings
    MAX_FILE_SIZE: int = 100 * 1024 * 1024  # 100MB
    ALLOWED_EXTENSIONS: List[str] = [
        "jpg", "jpeg", "png", "gif", "webp",
        "mp4", "webm",
        "mp3", "wav",
        "pdf", "doc", "docx"
    ]
    UPLOAD_EXPIRY: int = 3600  # 1 hour in seconds
    
    # Processing settings
    ENABLE_IMAGE_PROCESSING: bool = True
    ENABLE_VIDEO_PROCESSING: bool = True
    ENABLE_AUDIO_PROCESSING: bool = True
    MAX_PROCESSING_CONCURRENCY: int = 4
    
    # Cache settings
    CACHE_TTL: int = 3600  # 1 hour in seconds
    
    # Integration settings
    RESTAURANT_SERVICE_URL: str = "http://restaurant-service:3009"
    MENU_SERVICE_URL: str = "http://menu-service:3012"
    ORDER_SERVICE_URL: str = "http://order-service:3010"
    
    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings() 