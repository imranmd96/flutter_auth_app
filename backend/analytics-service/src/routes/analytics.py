from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from bson import ObjectId
from ..models.analytics import (
    RestaurantMetrics,
    CustomerMetrics,
    MenuAnalytics,
    StaffPerformance,
    MarketingAnalytics,
    InventoryAnalytics,
    AnalyticsReport,
    MetricType,
    TimeInterval
)
from ..database.mongodb import mongodb
from ..config import settings

router = APIRouter()

# Restaurant Metrics Routes
@router.get("/restaurant/{restaurant_id}/metrics", response_model=List[RestaurantMetrics])
async def get_restaurant_metrics(
    restaurant_id: str,
    start_date: datetime,
    end_date: datetime,
    interval: TimeInterval = TimeInterval.DAILY
):
    """Get restaurant metrics for a specific time period."""
    collection = await mongodb.get_collection("restaurant_metrics")
    cursor = collection.find({
        "restaurant_id": restaurant_id,
        "date": {"$gte": start_date, "$lte": end_date},
        "interval": interval
    }).sort("date", 1)
    metrics = await cursor.to_list(length=None)
    
    return [RestaurantMetrics(**metric) for metric in metrics]

# Customer Analytics Routes
@router.get("/customers/{customer_id}/metrics", response_model=CustomerMetrics)
async def get_customer_metrics(customer_id: str):
    """Get analytics for a specific customer."""
    collection = await mongodb.get_collection("customer_metrics")
    metrics = await collection.find_one({"customer_id": customer_id})
    
    if not metrics:
        raise HTTPException(status_code=404, detail="Customer metrics not found")
    
    return CustomerMetrics(**metrics)

@router.get("/restaurant/{restaurant_id}/customers/top", response_model=List[CustomerMetrics])
async def get_top_customers(
    restaurant_id: str,
    limit: int = Query(10, ge=1, le=100),
    sort_by: str = "total_spent"
):
    """Get top customers for a restaurant."""
    collection = await mongodb.get_collection("customer_metrics")
    cursor = collection.find({"restaurant_id": restaurant_id}).sort(sort_by, -1).limit(limit)
    customers = await cursor.to_list(length=limit)
    
    return [CustomerMetrics(**customer) for customer in customers]

# Menu Analytics Routes
@router.get("/menu/{item_id}/analytics", response_model=MenuAnalytics)
async def get_menu_item_analytics(item_id: str):
    """Get analytics for a specific menu item."""
    collection = await mongodb.get_collection("menu_analytics")
    analytics = await collection.find_one({"item_id": item_id})
    
    if not analytics:
        raise HTTPException(status_code=404, detail="Menu item analytics not found")
    
    return MenuAnalytics(**analytics)

@router.get("/restaurant/{restaurant_id}/menu/top", response_model=List[MenuAnalytics])
async def get_top_menu_items(
    restaurant_id: str,
    limit: int = Query(10, ge=1, le=100),
    sort_by: str = "popularity_score"
):
    """Get top performing menu items for a restaurant."""
    collection = await mongodb.get_collection("menu_analytics")
    cursor = collection.find({"restaurant_id": restaurant_id}).sort(sort_by, -1).limit(limit)
    items = await cursor.to_list(length=limit)
    
    return [MenuAnalytics(**item) for item in items]

# Staff Performance Routes
@router.get("/staff/{staff_id}/performance", response_model=StaffPerformance)
async def get_staff_performance(staff_id: str):
    """Get performance metrics for a staff member."""
    collection = await mongodb.get_collection("staff_performance")
    performance = await collection.find_one({"staff_id": staff_id})
    
    if not performance:
        raise HTTPException(status_code=404, detail="Staff performance not found")
    
    return StaffPerformance(**performance)

@router.get("/restaurant/{restaurant_id}/staff/top", response_model=List[StaffPerformance])
async def get_top_performing_staff(
    restaurant_id: str,
    limit: int = Query(10, ge=1, le=100),
    sort_by: str = "efficiency_score"
):
    """Get top performing staff members for a restaurant."""
    collection = await mongodb.get_collection("staff_performance")
    cursor = collection.find({"restaurant_id": restaurant_id}).sort(sort_by, -1).limit(limit)
    staff = await cursor.to_list(length=limit)
    
    return [StaffPerformance(**member) for member in staff]

# Marketing Analytics Routes
@router.get("/marketing/{campaign_id}/analytics", response_model=MarketingAnalytics)
async def get_campaign_analytics(campaign_id: str):
    """Get analytics for a specific marketing campaign."""
    collection = await mongodb.get_collection("marketing_analytics")
    analytics = await collection.find_one({"campaign_id": campaign_id})
    
    if not analytics:
        raise HTTPException(status_code=404, detail="Campaign analytics not found")
    
    return MarketingAnalytics(**analytics)

@router.get("/restaurant/{restaurant_id}/marketing/campaigns", response_model=List[MarketingAnalytics])
async def get_restaurant_campaigns(
    restaurant_id: str,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
):
    """Get all marketing campaigns for a restaurant."""
    collection = await mongodb.get_collection("marketing_analytics")
    query = {"restaurant_id": restaurant_id}
    
    if start_date and end_date:
        query["created_at"] = {"$gte": start_date, "$lte": end_date}
    
    cursor = collection.find(query).sort("created_at", -1)
    campaigns = await cursor.to_list(length=None)
    
    return [MarketingAnalytics(**campaign) for campaign in campaigns]

# Inventory Analytics Routes
@router.get("/inventory/{item_id}/analytics", response_model=InventoryAnalytics)
async def get_inventory_analytics(item_id: str):
    """Get analytics for a specific inventory item."""
    collection = await mongodb.get_collection("inventory_analytics")
    analytics = await collection.find_one({"item_id": item_id})
    
    if not analytics:
        raise HTTPException(status_code=404, detail="Inventory analytics not found")
    
    return InventoryAnalytics(**analytics)

@router.get("/restaurant/{restaurant_id}/inventory/performance", response_model=List[InventoryAnalytics])
async def get_inventory_performance(
    restaurant_id: str,
    sort_by: str = "cost_efficiency"
):
    """Get performance metrics for all inventory items."""
    collection = await mongodb.get_collection("inventory_analytics")
    cursor = collection.find({"restaurant_id": restaurant_id}).sort(sort_by, -1)
    items = await cursor.to_list(length=None)
    
    return [InventoryAnalytics(**item) for item in items]

# Analytics Report Routes
@router.post("/reports/generate", response_model=AnalyticsReport)
async def generate_analytics_report(
    restaurant_id: str,
    report_type: MetricType,
    start_date: datetime,
    end_date: datetime
):
    """Generate a new analytics report."""
    collection = await mongodb.get_collection("analytics_reports")
    
    # Create report
    report = AnalyticsReport(
        restaurant_id=restaurant_id,
        report_type=report_type,
        start_date=start_date,
        end_date=end_date
    )
    
    # Convert to dict and remove None values
    report_dict = report.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(report_dict)
    report_dict["_id"] = result.inserted_id
    
    return AnalyticsReport(**report_dict)

@router.get("/reports/{report_id}", response_model=AnalyticsReport)
async def get_analytics_report(report_id: str):
    """Get a specific analytics report."""
    if not ObjectId.is_valid(report_id):
        raise HTTPException(status_code=400, detail="Invalid report ID")
    
    collection = await mongodb.get_collection("analytics_reports")
    report = await collection.find_one({"_id": ObjectId(report_id)})
    
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return AnalyticsReport(**report)

@router.get("/restaurant/{restaurant_id}/reports", response_model=List[AnalyticsReport])
async def get_restaurant_reports(
    restaurant_id: str,
    report_type: Optional[MetricType] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
):
    """Get all analytics reports for a restaurant."""
    collection = await mongodb.get_collection("analytics_reports")
    query = {"restaurant_id": restaurant_id}
    
    if report_type:
        query["report_type"] = report_type
    
    if start_date and end_date:
        query["created_at"] = {"$gte": start_date, "$lte": end_date}
    
    cursor = collection.find(query).sort("created_at", -1)
    reports = await cursor.to_list(length=None)
    
    return [AnalyticsReport(**report) for report in reports] 