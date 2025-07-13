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

class MetricType(str, Enum):
    REVENUE = "revenue"
    ORDERS = "orders"
    CUSTOMERS = "customers"
    RATINGS = "ratings"
    INVENTORY = "inventory"
    STAFF = "staff"
    MARKETING = "marketing"

class TimeInterval(str, Enum):
    HOURLY = "hourly"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    YEARLY = "yearly"

class RestaurantMetrics(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    date: datetime
    interval: TimeInterval
    metrics: Dict[str, float] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class CustomerMetrics(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    customer_id: str
    total_orders: int = 0
    total_spent: float = 0
    average_order_value: float = 0
    last_order_date: Optional[datetime] = None
    favorite_items: List[str] = Field(default_factory=list)
    dietary_preferences: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class MenuAnalytics(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    item_id: str
    total_orders: int = 0
    total_revenue: float = 0
    average_rating: float = 0
    popularity_score: float = 0
    category_performance: Dict[str, float] = Field(default_factory=dict)
    time_based_metrics: Dict[str, Dict[str, float]] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class StaffPerformance(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    staff_id: str
    total_orders_handled: int = 0
    average_order_time: float = 0
    customer_satisfaction: float = 0
    efficiency_score: float = 0
    performance_metrics: Dict[str, float] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class MarketingAnalytics(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    campaign_id: str
    total_reach: int = 0
    total_engagement: int = 0
    conversion_rate: float = 0
    revenue_generated: float = 0
    roi: float = 0
    channel_performance: Dict[str, Dict[str, float]] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class InventoryAnalytics(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    item_id: str
    total_usage: float = 0
    waste_percentage: float = 0
    cost_efficiency: float = 0
    stock_turnover: float = 0
    reorder_frequency: float = 0
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class AnalyticsReport(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    restaurant_id: str
    report_type: MetricType
    start_date: datetime
    end_date: datetime
    metrics: Dict[str, Any] = Field(default_factory=dict)
    insights: List[str] = Field(default_factory=list)
    recommendations: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True 