from motor.motor_asyncio import AsyncIOMotorClient
from ..config import settings

class MongoDB:
    client: AsyncIOMotorClient = None
    db = None

    async def connect_to_mongodb(self):
        self.client = AsyncIOMotorClient(settings.MONGODB_URI)
        self.db = self.client[settings.MONGODB_DB_NAME]
        print("Connected to MongoDB.")

    async def close_mongodb_connection(self):
        if self.client:
            self.client.close()
            print("MongoDB connection closed.")

    async def get_collection(self, collection_name: str):
        return self.db[collection_name]

mongodb = MongoDB() 