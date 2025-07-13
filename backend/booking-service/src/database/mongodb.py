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
        mongodb_url = os.getenv("MONGODB_URI", "mongodb://localhost:27017/forkline-booking-service")
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
        # Bookings collection indexes
        await cls.db.bookings.create_index([("booking_number", 1)], unique=True)
        await cls.db.bookings.create_index([("restaurant_id", 1), ("booking_date", 1)])
        await cls.db.bookings.create_index([("customer_id", 1), ("booking_date", 1)])
        await cls.db.bookings.create_index([("table_id", 1), ("booking_date", 1)])
        await cls.db.bookings.create_index([("status", 1), ("booking_date", 1)])
        await cls.db.bookings.create_index([("booking_type", 1), ("booking_date", 1)])
        await cls.db.bookings.create_index([("start_time", 1), ("end_time", 1)])
        await cls.db.bookings.create_index([("waitlist_position", 1)])

        # Tables collection indexes
        await cls.db.tables.create_index([("restaurant_id", 1), ("table_number", 1)], unique=True)
        await cls.db.tables.create_index([("status", 1)])
        await cls.db.tables.create_index([("capacity", 1)])
        await cls.db.tables.create_index([("features", 1)])

        # Waitlist collection indexes
        await cls.db.waitlist.create_index([("restaurant_id", 1), ("created_at", 1)])
        await cls.db.waitlist.create_index([("customer_id", 1)])
        await cls.db.waitlist.create_index([("party_size", 1)])
        await cls.db.waitlist.create_index([("status", 1)])

def get_bookings_collection():
    """Get bookings collection."""
    return MongoDB.get_database().bookings

def get_tables_collection():
    """Get tables collection."""
    return MongoDB.get_database().tables

def get_waitlist_collection():
    """Get waitlist collection."""
    return MongoDB.get_database().waitlist 