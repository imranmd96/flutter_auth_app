from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    MONGODB_URI: str = "mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/menu-service?retryWrites=true&w=majority"
    MONGODB_DB_NAME: str = "menu-service"
    REDIS_URL: str = "redis://localhost:6379"
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Menu Service"
    DEBUG: bool = True
    
    # Menu specific settings
    MAX_ITEMS_PER_MENU: int = 100
    MAX_CATEGORIES_PER_MENU: int = 10
    MAX_CUSTOMIZATION_OPTIONS: int = 5
    MAX_INGREDIENTS_PER_ITEM: int = 20
    MAX_ALLERGENS_PER_ITEM: int = 10
    CACHE_TTL: int = 3600  # 1 hour in seconds
    
    # Image upload settings
    MAX_IMAGE_SIZE: int = 5 * 1024 * 1024  # 5MB
    ALLOWED_IMAGE_TYPES: list = ["image/jpeg", "image/png", "image/webp"]
    IMAGE_UPLOAD_PATH: str = "uploads/menu"
    
    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings() 