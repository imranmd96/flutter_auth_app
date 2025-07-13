from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
from enum import Enum

class BookingStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SEATED = "seated"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    NO_SHOW = "no_show"

class BookingType(str, Enum):
    REGULAR = "regular"
    WALK_IN = "walk_in"
    VIP = "vip"
    GROUP = "group"

class TableStatus(str, Enum):
    AVAILABLE = "available"
    RESERVED = "reserved"
    OCCUPIED = "occupied"
    CLEANING = "cleaning"
    MAINTENANCE = "maintenance"

class Table(BaseModel):
    id: str
    restaurant_id: str
    table_number: str
    capacity: int = Field(..., gt=0)
    status: TableStatus = TableStatus.AVAILABLE
    location: Optional[str] = None
    features: List[str] = []
    created_at: datetime
    updated_at: datetime

class BookingBase(BaseModel):
    restaurant_id: str
    customer_id: str
    table_id: str
    booking_type: BookingType = BookingType.REGULAR
    party_size: int = Field(..., gt=0)
    booking_date: datetime
    start_time: datetime
    end_time: datetime
    special_requests: Optional[str] = None
    contact_phone: str
    contact_email: Optional[str] = None
    status: BookingStatus = BookingStatus.PENDING

    @validator('end_time')
    def end_time_must_be_after_start_time(cls, v, values):
        if 'start_time' in values and v <= values['start_time']:
            raise ValueError('end_time must be after start_time')
        return v

    @validator('party_size')
    def party_size_must_be_valid(cls, v, values):
        if 'table_id' in values:
            # Here you would typically check against the table's capacity
            # For now, we'll just ensure it's positive
            if v <= 0:
                raise ValueError('party_size must be positive')
        return v

class Booking(BookingBase):
    id: str
    booking_number: str
    created_at: datetime
    updated_at: datetime
    confirmed_at: Optional[datetime] = None
    seated_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    cancelled_at: Optional[datetime] = None
    no_show_at: Optional[datetime] = None
    cancellation_reason: Optional[str] = None
    waitlist_position: Optional[int] = None
    waitlist_joined_at: Optional[datetime] = None
    waitlist_notified_at: Optional[datetime] = None

class BookingCreate(BookingBase):
    pass

class BookingUpdate(BaseModel):
    status: Optional[BookingStatus] = None
    party_size: Optional[int] = Field(None, gt=0)
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    special_requests: Optional[str] = None
    contact_phone: Optional[str] = None
    contact_email: Optional[str] = None
    cancellation_reason: Optional[str] = None

class BookingFilter(BaseModel):
    restaurant_id: Optional[str] = None
    customer_id: Optional[str] = None
    status: Optional[BookingStatus] = None
    booking_type: Optional[BookingType] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    table_id: Optional[str] = None

class BookingStats(BaseModel):
    total_bookings: int
    confirmed_bookings: int
    cancelled_bookings: int
    no_shows: int
    average_party_size: float
    bookings_by_status: dict
    bookings_by_type: dict
    peak_hours: List[dict]
    popular_tables: List[dict]
    waitlist_stats: Optional[dict] = None 