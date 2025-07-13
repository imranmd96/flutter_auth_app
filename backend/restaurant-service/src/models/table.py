from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from enum import Enum
from datetime import datetime, time

class TableStatus(str, Enum):
    AVAILABLE = "available"
    OCCUPIED = "occupied"
    RESERVED = "reserved"
    OUT_OF_SERVICE = "out_of_service"

class TableType(str, Enum):
    INDOOR = "indoor"
    OUTDOOR = "outdoor"
    BAR = "bar"
    PRIVATE_ROOM = "private_room"
    COUNTER = "counter"

class TableBase(BaseModel):
    number: str = Field(..., min_length=1, max_length=10)
    capacity: int = Field(..., gt=0)
    type: TableType
    status: TableStatus = TableStatus.AVAILABLE
    location: Optional[Dict[str, float]] = None  # {x: float, y: float} for floor plan
    is_wheelchair_accessible: bool = False
    has_power_outlet: bool = False
    is_smoking_allowed: bool = False
    minimum_order: Optional[float] = None
    notes: Optional[str] = None

class Table(TableBase):
    id: str
    restaurant_id: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    current_reservation: Optional[Dict] = None
    last_cleaned: Optional[datetime] = None
    maintenance_notes: Optional[List[str]] = []

class ReservationStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SEATED = "seated"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    NO_SHOW = "no_show"

class ReservationBase(BaseModel):
    table_id: str
    customer_id: str
    party_size: int = Field(..., gt=0)
    reservation_time: datetime
    duration: int = Field(..., gt=0)  # in minutes
    special_requests: Optional[str] = None
    status: ReservationStatus = ReservationStatus.PENDING
    source: str = "website"  # website, phone, walk-in, etc.
    notes: Optional[str] = None

class Reservation(ReservationBase):
    id: str
    restaurant_id: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    confirmed_at: Optional[datetime] = None
    seated_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    cancelled_at: Optional[datetime] = None
    cancellation_reason: Optional[str] = None
    customer_contact: Optional[Dict[str, str]] = None  # {phone: str, email: str}
    table_number: Optional[str] = None
    server_id: Optional[str] = None
    estimated_bill: Optional[float] = None
    actual_bill: Optional[float] = None
    feedback: Optional[Dict] = None

    class Config:
        schema_extra = {
            "example": {
                "table_id": "table123",
                "customer_id": "user456",
                "party_size": 4,
                "reservation_time": "2024-02-14T19:00:00Z",
                "duration": 120,
                "special_requests": "Window seat preferred",
                "status": "pending",
                "source": "website",
                "notes": "Anniversary celebration"
            }
        } 