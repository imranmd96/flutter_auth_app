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

class MovementType(str, Enum):
    PURCHASE = "purchase"
    SALE = "sale"
    ADJUSTMENT = "adjustment"
    TRANSFER = "transfer"
    WASTE = "waste"
    RETURN = "return"

class UnitType(str, Enum):
    PIECE = "piece"
    KILOGRAM = "kilogram"
    GRAM = "gram"
    LITER = "liter"
    MILLILITER = "milliliter"
    PACK = "pack"
    BOX = "box"
    CASE = "case"

class Supplier(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    name: str
    contact_person: str
    email: str
    phone: str
    address: str
    tax_id: Optional[str] = None
    payment_terms: Optional[str] = None
    notes: Optional[str] = None
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class InventoryItem(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    name: str
    description: Optional[str] = None
    sku: str
    category: str
    unit: UnitType
    current_quantity: float = 0
    minimum_quantity: float = 0
    reorder_point: float = 0
    reorder_quantity: float = 0
    cost_per_unit: float
    supplier_id: Optional[str] = None
    location: Optional[str] = None
    expiry_date: Optional[datetime] = None
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class StockMovement(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    item_id: str
    movement_type: MovementType
    quantity: float
    unit_price: float
    total_amount: float
    reference_number: Optional[str] = None
    notes: Optional[str] = None
    created_by: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class ReorderPoint(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    item_id: str
    minimum_quantity: float
    reorder_quantity: float
    supplier_id: Optional[str] = None
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class LowStockAlert(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    item_id: str
    current_quantity: float
    minimum_quantity: float
    alert_date: datetime = Field(default_factory=datetime.utcnow)
    is_resolved: bool = False
    resolved_at: Optional[datetime] = None
    resolved_by: Optional[str] = None
    notes: Optional[str] = None

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True 