from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    MONGODB_URI: str = "mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/inventory-service?retryWrites=true&w=majority"
    MONGODB_DB_NAME: str = "inventory-service"
    REDIS_URL: str = "redis://localhost:6379"
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Inventory Service"
    DEBUG: bool = True
    
    # Inventory specific settings
    MAX_ITEMS_PER_RESTAURANT: int = 1000
    MAX_SUPPLIERS_PER_RESTAURANT: int = 50
    MAX_MOVEMENTS_PER_DAY: int = 1000
    LOW_STOCK_THRESHOLD: float = 0.2  # 20% of reorder point
    CACHE_TTL: int = 3600  # 1 hour in seconds
    
    # Alert settings
    ENABLE_LOW_STOCK_ALERTS: bool = True
    ENABLE_EXPIRY_ALERTS: bool = True
    EXPIRY_ALERT_DAYS: int = 7  # Alert 7 days before expiry
    
    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings() 