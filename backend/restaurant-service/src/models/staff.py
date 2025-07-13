from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
from enum import Enum

class StaffRole(str, Enum):
    MANAGER = "manager"
    WAITER = "waiter"
    CHEF = "chef"
    BARTENDER = "bartender"
    HOST = "host"
    DELIVERY = "delivery"

class StaffStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    ON_LEAVE = "on_leave"
    TERMINATED = "terminated"

class StaffBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone: str
    role: StaffRole
    status: StaffStatus = StaffStatus.ACTIVE
    hire_date: datetime
    salary: float
    emergency_contact: Optional[str] = None
    address: Optional[str] = None
    documents: Optional[List[str]] = None
    notes: Optional[str] = None

class Staff(StaffBase):
    id: str
    restaurant_id: str
    created_at: datetime
    updated_at: datetime
    last_active: Optional[datetime] = None
    performance_rating: Optional[float] = None
    schedule: Optional[dict] = None
    permissions: List[str] = []

class StaffCreate(StaffBase):
    password: str

class StaffUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    role: Optional[StaffRole] = None
    status: Optional[StaffStatus] = None
    salary: Optional[float] = None
    emergency_contact: Optional[str] = None
    address: Optional[str] = None
    documents: Optional[List[str]] = None
    notes: Optional[str] = None
    schedule: Optional[dict] = None
    permissions: Optional[List[str]] = None

class StaffSchedule(BaseModel):
    staff_id: str
    restaurant_id: str
    week_start: datetime
    week_end: datetime
    shifts: List[dict]  # List of shift objects with day, start_time, end_time
    created_at: datetime
    updated_at: datetime

class StaffPerformance(BaseModel):
    staff_id: str
    restaurant_id: str
    rating: float
    review: str
    reviewer_id: str
    review_date: datetime
    metrics: Optional[dict] = None  # Additional performance metrics
    created_at: datetime
    updated_at: datetime 