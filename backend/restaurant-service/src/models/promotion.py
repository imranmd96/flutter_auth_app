from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class PromotionType(str, Enum):
    PERCENTAGE = "percentage"
    FIXED_AMOUNT = "fixed_amount"
    BUY_ONE_GET_ONE = "bogo"
    FREE_ITEM = "free_item"
    MINIMUM_SPEND = "minimum_spend"
    HAPPY_HOUR = "happy_hour"
    SPECIAL_EVENT = "special_event"
    SEASONAL = "seasonal"

class PromotionStatus(str, Enum):
    DRAFT = "draft"
    SCHEDULED = "scheduled"
    ACTIVE = "active"
    PAUSED = "paused"
    EXPIRED = "expired"
    CANCELLED = "cancelled"

class PromotionTarget(str, Enum):
    ALL = "all"
    NEW_CUSTOMERS = "new_customers"
    RETURNING_CUSTOMERS = "returning_customers"
    VIP_CUSTOMERS = "vip_customers"
    SPECIFIC_ITEMS = "specific_items"
    SPECIFIC_CATEGORIES = "specific_categories"

class PromotionBase(BaseModel):
    name: str
    description: str
    type: PromotionType
    target: PromotionTarget
    start_date: datetime
    end_date: datetime
    status: PromotionStatus = PromotionStatus.DRAFT
    terms_conditions: Optional[str] = None
    usage_limit: Optional[int] = None
    minimum_order_amount: Optional[float] = None
    maximum_discount_amount: Optional[float] = None
    days_of_week: Optional[List[int]] = None  # 0 = Monday, 6 = Sunday
    time_of_day: Optional[dict] = None  # {"start": "HH:MM", "end": "HH:MM"}
    excluded_items: Optional[List[str]] = None
    excluded_categories: Optional[List[str]] = None

class Promotion(PromotionBase):
    id: str
    restaurant_id: str
    created_at: datetime
    updated_at: datetime
    created_by: str
    updated_by: str
    total_uses: int = 0
    total_discount_amount: float = 0
    average_order_value: Optional[float] = None
    redemption_rate: Optional[float] = None

class PercentagePromotion(Promotion):
    percentage: float = Field(..., ge=0, le=100)

class FixedAmountPromotion(Promotion):
    amount: float = Field(..., gt=0)

class BuyOneGetOnePromotion(Promotion):
    eligible_items: List[str]
    free_items: List[str]

class FreeItemPromotion(Promotion):
    free_item_id: str
    minimum_purchase_amount: float

class MinimumSpendPromotion(Promotion):
    spend_amount: float
    reward_amount: float
    reward_type: PromotionType  # Can be PERCENTAGE or FIXED_AMOUNT

class HappyHourPromotion(Promotion):
    discount_percentage: float = Field(..., ge=0, le=100)
    eligible_categories: List[str]
    time_slots: List[dict]  # List of {"day": int, "start": "HH:MM", "end": "HH:MM"}

class PromotionCreate(PromotionBase):
    pass

class PromotionUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[PromotionStatus] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    terms_conditions: Optional[str] = None
    usage_limit: Optional[int] = None
    minimum_order_amount: Optional[float] = None
    maximum_discount_amount: Optional[float] = None
    days_of_week: Optional[List[int]] = None
    time_of_day: Optional[dict] = None
    excluded_items: Optional[List[str]] = None
    excluded_categories: Optional[List[str]] = None

class PromotionUsage(BaseModel):
    id: str
    promotion_id: str
    restaurant_id: str
    customer_id: str
    order_id: str
    used_at: datetime
    discount_amount: float
    order_amount: float
    items: List[str]  # List of item IDs that were part of the order

class PromotionStats(BaseModel):
    promotion_id: str
    restaurant_id: str
    total_uses: int
    total_discount_amount: float
    average_order_value: float
    redemption_rate: float
    customer_demographics: Optional[dict] = None
    popular_items: Optional[List[dict]] = None
    peak_usage_times: Optional[List[dict]] = None
    revenue_impact: Optional[dict] = None 