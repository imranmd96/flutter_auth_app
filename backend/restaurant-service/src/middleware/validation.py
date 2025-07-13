from fastapi import HTTPException, status
from typing import Optional, List
from datetime import datetime, time
import re
from pydantic import BaseModel, validator, EmailStr

class ValidationError(HTTPException):
    def __init__(self, detail: str):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail
        )

def validate_phone_number(phone: str) -> str:
    """Validate phone number format."""
    pattern = r'^\+?1?\d{9,15}$'
    if not re.match(pattern, phone):
        raise ValidationError("Invalid phone number format")
    return phone

def validate_email(email: str) -> str:
    """Validate email format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(pattern, email):
        raise ValidationError("Invalid email format")
    return email

def validate_opening_hours(hours: dict) -> dict:
    """Validate restaurant opening hours."""
    days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    
    for day in days:
        if day not in hours:
            raise ValidationError(f"Missing opening hours for {day}")
        
        day_hours = hours[day]
        if not isinstance(day_hours, dict):
            raise ValidationError(f"Invalid format for {day} hours")
        
        if 'open' not in day_hours or 'close' not in day_hours:
            raise ValidationError(f"Missing open/close times for {day}")
        
        try:
            open_time = datetime.strptime(day_hours['open'], '%H:%M').time()
            close_time = datetime.strptime(day_hours['close'], '%H:%M').time()
            
            if open_time >= close_time:
                raise ValidationError(f"Close time must be after open time for {day}")
        except ValueError:
            raise ValidationError(f"Invalid time format for {day}")
    
    return hours

def validate_price_range(price_range: str) -> str:
    """Validate price range format (e.g., '$', '$$', '$$$', '$$$$')."""
    valid_ranges = ['$', '$$', '$$$', '$$$$']
    if price_range not in valid_ranges:
        raise ValidationError("Invalid price range. Must be one of: $, $$, $$$, $$$$")
    return price_range

def validate_coordinates(lat: float, lng: float) -> tuple:
    """Validate geographical coordinates."""
    if not (-90 <= lat <= 90):
        raise ValidationError("Invalid latitude. Must be between -90 and 90")
    if not (-180 <= lng <= 180):
        raise ValidationError("Invalid longitude. Must be between -180 and 180")
    return lat, lng

def validate_rating(rating: float) -> float:
    """Validate rating value."""
    if not (0 <= rating <= 5):
        raise ValidationError("Rating must be between 0 and 5")
    return rating

def validate_capacity(capacity: int) -> int:
    """Validate table capacity."""
    if capacity < 1:
        raise ValidationError("Capacity must be at least 1")
    if capacity > 20:
        raise ValidationError("Capacity cannot exceed 20")
    return capacity

def validate_reservation_time(reservation_time: datetime) -> datetime:
    """Validate reservation time."""
    now = datetime.utcnow()
    if reservation_time < now:
        raise ValidationError("Reservation time cannot be in the past")
    
    # Don't allow reservations more than 30 days in advance
    max_future = now.replace(day=now.day + 30)
    if reservation_time > max_future:
        raise ValidationError("Reservations cannot be made more than 30 days in advance")
    
    return reservation_time

def validate_party_size(party_size: int, table_capacity: int) -> int:
    """Validate party size against table capacity."""
    if party_size < 1:
        raise ValidationError("Party size must be at least 1")
    if party_size > table_capacity:
        raise ValidationError(f"Party size cannot exceed table capacity of {table_capacity}")
    return party_size

def validate_menu_item_price(price: float) -> float:
    """Validate menu item price."""
    if price < 0:
        raise ValidationError("Price cannot be negative")
    if price > 1000:
        raise ValidationError("Price cannot exceed $1000")
    return price

def validate_preparation_time(minutes: int) -> int:
    """Validate menu item preparation time."""
    if minutes < 1:
        raise ValidationError("Preparation time must be at least 1 minute")
    if minutes > 120:
        raise ValidationError("Preparation time cannot exceed 120 minutes")
    return minutes

def validate_calories(calories: int) -> int:
    """Validate menu item calories."""
    if calories < 0:
        raise ValidationError("Calories cannot be negative")
    if calories > 5000:
        raise ValidationError("Calories cannot exceed 5000")
    return calories

def validate_delivery_radius(radius: float) -> float:
    """Validate delivery radius in kilometers."""
    if radius < 0:
        raise ValidationError("Delivery radius cannot be negative")
    if radius > 50:
        raise ValidationError("Delivery radius cannot exceed 50 kilometers")
    return radius

def validate_delivery_fee(fee: float) -> float:
    """Validate delivery fee."""
    if fee < 0:
        raise ValidationError("Delivery fee cannot be negative")
    if fee > 100:
        raise ValidationError("Delivery fee cannot exceed $100")
    return fee

def validate_minimum_order(amount: float) -> float:
    """Validate minimum order amount."""
    if amount < 0:
        raise ValidationError("Minimum order amount cannot be negative")
    if amount > 1000:
        raise ValidationError("Minimum order amount cannot exceed $1000")
    return amount

# Base validation models
class BaseValidationModel(BaseModel):
    class Config:
        extra = "forbid"  # Prevent extra fields
        anystr_strip_whitespace = True  # Strip whitespace from strings

class RestaurantValidationModel(BaseValidationModel):
    name: str
    description: str
    cuisine_type: str
    address: str
    phone: str
    email: str
    opening_hours: dict
    price_range: str
    delivery_radius: Optional[float] = None
    delivery_fee: Optional[float] = None
    minimum_order: Optional[float] = None

    @validator('phone')
    def validate_phone(cls, v):
        return validate_phone_number(v)

    @validator('email')
    def validate_email(cls, v):
        return validate_email(v)

    @validator('opening_hours')
    def validate_opening_hours(cls, v):
        return validate_opening_hours(v)

    @validator('price_range')
    def validate_price_range(cls, v):
        return validate_price_range(v)

    @validator('delivery_radius')
    def validate_delivery_radius(cls, v):
        if v is not None:
            return validate_delivery_radius(v)
        return v

    @validator('delivery_fee')
    def validate_delivery_fee(cls, v):
        if v is not None:
            return validate_delivery_fee(v)
        return v

    @validator('minimum_order')
    def validate_minimum_order(cls, v):
        if v is not None:
            return validate_minimum_order(v)
        return v

class MenuItemValidationModel(BaseValidationModel):
    name: str
    description: str
    price: float
    category: str
    preparation_time: int
    calories: Optional[int] = None
    is_spicy: bool = False
    is_popular: bool = False

    @validator('price')
    def validate_price(cls, v):
        return validate_menu_item_price(v)

    @validator('preparation_time')
    def validate_preparation_time(cls, v):
        return validate_preparation_time(v)

    @validator('calories')
    def validate_calories(cls, v):
        if v is not None:
            return validate_calories(v)
        return v

class TableValidationModel(BaseValidationModel):
    number: str
    capacity: int
    type: str
    location: Optional[str] = None
    is_wheelchair_accessible: bool = False

    @validator('capacity')
    def validate_capacity(cls, v):
        return validate_capacity(v)

class ReservationValidationModel(BaseValidationModel):
    table_id: str
    party_size: int
    reservation_time: datetime
    duration: int
    special_requests: Optional[str] = None

    @validator('reservation_time')
    def validate_reservation_time(cls, v):
        return validate_reservation_time(v)

    @validator('duration')
    def validate_duration(cls, v):
        if v < 30:
            raise ValidationError("Duration must be at least 30 minutes")
        if v > 240:
            raise ValidationError("Duration cannot exceed 4 hours")
        return v 