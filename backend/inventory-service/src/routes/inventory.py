from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional
from datetime import datetime
from bson import ObjectId
from ..models.inventory import (
    Supplier,
    InventoryItem,
    StockMovement,
    ReorderPoint,
    LowStockAlert,
    MovementType,
    UnitType
)
from ..database.mongodb import mongodb
from ..config import settings

router = APIRouter()

# Supplier Routes
@router.post("/suppliers/", response_model=Supplier)
async def create_supplier(supplier: Supplier):
    """Create a new supplier."""
    collection = await mongodb.get_collection("suppliers")
    
    # Add timestamps
    supplier.created_at = datetime.utcnow()
    supplier.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    supplier_dict = supplier.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(supplier_dict)
    supplier_dict["_id"] = result.inserted_id
    
    return Supplier(**supplier_dict)

@router.get("/suppliers/{supplier_id}", response_model=Supplier)
async def get_supplier(supplier_id: str):
    """Get a specific supplier by ID."""
    if not ObjectId.is_valid(supplier_id):
        raise HTTPException(status_code=400, detail="Invalid supplier ID")
    
    collection = await mongodb.get_collection("suppliers")
    supplier = await collection.find_one({"_id": ObjectId(supplier_id)})
    
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    
    return Supplier(**supplier)

@router.get("/suppliers/restaurant/{restaurant_id}", response_model=List[Supplier])
async def get_restaurant_suppliers(restaurant_id: str):
    """Get all suppliers for a restaurant."""
    collection = await mongodb.get_collection("suppliers")
    cursor = collection.find({"restaurant_id": restaurant_id})
    suppliers = await cursor.to_list(length=None)
    
    return [Supplier(**supplier) for supplier in suppliers]

# Inventory Item Routes
@router.post("/items/", response_model=InventoryItem)
async def create_inventory_item(item: InventoryItem):
    """Create a new inventory item."""
    collection = await mongodb.get_collection("inventory_items")
    
    # Add timestamps
    item.created_at = datetime.utcnow()
    item.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    item_dict = item.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(item_dict)
    item_dict["_id"] = result.inserted_id
    
    return InventoryItem(**item_dict)

@router.get("/items/{item_id}", response_model=InventoryItem)
async def get_inventory_item(item_id: str):
    """Get a specific inventory item by ID."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("inventory_items")
    item = await collection.find_one({"_id": ObjectId(item_id)})
    
    if not item:
        raise HTTPException(status_code=404, detail="Inventory item not found")
    
    return InventoryItem(**item)

@router.get("/items/restaurant/{restaurant_id}", response_model=List[InventoryItem])
async def get_restaurant_items(restaurant_id: str):
    """Get all inventory items for a restaurant."""
    collection = await mongodb.get_collection("inventory_items")
    cursor = collection.find({"restaurant_id": restaurant_id})
    items = await cursor.to_list(length=None)
    
    return [InventoryItem(**item) for item in items]

@router.put("/items/{item_id}", response_model=InventoryItem)
async def update_inventory_item(item_id: str, item: InventoryItem):
    """Update an inventory item."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("inventory_items")
    
    # Update timestamps
    item.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    item_dict = item.dict(exclude_none=True)
    
    # Update in database
    result = await collection.update_one(
        {"_id": ObjectId(item_id)},
        {"$set": item_dict}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Inventory item not found")
    
    return item

# Stock Movement Routes
@router.post("/movements/", response_model=StockMovement)
async def create_stock_movement(movement: StockMovement):
    """Create a new stock movement and update inventory quantities."""
    # Get collections
    movements_collection = await mongodb.get_collection("stock_movements")
    items_collection = await mongodb.get_collection("inventory_items")
    
    # Get the inventory item
    item = await items_collection.find_one({"_id": ObjectId(movement.item_id)})
    if not item:
        raise HTTPException(status_code=404, detail="Inventory item not found")
    
    # Calculate new quantity based on movement type
    current_quantity = item["current_quantity"]
    if movement.movement_type in [MovementType.PURCHASE, MovementType.RETURN]:
        new_quantity = current_quantity + movement.quantity
    elif movement.movement_type in [MovementType.SALE, MovementType.WASTE]:
        if current_quantity < movement.quantity:
            raise HTTPException(status_code=400, detail="Insufficient stock")
        new_quantity = current_quantity - movement.quantity
    else:  # ADJUSTMENT, TRANSFER
        new_quantity = movement.quantity
    
    # Create movement record
    movement_dict = movement.dict(exclude_none=True)
    result = await movements_collection.insert_one(movement_dict)
    movement_dict["_id"] = result.inserted_id
    
    # Update inventory quantity
    await items_collection.update_one(
        {"_id": ObjectId(movement.item_id)},
        {"$set": {"current_quantity": new_quantity, "updated_at": datetime.utcnow()}}
    )
    
    # Check for low stock alert
    if new_quantity <= item["reorder_point"]:
        alerts_collection = await mongodb.get_collection("low_stock_alerts")
        alert = LowStockAlert(
            restaurant_id=item["restaurant_id"],
            item_id=movement.item_id,
            current_quantity=new_quantity,
            minimum_quantity=item["minimum_quantity"]
        )
        await alerts_collection.insert_one(alert.dict(exclude_none=True))
    
    return StockMovement(**movement_dict)

@router.get("/movements/item/{item_id}", response_model=List[StockMovement])
async def get_item_movements(
    item_id: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100)
):
    """Get stock movements for a specific item with pagination."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("stock_movements")
    cursor = collection.find({"item_id": item_id}).sort("created_at", -1).skip(skip).limit(limit)
    movements = await cursor.to_list(length=limit)
    
    return [StockMovement(**movement) for movement in movements]

# Reorder Point Routes
@router.post("/reorder-points/", response_model=ReorderPoint)
async def create_reorder_point(reorder_point: ReorderPoint):
    """Create a new reorder point."""
    collection = await mongodb.get_collection("reorder_points")
    
    # Add timestamps
    reorder_point.created_at = datetime.utcnow()
    reorder_point.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    reorder_point_dict = reorder_point.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(reorder_point_dict)
    reorder_point_dict["_id"] = result.inserted_id
    
    return ReorderPoint(**reorder_point_dict)

@router.get("/reorder-points/item/{item_id}", response_model=ReorderPoint)
async def get_item_reorder_point(item_id: str):
    """Get reorder point for a specific item."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("reorder_points")
    reorder_point = await collection.find_one({"item_id": item_id})
    
    if not reorder_point:
        raise HTTPException(status_code=404, detail="Reorder point not found")
    
    return ReorderPoint(**reorder_point)

# Low Stock Alert Routes
@router.get("/alerts/low-stock/", response_model=List[LowStockAlert])
async def get_low_stock_alerts(
    restaurant_id: str,
    resolved: bool = False
):
    """Get low stock alerts for a restaurant."""
    collection = await mongodb.get_collection("low_stock_alerts")
    cursor = collection.find({
        "restaurant_id": restaurant_id,
        "is_resolved": resolved
    }).sort("alert_date", -1)
    alerts = await cursor.to_list(length=None)
    
    return [LowStockAlert(**alert) for alert in alerts]

@router.put("/alerts/{alert_id}/resolve")
async def resolve_low_stock_alert(
    alert_id: str,
    resolved_by: str,
    notes: Optional[str] = None
):
    """Mark a low stock alert as resolved."""
    if not ObjectId.is_valid(alert_id):
        raise HTTPException(status_code=400, detail="Invalid alert ID")
    
    collection = await mongodb.get_collection("low_stock_alerts")
    result = await collection.update_one(
        {"_id": ObjectId(alert_id)},
        {
            "$set": {
                "is_resolved": True,
                "resolved_at": datetime.utcnow(),
                "resolved_by": resolved_by,
                "notes": notes
            }
        }
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Alert not found")
    
    return {"message": "Alert resolved successfully"} 