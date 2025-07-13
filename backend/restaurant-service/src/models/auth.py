from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: datetime

class TokenData(BaseModel):
    user_id: str
    role: str
    restaurant_id: Optional[str] = None

class UserRole(str, BaseModel):
    ADMIN = "admin"
    RESTAURANT_OWNER = "restaurant_owner"
    STAFF = "staff"
    CUSTOMER = "customer" 