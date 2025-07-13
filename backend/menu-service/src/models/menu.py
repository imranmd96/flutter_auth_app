from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from bson import ObjectId
from enum import Enum

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")

class CategoryType(str, Enum):
    APPETIZER = "appetizer"
    MAIN_COURSE = "main_course"
    DESSERT = "dessert"
    BEVERAGE = "beverage"
    SIDE_DISH = "side_dish"
    SPECIAL = "special"

class DietaryInfo(str, Enum):
    VEGETARIAN = "vegetarian"
    VEGAN = "vegan"
    GLUTEN_FREE = "gluten_free"
    DAIRY_FREE = "dairy_free"
    NUT_FREE = "nut_free"
    HALAL = "halal"
    KOSHER = "kosher"

class ItemStatus(str, Enum):
    AVAILABLE = "available"
    OUT_OF_STOCK = "out_of_stock"
    DISCONTINUED = "discontinued"
    HIDDEN = "hidden"

class MenuItem(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    name: str
    description: str
    price: float
    category: CategoryType
    dietary_info: List[DietaryInfo] = []
    ingredients: List[str] = []
    allergens: List[str] = []
    calories: Optional[int] = None
    preparation_time: Optional[int] = None  # in minutes
    image_url: Optional[str] = None
    status: ItemStatus = ItemStatus.AVAILABLE
    customization_options: List[Dict[str, Any]] = []  # e.g., size, toppings, etc.
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class MenuCategory(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    name: str
    type: CategoryType
    description: Optional[str] = None
    image_url: Optional[str] = None
    display_order: int = 0
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class Menu(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    name: str
    description: Optional[str] = None
    categories: List[MenuCategory] = []
    items: List[MenuItem] = []
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class MenuVersion(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    menu_id: str
    version_number: int
    changes: List[Dict[str, Any]] = []  # Track changes made in this version
    created_at: datetime = Field(default_factory=datetime.utcnow)
    created_by: str  # User ID who created this version

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True 