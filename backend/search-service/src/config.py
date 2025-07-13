from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    MONGODB_URI: str = "mongodb+srv://imranmd96:imranmd96@book.bb9dssu.mongodb.net/search-service?retryWrites=true&w=majority"
    MONGODB_DB_NAME: str = "search-service"
    REDIS_URL: str = "redis://localhost:6379"
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Search Service"
    DEBUG: bool = True
    
    # Search specific settings
    MAX_SEARCH_RESULTS: int = 1000
    DEFAULT_PAGE_SIZE: int = 10
    MAX_PAGE_SIZE: int = 100
    CACHE_TTL: int = 3600  # 1 hour in seconds
    
    # Elasticsearch settings
    ELASTICSEARCH_URL: str = "http://elasticsearch:9200"
    ELASTICSEARCH_INDEX_PREFIX: str = "restaurant_"
    
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