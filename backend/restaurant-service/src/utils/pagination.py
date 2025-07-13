from typing import TypeVar, Generic, List, Optional, Dict, Any
from pydantic import BaseModel
from fastapi import Query
from datetime import datetime

T = TypeVar('T')

class PageInfo(BaseModel):
    page: int
    size: int
    total: int
    total_pages: int
    has_next: bool
    has_previous: bool

class PaginatedResponse(BaseModel, Generic[T]):
    items: List[T]
    page_info: PageInfo

class FilterParams(BaseModel):
    """Base class for filter parameters"""
    pass

class SortParams(BaseModel):
    """Base class for sort parameters"""
    sort_by: Optional[str] = None
    sort_order: Optional[str] = "asc"

def get_pagination_params(
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Items per page"),
    sort_by: Optional[str] = Query(None, description="Field to sort by"),
    sort_order: Optional[str] = Query("asc", description="Sort order (asc/desc)")
) -> Dict[str, Any]:
    """Get pagination and sorting parameters from query."""
    return {
        "page": page,
        "size": size,
        "sort_by": sort_by,
        "sort_order": sort_order
    }

def apply_pagination(
    items: List[Any],
    page: int,
    size: int,
    sort_by: Optional[str] = None,
    sort_order: Optional[str] = "asc"
) -> PaginatedResponse:
    """Apply pagination and sorting to a list of items."""
    # Apply sorting if specified
    if sort_by:
        items = sorted(
            items,
            key=lambda x: getattr(x, sort_by, None),
            reverse=(sort_order.lower() == "desc")
        )

    # Calculate pagination
    total = len(items)
    total_pages = (total + size - 1) // size
    start_idx = (page - 1) * size
    end_idx = start_idx + size

    # Get items for current page
    page_items = items[start_idx:end_idx]

    # Create page info
    page_info = PageInfo(
        page=page,
        size=size,
        total=total,
        total_pages=total_pages,
        has_next=page < total_pages,
        has_previous=page > 1
    )

    return PaginatedResponse(items=page_items, page_info=page_info)

def build_mongo_query(filters: Dict[str, Any]) -> Dict[str, Any]:
    """Build MongoDB query from filter parameters."""
    query = {}
    
    for field, value in filters.items():
        if value is None:
            continue
            
        if isinstance(value, (int, float, str, bool)):
            query[field] = value
        elif isinstance(value, list):
            query[field] = {"$in": value}
        elif isinstance(value, dict):
            if "min" in value and "max" in value:
                query[field] = {
                    "$gte": value["min"],
                    "$lte": value["max"]
                }
            elif "min" in value:
                query[field] = {"$gte": value["min"]}
            elif "max" in value:
                query[field] = {"$lte": value["max"]}
            elif "in" in value:
                query[field] = {"$in": value["in"]}
            elif "nin" in value:
                query[field] = {"$nin": value["nin"]}
            elif "regex" in value:
                query[field] = {"$regex": value["regex"], "$options": "i"}
    
    return query

def build_mongo_sort(sort_by: Optional[str], sort_order: Optional[str]) -> List[tuple]:
    """Build MongoDB sort parameters."""
    if not sort_by:
        return []
        
    order = -1 if sort_order and sort_order.lower() == "desc" else 1
    return [(sort_by, order)]

def get_date_range_filter(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    field: str = "created_at"
) -> Dict[str, Any]:
    """Build date range filter for MongoDB query."""
    date_filter = {}
    
    if start_date:
        date_filter["$gte"] = start_date
    if end_date:
        date_filter["$lte"] = end_date
        
    return {field: date_filter} if date_filter else {}

def get_text_search_filter(
    search_term: Optional[str] = None,
    fields: List[str] = None
) -> Dict[str, Any]:
    """Build text search filter for MongoDB query."""
    if not search_term or not fields:
        return {}
        
    return {
        "$or": [
            {field: {"$regex": search_term, "$options": "i"}}
            for field in fields
        ]
    }

def get_geo_near_filter(
    lat: float,
    lng: float,
    max_distance: Optional[float] = None,
    field: str = "location"
) -> Dict[str, Any]:
    """Build geospatial query filter for MongoDB."""
    geo_filter = {
        field: {
            "$near": {
                "$geometry": {
                    "type": "Point",
                    "coordinates": [lng, lat]
                }
            }
        }
    }
    
    if max_distance:
        geo_filter[field]["$near"]["$maxDistance"] = max_distance * 1000  # Convert km to meters
        
    return geo_filter 