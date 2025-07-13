from fastapi import APIRouter, HTTPException, Depends, Query
from typing import Optional, List
from datetime import datetime, timedelta
from bson import ObjectId

from models.staff import (
    Staff,
    StaffCreate,
    StaffUpdate,
    StaffSchedule,
    StaffPerformance,
    StaffRole,
    StaffStatus
)
from models.auth import TokenData
from middleware.auth import (
    get_current_user,
    require_restaurant_owner,
    require_restaurant_staff
)
from database.mongodb import (
    get_staff_collection,
    get_staff_schedules_collection,
    get_staff_performance_collection
)
from utils.pagination import (
    get_pagination_params,
    PaginatedResponse,
    build_mongo_query,
    build_mongo_sort,
    get_date_range_filter
)

router = APIRouter(prefix="/api/restaurants/{restaurant_id}/staff", tags=["staff"])

@router.post("", response_model=Staff)
async def create_staff(
    restaurant_id: str,
    staff: StaffCreate,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        # Verify restaurant ownership
        from bson import ObjectId
        staff_dict = staff.dict()
        staff_dict["restaurant_id"] = restaurant_id
        staff_dict["created_at"] = datetime.utcnow()
        staff_dict["updated_at"] = datetime.utcnow()
        staff_dict["created_by"] = current_user.user_id
        staff_dict["updated_by"] = current_user.user_id

        # Check if email already exists
        existing_staff = await get_staff_collection().find_one({"email": staff.email})
        if existing_staff:
            raise HTTPException(status_code=400, detail="Email already registered")

        result = await get_staff_collection().insert_one(staff_dict)
        staff_dict["id"] = str(result.inserted_id)
        return staff_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("", response_model=PaginatedResponse[Staff])
async def get_staff(
    restaurant_id: str,
    role: Optional[StaffRole] = None,
    status: Optional[StaffStatus] = None,
    search: Optional[str] = None,
    current_user: TokenData = Depends(require_restaurant_staff),
    pagination: dict = Depends(get_pagination_params)
):
    try:
        # Build base query
        query = {"restaurant_id": restaurant_id}
        
        # Add filters
        if role:
            query["role"] = role
        if status:
            query["status"] = status

        # Add text search
        if search:
            query["$or"] = [
                {"first_name": {"$regex": search, "$options": "i"}},
                {"last_name": {"$regex": search, "$options": "i"}},
                {"email": {"$regex": search, "$options": "i"}}
            ]

        # Get total count
        total = await get_staff_collection().count_documents(query)

        # Apply pagination and sorting
        skip = (pagination["page"] - 1) * pagination["size"]
        sort = build_mongo_sort(pagination["sort_by"], pagination["sort_order"])

        # Get paginated results
        cursor = get_staff_collection().find(query).skip(skip).limit(pagination["size"])
        if sort:
            cursor = cursor.sort(sort)

        staff_list = []
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            staff_list.append(document)

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

        return PaginatedResponse(items=staff_list, page_info=page_info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{staff_id}", response_model=Staff)
async def get_staff_member(
    restaurant_id: str,
    staff_id: str,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        staff = await get_staff_collection().find_one({
            "_id": ObjectId(staff_id),
            "restaurant_id": restaurant_id
        })
        if staff:
            staff["id"] = str(staff.pop("_id"))
            return staff
        raise HTTPException(status_code=404, detail="Staff member not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{staff_id}", response_model=Staff)
async def update_staff(
    restaurant_id: str,
    staff_id: str,
    staff_update: StaffUpdate,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        staff_dict = staff_update.dict(exclude_unset=True)
        staff_dict["updated_at"] = datetime.utcnow()
        staff_dict["updated_by"] = current_user.user_id

        result = await get_staff_collection().update_one(
            {"_id": ObjectId(staff_id), "restaurant_id": restaurant_id},
            {"$set": staff_dict}
        )
        
        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Staff member not found")
            
        updated_staff = await get_staff_collection().find_one({"_id": ObjectId(staff_id)})
        updated_staff["id"] = str(updated_staff.pop("_id"))
        return updated_staff
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{staff_id}")
async def delete_staff(
    restaurant_id: str,
    staff_id: str,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        result = await get_staff_collection().delete_one({
            "_id": ObjectId(staff_id),
            "restaurant_id": restaurant_id
        })
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Staff member not found")
        return {"message": "Staff member deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{staff_id}/schedule", response_model=StaffSchedule)
async def create_staff_schedule(
    restaurant_id: str,
    staff_id: str,
    schedule: StaffSchedule,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        # Verify staff exists
        staff = await get_staff_collection().find_one({
            "_id": ObjectId(staff_id),
            "restaurant_id": restaurant_id
        })
        if not staff:
            raise HTTPException(status_code=404, detail="Staff member not found")

        schedule_dict = schedule.dict()
        schedule_dict["staff_id"] = staff_id
        schedule_dict["restaurant_id"] = restaurant_id
        schedule_dict["created_at"] = datetime.utcnow()
        schedule_dict["updated_at"] = datetime.utcnow()

        result = await get_staff_schedules_collection().insert_one(schedule_dict)
        schedule_dict["id"] = str(result.inserted_id)
        return schedule_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{staff_id}/schedule", response_model=List[StaffSchedule])
async def get_staff_schedules(
    restaurant_id: str,
    staff_id: str,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        query = {
            "staff_id": staff_id,
            "restaurant_id": restaurant_id
        }

        if start_date or end_date:
            date_filter = get_date_range_filter(start_date, end_date, "week_start")
            query.update(date_filter)

        schedules = []
        cursor = get_staff_schedules_collection().find(query).sort("week_start", 1)
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            schedules.append(document)
        return schedules
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{staff_id}/performance", response_model=StaffPerformance)
async def create_staff_performance_review(
    restaurant_id: str,
    staff_id: str,
    performance: StaffPerformance,
    current_user: TokenData = Depends(require_restaurant_owner)
):
    try:
        # Verify staff exists
        staff = await get_staff_collection().find_one({
            "_id": ObjectId(staff_id),
            "restaurant_id": restaurant_id
        })
        if not staff:
            raise HTTPException(status_code=404, detail="Staff member not found")

        performance_dict = performance.dict()
        performance_dict["staff_id"] = staff_id
        performance_dict["restaurant_id"] = restaurant_id
        performance_dict["reviewer_id"] = current_user.user_id
        performance_dict["created_at"] = datetime.utcnow()
        performance_dict["updated_at"] = datetime.utcnow()

        result = await get_staff_performance_collection().insert_one(performance_dict)
        performance_dict["id"] = str(result.inserted_id)

        # Update staff performance rating
        all_reviews = []
        cursor = get_staff_performance_collection().find({
            "staff_id": staff_id,
            "restaurant_id": restaurant_id
        })
        async for review in cursor:
            all_reviews.append(review["rating"])

        avg_rating = sum(all_reviews) / len(all_reviews)
        await get_staff_collection().update_one(
            {"_id": ObjectId(staff_id)},
            {"$set": {"performance_rating": avg_rating}}
        )

        return performance_dict
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{staff_id}/performance", response_model=List[StaffPerformance])
async def get_staff_performance_reviews(
    restaurant_id: str,
    staff_id: str,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: TokenData = Depends(require_restaurant_staff)
):
    try:
        query = {
            "staff_id": staff_id,
            "restaurant_id": restaurant_id
        }

        if start_date or end_date:
            date_filter = get_date_range_filter(start_date, end_date, "review_date")
            query.update(date_filter)

        reviews = []
        cursor = get_staff_performance_collection().find(query).sort("review_date", -1)
        async for document in cursor:
            document["id"] = str(document.pop("_id"))
            reviews.append(document)
        return reviews
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 