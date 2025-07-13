from fastapi import FastAPI, HTTPException, Depends, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
import uvicorn
import os
from dotenv import load_dotenv
from typing import Optional, List

from models.restaurant import Restaurant, RestaurantBase, RestaurantStatus
from models.menu import MenuItem, MenuItemBase, MenuItemStatus
from models.table import Table, TableBase, TableStatus, Reservation, ReservationBase, ReservationStatus
from models.auth import Token, TokenData, UserRole
from database.mongodb import MongoDB, get_restaurants_collection, get_menu_items_collection, get_tables_collection, get_reservations_collection
from middleware.auth import (
    get_current_user,
    require_role,
    require_restaurant_owner,
    require_restaurant_staff,
    create_access_token
)
from middleware.validation import (
    RestaurantValidationModel,
    MenuItemValidationModel,
    TableValidationModel,
    ReservationValidationModel
)
from utils.pagination import (
    get_pagination_params,
    apply_pagination,
    build_mongo_query,
    build_mongo_sort,
    get_date_range_filter,
    get_text_search_filter,
    get_geo_near_filter,
    PaginatedResponse
)

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI(
    title="Restaurant Service",
    description="Restaurant Management Service for ForkLine",
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

# Restaurant endpoints
@app.post("/api/restaurants", response_model=Restaurant)
async def create_restaurant(
    restaurant: RestaurantValidationModel,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        restaurant_dict = restaurant.dict()
        restaurant_dict["created_at"] = datetime.utcnow()
        restaurant_dict["updated_at"] = datetime.utcnow()
        restaurant_dict["owner_id"] = current_user.user_id
        result = await get_restaurants_collection().insert_one(restaurant_dict)
        restaurant_dict["id"] = str(result.inserted_id)
        return restaurant_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/restaurants", response_model=PaginatedResponse[Restaurant])
async def get_restaurants(
    cuisine_type: Optional[str] = None,
    status: Optional[RestaurantStatus] = None,
    min_rating: Optional[float] = None,
    has_delivery: Optional[bool] = None,
    has_reservations: Optional[bool] = None,
    search: Optional[str] = None,
    lat: Optional[float] = None,
    lng: Optional[float] = None,
    max_distance: Optional[float] = None,
    current_user: TokenData = Depends(get_current_user),
    pagination: dict = Depends(get_pagination_params)
):
    try:
        # Build base query
        query = {}
        
        # Add filters
        if cuisine_type:
            query["cuisine_type"] = cuisine_type
        if status:
            query["status"] = status
        if min_rating is not None:
            query["rating"] = {"$gte": min_rating}
        if has_delivery is not None:
            query["accepts_delivery"] = has_delivery
        if has_reservations is not None:
            query["accepts_reservations"] = has_reservations

        # Add text search
        if search:
            search_filter = get_text_search_filter(
                search,
                ["name", "description", "cuisine_type", "address"]
            )
            query.update(search_filter)

        # Add geospatial search
        if lat is not None and lng is not None:
            geo_filter = get_geo_near_filter(lat, lng, max_distance)
            query.update(geo_filter)

        # Get total count
        total = await get_restaurants_collection().count_documents(query)

        # Apply pagination and sorting
        skip = (pagination["page"] - 1) * pagination["size"]
        sort = build_mongo_sort(pagination["sort_by"], pagination["sort_order"])

        # Get paginated results
        cursor = get_restaurants_collection().find(query).skip(skip).limit(pagination["size"])
        if sort:
            cursor = cursor.sort(sort)

        restaurants = []
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            restaurants.append(document)

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

        return PaginatedResponse(items=restaurants, page_info=page_info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/restaurants/{restaurant_id}", response_model=Restaurant)
async def get_restaurant(
    restaurant_id: str,
    current_user: TokenData = Depends(get_current_user)
):
    try:
        from bson import ObjectId
        restaurant = await get_restaurants_collection().find_one({"_id": ObjectId(restaurant_id)})
        if restaurant:
            restaurant["id"] = str(restaurant.pop("_id"))
            return restaurant
        raise HTTPException(status_code=404, detail="Restaurant not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/restaurants/{restaurant_id}", response_model=Restaurant)
async def update_restaurant(
    restaurant_id: str,
    restaurant: RestaurantBase,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        from bson import ObjectId
        # Verify restaurant ownership
        existing_restaurant = await get_restaurants_collection().find_one({
            "_id": ObjectId(restaurant_id),
            "owner_id": current_user.user_id
        })
        if not existing_restaurant:
            raise HTTPException(status_code=403, detail="Not authorized to update this restaurant")

        restaurant_dict = restaurant.dict()
        restaurant_dict["updated_at"] = datetime.utcnow()
        
        result = await get_restaurants_collection().update_one(
            {"_id": ObjectId(restaurant_id)},
            {"$set": restaurant_dict}
        )
        
        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Restaurant not found")
            
        updated_restaurant = await get_restaurants_collection().find_one({"_id": ObjectId(restaurant_id)})
        updated_restaurant["id"] = str(updated_restaurant.pop("_id"))
        return updated_restaurant
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/restaurants/{restaurant_id}")
async def delete_restaurant(
    restaurant_id: str,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        from bson import ObjectId
        # Verify restaurant ownership
        existing_restaurant = await get_restaurants_collection().find_one({
            "_id": ObjectId(restaurant_id),
            "owner_id": current_user.user_id
        })
        if not existing_restaurant:
            raise HTTPException(status_code=403, detail="Not authorized to delete this restaurant")

        result = await get_restaurants_collection().delete_one({"_id": ObjectId(restaurant_id)})
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Restaurant not found")
        return {"message": "Restaurant deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Menu endpoints
@app.post("/api/restaurants/{restaurant_id}/menu-items", response_model=MenuItem)
async def create_menu_item(
    restaurant_id: str,
    menu_item: MenuItemValidationModel,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        from bson import ObjectId
        # Verify restaurant exists and user has access
        restaurant = await get_restaurants_collection().find_one({
            "_id": ObjectId(restaurant_id),
            "$or": [
                {"owner_id": current_user.user_id},
                {"staff_ids": current_user.user_id}
            ]
        })
        if not restaurant:
            raise HTTPException(status_code=403, detail="Not authorized to add menu items to this restaurant")

        menu_item_dict = menu_item.dict()
        menu_item_dict["restaurant_id"] = restaurant_id
        menu_item_dict["created_at"] = datetime.utcnow()
        menu_item_dict["updated_at"] = datetime.utcnow()
        
        result = await get_menu_items_collection().insert_one(menu_item_dict)
        menu_item_dict["id"] = str(result.inserted_id)
        return menu_item_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/restaurants/{restaurant_id}/menu-items", response_model=PaginatedResponse[MenuItem])
async def get_menu_items(
    restaurant_id: str,
    category: Optional[str] = None,
    status: Optional[MenuItemStatus] = None,
    is_spicy: Optional[bool] = None,
    is_popular: Optional[bool] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    search: Optional[str] = None,
    current_user: TokenData = Depends(get_current_user),
    pagination: dict = Depends(get_pagination_params)
):
    try:
        from bson import ObjectId
        # Build base query
        query = {"restaurant_id": restaurant_id}
        
        # Add filters
        if category:
            query["category"] = category
        if status:
            query["status"] = status
        if is_spicy is not None:
            query["is_spicy"] = is_spicy
        if is_popular is not None:
            query["is_popular"] = is_popular
        if min_price is not None or max_price is not None:
            query["price"] = {}
            if min_price is not None:
                query["price"]["$gte"] = min_price
            if max_price is not None:
                query["price"]["$lte"] = max_price

        # Add text search
        if search:
            search_filter = get_text_search_filter(
                search,
                ["name", "description", "category"]
            )
            query.update(search_filter)

        # Get total count
        total = await get_menu_items_collection().count_documents(query)

        # Apply pagination and sorting
        skip = (pagination["page"] - 1) * pagination["size"]
        sort = build_mongo_sort(pagination["sort_by"], pagination["sort_order"])

        # Get paginated results
        cursor = get_menu_items_collection().find(query).skip(skip).limit(pagination["size"])
        if sort:
            cursor = cursor.sort(sort)

        menu_items = []
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            menu_items.append(document)

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

        return PaginatedResponse(items=menu_items, page_info=page_info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Table endpoints
@app.post("/api/restaurants/{restaurant_id}/tables", response_model=Table)
async def create_table(
    restaurant_id: str,
    table: TableBase,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        from bson import ObjectId
        # Verify restaurant exists and user has access
        restaurant = await get_restaurants_collection().find_one({
            "_id": ObjectId(restaurant_id),
            "$or": [
                {"owner_id": current_user.user_id},
                {"staff_ids": current_user.user_id}
            ]
        })
        if not restaurant:
            raise HTTPException(status_code=403, detail="Not authorized to add tables to this restaurant")

        table_dict = table.dict()
        table_dict["restaurant_id"] = restaurant_id
        table_dict["created_at"] = datetime.utcnow()
        table_dict["updated_at"] = datetime.utcnow()
        
        result = await get_tables_collection().insert_one(table_dict)
        table_dict["id"] = str(result.inserted_id)
        return table_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/restaurants/{restaurant_id}/tables", response_model=list[Table])
async def get_tables(
    restaurant_id: str,
    status: TableStatus = None,
    type: str = None,
    min_capacity: int = None,
    current_user: TokenData = Depends(get_current_user)
):
    try:
        from bson import ObjectId
        query = {"restaurant_id": restaurant_id}
        if status:
            query["status"] = status
        if type:
            query["type"] = type
        if min_capacity is not None:
            query["capacity"] = {"$gte": min_capacity}

        tables = []
        cursor = get_tables_collection().find(query)
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            tables.append(document)
        return tables
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Reservation endpoints
@app.post("/api/restaurants/{restaurant_id}/reservations", response_model=Reservation)
async def create_reservation(
    restaurant_id: str,
    reservation: ReservationValidationModel,
    current_user: TokenData = Depends(get_current_user)
):
    try:
        from bson import ObjectId
        # Verify restaurant exists
        restaurant = await get_restaurants_collection().find_one({"_id": ObjectId(restaurant_id)})
        if not restaurant:
            raise HTTPException(status_code=404, detail="Restaurant not found")

        # Verify table exists and is available
        table = await get_tables_collection().find_one({
            "_id": ObjectId(reservation.table_id),
            "restaurant_id": restaurant_id,
            "status": TableStatus.AVAILABLE
        })
        if not table:
            raise HTTPException(status_code=400, detail="Table not available")

        # Check for existing reservations at the same time
        existing_reservation = await get_reservations_collection().find_one({
            "table_id": reservation.table_id,
            "reservation_time": reservation.reservation_time,
            "status": {"$in": [ReservationStatus.CONFIRMED, ReservationStatus.PENDING]}
        })
        if existing_reservation:
            raise HTTPException(status_code=400, detail="Table already reserved for this time")

        reservation_dict = reservation.dict()
        reservation_dict["restaurant_id"] = restaurant_id
        reservation_dict["customer_id"] = current_user.user_id
        reservation_dict["created_at"] = datetime.utcnow()
        reservation_dict["updated_at"] = datetime.utcnow()
        reservation_dict["table_number"] = table["number"]
        
        result = await get_reservations_collection().insert_one(reservation_dict)
        reservation_dict["id"] = str(result.inserted_id)

        # Update table status
        await get_tables_collection().update_one(
            {"_id": ObjectId(reservation.table_id)},
            {
                "$set": {
                    "status": TableStatus.RESERVED,
                    "current_reservation": reservation_dict
                }
            }
        )

        return reservation_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/restaurants/{restaurant_id}/reservations", response_model=PaginatedResponse[Reservation])
async def get_reservations(
    restaurant_id: str,
    status: Optional[ReservationStatus] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: TokenData = Depends(require_restaurant_staff),
    pagination: dict = Depends(get_pagination_params)
):
    try:
        from bson import ObjectId
        # Build base query
        query = {"restaurant_id": restaurant_id}
        
        # Add status filter
        if status:
            query["status"] = status

        # Add date range filter
        date_filter = get_date_range_filter(start_date, end_date, "reservation_time")
        query.update(date_filter)

        # Get total count
        total = await get_reservations_collection().count_documents(query)

        # Apply pagination and sorting
        skip = (pagination["page"] - 1) * pagination["size"]
        sort = build_mongo_sort(pagination["sort_by"], pagination["sort_order"])

        # Get paginated results
        cursor = get_reservations_collection().find(query).skip(skip).limit(pagination["size"])
        if sort:
            cursor = cursor.sort(sort)

        reservations = []
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            reservations.append(document)

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

        return PaginatedResponse(items=reservations, page_info=page_info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.middleware("http")
async def log_requests(request: Request, call_next):
    body = await request.body()
    print(f"[{request.method}] {request.url.path} - body: {body.decode('utf-8')}")
    response = await call_next(request)
    return response

if __name__ == "__main__":
    port = int(os.getenv("PORT", 3012))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True) 