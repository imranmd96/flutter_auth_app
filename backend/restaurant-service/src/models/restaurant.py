from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Dict
from datetime import time
from enum import Enum

class CuisineType(str, Enum):
    ITALIAN = "italian"
    CHINESE = "chinese"
    INDIAN = "indian"
    MEXICAN = "mexican"
    JAPANESE = "japanese"
    AMERICAN = "american"
    THAI = "thai"
    MEDITERRANEAN = "mediterranean"
    OTHER = "other"

class RestaurantStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    SUSPENDED = "suspended"
    PENDING = "pending"

class OpeningHours(BaseModel):
    monday: Optional[Dict[str, str]] = None
    tuesday: Optional[Dict[str, str]] = None
    wednesday: Optional[Dict[str, str]] = None
    thursday: Optional[Dict[str, str]] = None
    friday: Optional[Dict[str, str]] = None
    saturday: Optional[Dict[str, str]] = None
    sunday: Optional[Dict[str, str]] = None

class RestaurantBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    description: str = Field(..., min_length=10, max_length=1000)
    cuisine_type: CuisineType
    address: str = Field(..., min_length=5, max_length=200)
    phone: str = Field(..., regex=r'^\+?1?\d{9,15}$')
    email: EmailStr
    opening_hours: OpeningHours
    owner_id: str
    status: RestaurantStatus = RestaurantStatus.ACTIVE
    capacity: int = Field(..., gt=0)
    price_range: str = Field(..., regex=r'^\$+\s*-\s*\$+$')
    delivery_radius: Optional[float] = Field(None, ge=0, le=50)  # in kilometers
    delivery_fee: Optional[float] = Field(None, ge=0)
    minimum_order: Optional[float] = Field(None, ge=0)
    accepts_reservations: bool = True
    accepts_delivery: bool = True
    accepts_takeout: bool = True
    has_parking: bool = False
    is_wheelchair_accessible: bool = False
    has_outdoor_seating: bool = False
    has_wifi: bool = False
    accepts_credit_cards: bool = True
    accepts_cash: bool = True

class Restaurant(RestaurantBase):
    id: str
    rating: Optional[float] = Field(None, ge=0, le=5)
    total_reviews: Optional[int] = Field(0, ge=0)
    menu_items: Optional[List[str]] = []
    tables: Optional[List[dict]] = []
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    location: Optional[Dict[str, float]] = None  # {latitude: float, longitude: float}
    images: Optional[List[str]] = []  # URLs to restaurant images
    features: Optional[List[str]] = []  # Additional features/amenities
    payment_methods: Optional[List[str]] = []
    dietary_options: Optional[List[str]] = []  # e.g., ["vegetarian", "vegan", "gluten-free"]
    tags: Optional[List[str]] = []  # For search and filtering

    class Config:
        schema_extra = {
            "example": {
                "name": "La Bella Italia",
                "description": "Authentic Italian cuisine in a cozy atmosphere",
                "cuisine_type": "italian",
                "address": "123 Main St, City, Country",
                "phone": "+1234567890",
                "email": "info@labellaitalia.com",
                "opening_hours": {
                    "monday": {"open": "09:00", "close": "22:00"},
                    "tuesday": {"open": "09:00", "close": "22:00"},
                    "wednesday": {"open": "09:00", "close": "22:00"},
                    "thursday": {"open": "09:00", "close": "22:00"},
                    "friday": {"open": "09:00", "close": "23:00"},
                    "saturday": {"open": "10:00", "close": "23:00"},
                    "sunday": {"open": "10:00", "close": "22:00"}
                },
                "owner_id": "user123",
                "status": "active",
                "capacity": 100,
                "price_range": "$$ - $$$",
                "delivery_radius": 5.0,
                "delivery_fee": 2.99,
                "minimum_order": 15.00
            }
        } 