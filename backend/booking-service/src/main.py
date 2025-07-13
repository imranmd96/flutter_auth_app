from fastapi import FastAPI, HTTPException, Depends, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
import uvicorn
import os
from dotenv import load_dotenv
from typing import Optional, List
from bson import ObjectId

from models.booking import (
    Booking,
    BookingCreate,
    BookingUpdate,
    BookingFilter,
    BookingStats,
    BookingStatus,
    BookingType,
    Table,
    TableStatus
)
from models.auth import TokenData
from middleware.auth import (
    get_current_user,
    require_role,
    require_restaurant_owner,
    require_restaurant_staff
)
from database.mongodb import (
    MongoDB,
    get_bookings_collection,
    get_tables_collection,
    get_waitlist_collection
)
from utils.pagination import (
    get_pagination_params,
    PaginatedResponse,
    build_mongo_sort,
    get_date_range_filter
)

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI(
    title="Booking Service",
    description="Table Booking and Reservation Service for ForkLine",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Startup and shutdown events
@app.on_event("startup")
async def startup_db_client():
    await MongoDB.connect_to_database()

@app.on_event("shutdown")
async def shutdown_db_client():
    await MongoDB.close_database_connection()

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "ok", "timestamp": datetime.utcnow()}

# Table endpoints
@app.post("/api/tables", response_model=Table)
async def create_table(
    table: Table,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        table_dict = table.dict()
        table_dict["created_at"] = datetime.utcnow()
        table_dict["updated_at"] = datetime.utcnow()
        
        result = await get_tables_collection().insert_one(table_dict)
        table_dict["id"] = str(result.inserted_id)
        
        return table_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/tables", response_model=PaginatedResponse[Table])
async def get_tables(
    restaurant_id: str,
    status: Optional[TableStatus] = None,
    min_capacity: Optional[int] = None,
    features: Optional[List[str]] = None,
    current_user: TokenData = Depends(get_current_user),
    pagination: dict = Depends(get_pagination_params)
):
    try:
        # Build query
        query = {"restaurant_id": restaurant_id}
        if status:
            query["status"] = status
        if min_capacity:
            query["capacity"] = {"$gte": min_capacity}
        if features:
            query["features"] = {"$all": features}

        # Get total count
        total = await get_tables_collection().count_documents(query)

        # Apply pagination and sorting
        skip = (pagination["page"] - 1) * pagination["size"]
        sort = build_mongo_sort(pagination["sort_by"], pagination["sort_order"])

        # Get paginated results
        cursor = get_tables_collection().find(query).skip(skip).limit(pagination["size"])
        if sort:
            cursor = cursor.sort(sort)

        tables = []
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            tables.append(document)

        # Create pagination info
        total_pages = (total + pagination["size"] - 1) // pagination["size"]
        page_info = {
            "page": pagination["page"],
            "size": pagination["size"],
            "total": total,
            "total_pages": total_pages,
            "has_next": pagination["page"] < total_pages,
            "has_previous": pagination["page"] > 1
        }

        return PaginatedResponse(items=tables, page_info=page_info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Booking endpoints
@app.post("/api/bookings", response_model=Booking)
async def create_booking(
    booking: BookingCreate,
    current_user: TokenData = Depends(get_current_user)
):
    try:
        # Check table availability
        table = await get_tables_collection().find_one({
            "_id": ObjectId(booking.table_id),
            "status": TableStatus.AVAILABLE
        })
        if not table:
            raise HTTPException(status_code=400, detail="Table not available")

        # Check for overlapping bookings
        overlapping = await get_bookings_collection().find_one({
            "table_id": booking.table_id,
            "booking_date": booking.booking_date,
            "status": {"$in": [BookingStatus.CONFIRMED, BookingStatus.SEATED]},
            "$or": [
                {
                    "start_time": {"$lt": booking.end_time},
                    "end_time": {"$gt": booking.start_time}
                }
            ]
        })
        if overlapping:
            raise HTTPException(status_code=400, detail="Time slot not available")

        booking_dict = booking.dict()
        booking_dict["customer_id"] = current_user.user_id
        booking_dict["created_at"] = datetime.utcnow()
        booking_dict["updated_at"] = datetime.utcnow()
        
        # Generate booking number
        booking_dict["booking_number"] = f"BK-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{current_user.user_id[:6]}"
        
        result = await get_bookings_collection().insert_one(booking_dict)
        booking_dict["id"] = str(result.inserted_id)
        
        # Update table status
        await get_tables_collection().update_one(
            {"_id": ObjectId(booking.table_id)},
            {"$set": {"status": TableStatus.RESERVED}}
        )
        
        return booking_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/bookings", response_model=PaginatedResponse[Booking])
async def get_bookings(
    restaurant_id: Optional[str] = None,
    customer_id: Optional[str] = None,
    status: Optional[BookingStatus] = None,
    booking_type: Optional[BookingType] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: TokenData = Depends(get_current_user),
    pagination: dict = Depends(get_pagination_params)
):
    try:
        # Build query
        query = {}
        if restaurant_id:
            query["restaurant_id"] = restaurant_id
        if customer_id:
            query["customer_id"] = customer_id
        if status:
            query["status"] = status
        if booking_type:
            query["booking_type"] = booking_type

        # Add date range filter
        if start_date or end_date:
            date_filter = get_date_range_filter(start_date, end_date, "booking_date")
            query.update(date_filter)

        # Get total count
        total = await get_bookings_collection().count_documents(query)

        # Apply pagination and sorting
        skip = (pagination["page"] - 1) * pagination["size"]
        sort = build_mongo_sort(pagination["sort_by"], pagination["sort_order"])

        # Get paginated results
        cursor = get_bookings_collection().find(query).skip(skip).limit(pagination["size"])
        if sort:
            cursor = cursor.sort(sort)

        bookings = []
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            bookings.append(document)

        # Create pagination info
        total_pages = (total + pagination["size"] - 1) // pagination["size"]
        page_info = {
            "page": pagination["page"],
            "size": pagination["size"],
            "total": total,
            "total_pages": total_pages,
            "has_next": pagination["page"] < total_pages,
            "has_previous": pagination["page"] > 1
        }

        return PaginatedResponse(items=bookings, page_info=page_info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/bookings/{booking_id}", response_model=Booking)
async def get_booking(
    booking_id: str,
    current_user: TokenData = Depends(get_current_user)
):
    try:
        booking = await get_bookings_collection().find_one({"_id": ObjectId(booking_id)})
        if booking:
            booking["id"] = str(booking.pop("_id"))
            return booking
        raise HTTPException(status_code=404, detail="Booking not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/bookings/{booking_id}", response_model=Booking)
async def update_booking(
    booking_id: str,
    booking_update: BookingUpdate,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        update_dict = booking_update.dict(exclude_unset=True)
        update_dict["updated_at"] = datetime.utcnow()

        # Update booking
        result = await get_bookings_collection().update_one(
            {"_id": ObjectId(booking_id)},
            {"$set": update_dict}
        )
        
        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Booking not found")

        # Update table status if booking is cancelled
        if update_dict.get("status") == BookingStatus.CANCELLED:
            booking = await get_bookings_collection().find_one({"_id": ObjectId(booking_id)})
            await get_tables_collection().update_one(
                {"_id": ObjectId(booking["table_id"])},
                {"$set": {"status": TableStatus.AVAILABLE}}
            )
            
        updated_booking = await get_bookings_collection().find_one({"_id": ObjectId(booking_id)})
        updated_booking["id"] = str(updated_booking.pop("_id"))
        return updated_booking
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/bookings/{booking_id}/join-waitlist")
async def join_waitlist(
    booking_id: str,
    current_user: TokenData = Depends(get_current_user)
):
    try:
        # Get booking
        booking = await get_bookings_collection().find_one({"_id": ObjectId(booking_id)})
        if not booking:
            raise HTTPException(status_code=404, detail="Booking not found")

        # Check if already on waitlist
        existing = await get_waitlist_collection().find_one({
            "booking_id": booking_id,
            "status": "waiting"
        })
        if existing:
            raise HTTPException(status_code=400, detail="Already on waitlist")

        # Get waitlist position
        position = await get_waitlist_collection().count_documents({
            "restaurant_id": booking["restaurant_id"],
            "status": "waiting"
        }) + 1

        # Add to waitlist
        waitlist_dict = {
            "booking_id": booking_id,
            "restaurant_id": booking["restaurant_id"],
            "customer_id": current_user.user_id,
            "party_size": booking["party_size"],
            "position": position,
            "status": "waiting",
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        await get_waitlist_collection().insert_one(waitlist_dict)

        # Update booking
        await get_bookings_collection().update_one(
            {"_id": ObjectId(booking_id)},
            {
                "$set": {
                    "waitlist_position": position,
                    "waitlist_joined_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                }
            }
        )

        return {"message": "Added to waitlist", "position": position}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/restaurants/{restaurant_id}/bookings/stats", response_model=BookingStats)
async def get_restaurant_booking_stats(
    restaurant_id: str,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        # Build query
        query = {"restaurant_id": restaurant_id}
        if start_date or end_date:
            date_filter = get_date_range_filter(start_date, end_date, "booking_date")
            query.update(date_filter)

        # Get total bookings and stats
        pipeline = [
            {"$match": query},
            {
                "$group": {
                    "_id": None,
                    "total_bookings": {"$sum": 1},
                    "confirmed_bookings": {
                        "$sum": {"$cond": [{"$eq": ["$status", "confirmed"]}, 1, 0]}
                    },
                    "cancelled_bookings": {
                        "$sum": {"$cond": [{"$eq": ["$status", "cancelled"]}, 1, 0]}
                    },
                    "no_shows": {
                        "$sum": {"$cond": [{"$eq": ["$status", "no_show"]}, 1, 0]}
                    },
                    "total_party_size": {"$sum": "$party_size"}
                }
            }
        ]
        result = await get_bookings_collection().aggregate(pipeline).to_list(1)
        
        if not result:
            return {
                "total_bookings": 0,
                "confirmed_bookings": 0,
                "cancelled_bookings": 0,
                "no_shows": 0,
                "average_party_size": 0,
                "bookings_by_status": {},
                "bookings_by_type": {},
                "peak_hours": [],
                "popular_tables": []
            }

        stats = result[0]
        stats["average_party_size"] = stats["total_party_size"] / stats["total_bookings"]

        # Get bookings by status
        status_pipeline = [
            {"$match": query},
            {"$group": {"_id": "$status", "count": {"$sum": 1}}}
        ]
        status_stats = await get_bookings_collection().aggregate(status_pipeline).to_list(None)
        bookings_by_status = {stat["_id"]: stat["count"] for stat in status_stats}

        # Get bookings by type
        type_pipeline = [
            {"$match": query},
            {"$group": {"_id": "$booking_type", "count": {"$sum": 1}}}
        ]
        type_stats = await get_bookings_collection().aggregate(type_pipeline).to_list(None)
        bookings_by_type = {stat["_id"]: stat["count"] for stat in type_stats}

        # Get peak hours
        hours_pipeline = [
            {"$match": query},
            {
                "$group": {
                    "_id": {"$hour": "$start_time"},
                    "count": {"$sum": 1}
                }
            },
            {"$sort": {"_id": 1}}
        ]
        peak_hours = await get_bookings_collection().aggregate(hours_pipeline).to_list(None)

        # Get popular tables
        tables_pipeline = [
            {"$match": query},
            {"$group": {"_id": "$table_id", "count": {"$sum": 1}}},
            {"$sort": {"count": -1}},
            {"$limit": 10}
        ]
        popular_tables = await get_bookings_collection().aggregate(tables_pipeline).to_list(None)

        # Get waitlist stats
        waitlist_pipeline = [
            {"$match": {"restaurant_id": restaurant_id, "status": "waiting"}},
            {
                "$group": {
                    "_id": None,
                    "total_waiting": {"$sum": 1},
                    "average_wait_time": {"$avg": {"$subtract": [datetime.utcnow(), "$created_at"]}}
                }
            }
        ]
        waitlist_stats = await get_waitlist_collection().aggregate(waitlist_pipeline).to_list(1)

        return {
            "total_bookings": stats["total_bookings"],
            "confirmed_bookings": stats["confirmed_bookings"],
            "cancelled_bookings": stats["cancelled_bookings"],
            "no_shows": stats["no_shows"],
            "average_party_size": stats["average_party_size"],
            "bookings_by_status": bookings_by_status,
            "bookings_by_type": bookings_by_type,
            "peak_hours": peak_hours,
            "popular_tables": popular_tables,
            "waitlist_stats": waitlist_stats[0] if waitlist_stats else None
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.middleware("http")
async def log_requests(request: Request, call_next):
    body = await request.body()
    print(f"[{request.method}] {request.url.path} - body: {body.decode('utf-8')}")
    response = await call_next(request)
    return response

if __name__ == "__main__":
    port = int(os.getenv("PORT", 3002))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True) 