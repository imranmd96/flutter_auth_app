from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class ReviewType(str, Enum):
    RESTAURANT = "restaurant"
    MENU_ITEM = "menu_item"
    STAFF = "staff"

class ReviewStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    REPORTED = "reported"

class ReviewBase(BaseModel):
    rating: float = Field(..., ge=1, le=5)
    title: Optional[str] = None
    content: str
    photos: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    status: ReviewStatus = ReviewStatus.PENDING

class RestaurantReview(ReviewBase):
    id: str
    restaurant_id: str
    customer_id: str
    created_at: datetime
    updated_at: datetime
    helpful_votes: int = 0
    reply: Optional[str] = None
    reply_date: Optional[datetime] = None
    reported_count: int = 0
    verified_purchase: bool = False
    visit_date: Optional[datetime] = None
    ambiance_rating: Optional[float] = None
    service_rating: Optional[float] = None
    food_rating: Optional[float] = None
    value_rating: Optional[float] = None
    cleanliness_rating: Optional[float] = None

class MenuItemReview(ReviewBase):
    id: str
    restaurant_id: str
    menu_item_id: str
    customer_id: str
    created_at: datetime
    updated_at: datetime
    helpful_votes: int = 0
    reply: Optional[str] = None
    reply_date: Optional[datetime] = None
    reported_count: int = 0
    verified_purchase: bool = False
    taste_rating: Optional[float] = None
    presentation_rating: Optional[float] = None
    portion_size_rating: Optional[float] = None
    value_rating: Optional[float] = None

class ReviewCreate(ReviewBase):
    pass

class ReviewUpdate(BaseModel):
    rating: Optional[float] = Field(None, ge=1, le=5)
    title: Optional[str] = None
    content: Optional[str] = None
    photos: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    status: Optional[ReviewStatus] = None

class ReviewReply(BaseModel):
    reply: str
    reply_date: datetime = Field(default_factory=datetime.utcnow)

class ReviewReport(BaseModel):
    review_id: str
    reporter_id: str
    reason: str
    details: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    status: ReviewStatus = ReviewStatus.REPORTED 