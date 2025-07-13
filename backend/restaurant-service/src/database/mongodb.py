from motor.motor_asyncio import AsyncIOMotorClient
from typing import Optional
import os
from dotenv import load_dotenv

load_dotenv()

class MongoDB:
    client: Optional[AsyncIOMotorClient] = None
    db = None

    @classmethod
    async def connect_to_database(cls):
        """Connect to MongoDB database."""
        mongodb_url = os.getenv("MONGODB_URI", "mongodb://localhost:27017/forkline-restaurant-service")
        cls.client = AsyncIOMotorClient(mongodb_url)
        cls.db = cls.client.get_default_database()
        
        # Create indexes
        await cls._create_indexes()

    @classmethod
    async def close_database_connection(cls):
        """Close database connection."""
        if cls.client:
            cls.client.close()
            cls.client = None
            cls.db = None

    @classmethod
    def get_database(cls):
        """Get database instance."""
        if not cls.db:
            raise Exception("Database not initialized")
        return cls.db

    @classmethod
    async def _create_indexes(cls):
        """Create database indexes."""
        # Restaurants collection indexes
        await cls.db.restaurants.create_index([("location", "2dsphere")])
        await cls.db.restaurants.create_index([("name", "text"), ("cuisine_type", "text"), ("description", "text")])
        await cls.db.restaurants.create_index("owner_id")
        await cls.db.restaurants.create_index("status")

        # Menu items collection indexes
        await cls.db.menu_items.create_index([("name", "text"), ("description", "text"), ("category", "text")])
        await cls.db.menu_items.create_index("restaurant_id")
        await cls.db.menu_items.create_index("category")
        await cls.db.menu_items.create_index("status")

        # Tables collection indexes
        await cls.db.tables.create_index("restaurant_id")
        await cls.db.tables.create_index("status")
        await cls.db.tables.create_index([("restaurant_id", 1), ("number", 1)], unique=True)

        # Reservations collection indexes
        await cls.db.reservations.create_index("restaurant_id")
        await cls.db.reservations.create_index("customer_id")
        await cls.db.reservations.create_index("table_id")
        await cls.db.reservations.create_index("status")
        await cls.db.reservations.create_index("reservation_time")

        # Staff collection indexes
        await cls.db.staff.create_index([("email", 1)], unique=True)
        await cls.db.staff.create_index("restaurant_id")
        await cls.db.staff.create_index("role")
        await cls.db.staff.create_index("status")
        await cls.db.staff.create_index([("restaurant_id", 1), ("role", 1)])

        # Staff schedules collection indexes
        await cls.db.staff_schedules.create_index("staff_id")
        await cls.db.staff_schedules.create_index("restaurant_id")
        await cls.db.staff_schedules.create_index("week_start")
        await cls.db.staff_schedules.create_index([("staff_id", 1), ("week_start", 1)], unique=True)

        # Staff performance collection indexes
        await cls.db.staff_performance.create_index("staff_id")
        await cls.db.staff_performance.create_index("restaurant_id")
        await cls.db.staff_performance.create_index("review_date")

        # Restaurant reviews collection indexes
        await cls.db.restaurant_reviews.create_index([("title", "text"), ("content", "text")])
        await cls.db.restaurant_reviews.create_index("restaurant_id")
        await cls.db.restaurant_reviews.create_index("customer_id")
        await cls.db.restaurant_reviews.create_index("status")
        await cls.db.restaurant_reviews.create_index("rating")
        await cls.db.restaurant_reviews.create_index("created_at")

        # Menu item reviews collection indexes
        await cls.db.menu_item_reviews.create_index([("title", "text"), ("content", "text")])
        await cls.db.menu_item_reviews.create_index("restaurant_id")
        await cls.db.menu_item_reviews.create_index("menu_item_id")
        await cls.db.menu_item_reviews.create_index("customer_id")
        await cls.db.menu_item_reviews.create_index("status")
        await cls.db.menu_item_reviews.create_index("rating")
        await cls.db.menu_item_reviews.create_index("created_at")

        # Review reports collection indexes
        await cls.db.review_reports.create_index("review_id")
        await cls.db.review_reports.create_index("reporter_id")
        await cls.db.review_reports.create_index("status")
        await cls.db.review_reports.create_index("created_at")

        # Promotions collection indexes
        await cls.db.promotions.create_index([("name", "text"), ("description", "text")])
        await cls.db.promotions.create_index("restaurant_id")
        await cls.db.promotions.create_index("type")
        await cls.db.promotions.create_index("status")
        await cls.db.promotions.create_index("start_date")
        await cls.db.promotions.create_index("end_date")
        await cls.db.promotions.create_index([("restaurant_id", 1), ("status", 1)])

        # Promotion usage collection indexes
        await cls.db.promotion_usage.create_index("promotion_id")
        await cls.db.promotion_usage.create_index("restaurant_id")
        await cls.db.promotion_usage.create_index("customer_id")
        await cls.db.promotion_usage.create_index("order_id")
        await cls.db.promotion_usage.create_index("used_at")

def get_restaurants_collection():
    """Get restaurants collection."""
    return MongoDB.get_database().restaurants

def get_menu_items_collection():
    """Get menu items collection."""
    return MongoDB.get_database().menu_items

def get_tables_collection():
    """Get tables collection."""
    return MongoDB.get_database().tables

def get_reservations_collection():
    """Get reservations collection."""
    return MongoDB.get_database().reservations

def get_staff_collection():
    """Get staff collection."""
    return MongoDB.get_database().staff

def get_staff_schedules_collection():
    """Get staff schedules collection."""
    return MongoDB.get_database().staff_schedules

def get_staff_performance_collection():
    """Get staff performance collection."""
    return MongoDB.get_database().staff_performance

def get_restaurant_reviews_collection():
    """Get restaurant reviews collection."""
    return MongoDB.get_database().restaurant_reviews

def get_menu_item_reviews_collection():
    """Get menu item reviews collection."""
    return MongoDB.get_database().menu_item_reviews

def get_review_reports_collection():
    """Get review reports collection."""
    return MongoDB.get_database().review_reports

def get_promotions_collection():
    """Get promotions collection."""
    return MongoDB.get_database().promotions

def get_promotion_usage_collection():
    """Get promotion usage collection."""
    return MongoDB.get_database().promotion_usage 