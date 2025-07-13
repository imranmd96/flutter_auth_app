from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from enum import Enum
from datetime import datetime

class DietaryOption(str, Enum):
    VEGETARIAN = "vegetarian"
    VEGAN = "vegan"
    GLUTEN_FREE = "gluten-free"
    DAIRY_FREE = "dairy-free"
    NUT_FREE = "nut-free"
    HALAL = "halal"
    KOSHER = "kosher"

class MenuItemStatus(str, Enum):
    AVAILABLE = "available"
    UNAVAILABLE = "unavailable"
    OUT_OF_STOCK = "out_of_stock"
    SEASONAL = "seasonal"

class MenuItemBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    description: str = Field(..., min_length=10, max_length=500)
    price: float = Field(..., gt=0)
    category: str = Field(..., min_length=2, max_length=50)
    preparation_time: int = Field(..., gt=0)  # in minutes
    calories: Optional[int] = Field(None, ge=0)
    dietary_options: Optional[List[DietaryOption]] = []
    allergens: Optional[List[str]] = []
    ingredients: Optional[List[str]] = []
    customization_options: Optional[Dict[str, List[str]]] = None  # e.g., {"size": ["small", "medium", "large"]}
    status: MenuItemStatus = MenuItemStatus.AVAILABLE
    image_url: Optional[str] = None
    is_spicy: bool = False
    is_popular: bool = False
    is_chef_special: bool = False
    is_seasonal: bool = False
    available_times: Optional[Dict[str, List[str]]] = None  # e.g., {"monday": ["11:00-14:00", "17:00-22:00"]}

class MenuItem(MenuItemBase):
    id: str
    restaurant_id: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    rating: Optional[float] = Field(None, ge=0, le=5)
    total_reviews: Optional[int] = Field(0, ge=0)
    order_count: Optional[int] = Field(0, ge=0)
    tags: Optional[List[str]] = []

    class Config:
        schema_extra = {
            "example": {
                "name": "Margherita Pizza",
                "description": "Classic pizza with tomato sauce, mozzarella, and basil",
                "price": 12.99,
                "category": "Pizza",
                "preparation_time": 15,
                "calories": 800,
                "dietary_options": ["vegetarian"],
                "allergens": ["gluten", "dairy"],
                "ingredients": ["dough", "tomato sauce", "mozzarella", "basil"],
                "customization_options": {
                    "size": ["small", "medium", "large"],
                    "crust": ["thin", "thick", "gluten-free"]
                },
                "status": "available",
                "image_url": "https://example.com/margherita.jpg",
                "is_spicy": False,
                "is_popular": True,
                "is_chef_special": False,
                "is_seasonal": False
            }
        }

class MenuCategory(BaseModel):
    name: str = Field(..., min_length=2, max_length=50)
    description: Optional[str] = None
    image_url: Optional[str] = None
    display_order: int = Field(0, ge=0)
    is_active: bool = True

class Menu(BaseModel):
    restaurant_id: str
    categories: List[MenuCategory]
    items: List[MenuItem]
    last_updated: Optional[datetime] = None
    is_active: bool = True
    special_offers: Optional[List[Dict]] = None  # e.g., [{"name": "Happy Hour", "discount": "20%", "time": "15:00-18:00"}] 