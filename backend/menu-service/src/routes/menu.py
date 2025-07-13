from fastapi import APIRouter, HTTPException, Query, Depends, UploadFile, File
from typing import List, Optional
from datetime import datetime
from bson import ObjectId
from ..models.menu import (
    Menu,
    MenuItem,
    MenuCategory,
    MenuVersion,
    CategoryType,
    ItemStatus
)
from ..database.mongodb import mongodb
from ..config import settings

router = APIRouter()

# Menu Routes
@router.post("/menus/", response_model=Menu)
async def create_menu(menu: Menu):
    """Create a new menu."""
    collection = await mongodb.get_collection("menus")
    
    # Add timestamps
    menu.created_at = datetime.utcnow()
    menu.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    menu_dict = menu.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(menu_dict)
    menu_dict["_id"] = result.inserted_id
    
    return Menu(**menu_dict)

@router.get("/menus/{menu_id}", response_model=Menu)
async def get_menu(menu_id: str):
    """Get a specific menu by ID."""
    if not ObjectId.is_valid(menu_id):
        raise HTTPException(status_code=400, detail="Invalid menu ID")
    
    collection = await mongodb.get_collection("menus")
    menu = await collection.find_one({"_id": ObjectId(menu_id)})
    
    if not menu:
        raise HTTPException(status_code=404, detail="Menu not found")
    
    return Menu(**menu)

@router.get("/menus/restaurant/{restaurant_id}", response_model=List[Menu])
async def get_restaurant_menus(restaurant_id: str):
    """Get all menus for a restaurant."""
    collection = await mongodb.get_collection("menus")
    cursor = collection.find({"restaurant_id": restaurant_id})
    menus = await cursor.to_list(length=None)
    
    return [Menu(**menu) for menu in menus]

@router.put("/menus/{menu_id}", response_model=Menu)
async def update_menu(menu_id: str, menu: Menu):
    """Update a menu."""
    if not ObjectId.is_valid(menu_id):
        raise HTTPException(status_code=400, detail="Invalid menu ID")
    
    collection = await mongodb.get_collection("menus")
    
    # Update timestamps
    menu.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    menu_dict = menu.dict(exclude_none=True)
    
    # Update in database
    result = await collection.update_one(
        {"_id": ObjectId(menu_id)},
        {"$set": menu_dict}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Menu not found")
    
    return menu

@router.delete("/menus/{menu_id}")
async def delete_menu(menu_id: str):
    """Delete a menu."""
    if not ObjectId.is_valid(menu_id):
        raise HTTPException(status_code=400, detail="Invalid menu ID")
    
    collection = await mongodb.get_collection("menus")
    result = await collection.delete_one({"_id": ObjectId(menu_id)})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Menu not found")
    
    return {"message": "Menu deleted"}

# Menu Item Routes
@router.post("/items/", response_model=MenuItem)
async def create_menu_item(item: MenuItem):
    """Create a new menu item."""
    collection = await mongodb.get_collection("menu_items")
    
    # Add timestamps
    item.created_at = datetime.utcnow()
    item.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    item_dict = item.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(item_dict)
    item_dict["_id"] = result.inserted_id
    
    return MenuItem(**item_dict)

@router.get("/items/{item_id}", response_model=MenuItem)
async def get_menu_item(item_id: str):
    """Get a specific menu item by ID."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("menu_items")
    item = await collection.find_one({"_id": ObjectId(item_id)})
    
    if not item:
        raise HTTPException(status_code=404, detail="Menu item not found")
    
    return MenuItem(**item)

@router.get("/items/restaurant/{restaurant_id}", response_model=List[MenuItem])
async def get_restaurant_items(
    restaurant_id: str,
    category: Optional[CategoryType] = None,
    status: Optional[ItemStatus] = None
):
    """Get all menu items for a restaurant with optional filters."""
    collection = await mongodb.get_collection("menu_items")
    
    # Build query
    query = {"restaurant_id": restaurant_id}
    if category:
        query["category"] = category
    if status:
        query["status"] = status
    
    cursor = collection.find(query)
    items = await cursor.to_list(length=None)
    
    return [MenuItem(**item) for item in items]

@router.put("/items/{item_id}", response_model=MenuItem)
async def update_menu_item(item_id: str, item: MenuItem):
    """Update a menu item."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("menu_items")
    
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
        raise HTTPException(status_code=404, detail="Menu item not found")
    
    return item

@router.delete("/items/{item_id}")
async def delete_menu_item(item_id: str):
    """Delete a menu item."""
    if not ObjectId.is_valid(item_id):
        raise HTTPException(status_code=400, detail="Invalid item ID")
    
    collection = await mongodb.get_collection("menu_items")
    result = await collection.delete_one({"_id": ObjectId(item_id)})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Menu item not found")
    
    return {"message": "Menu item deleted"}

# Menu Category Routes
@router.post("/categories/", response_model=MenuCategory)
async def create_menu_category(category: MenuCategory):
    """Create a new menu category."""
    collection = await mongodb.get_collection("menu_categories")
    
    # Add timestamps
    category.created_at = datetime.utcnow()
    category.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    category_dict = category.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(category_dict)
    category_dict["_id"] = result.inserted_id
    
    return MenuCategory(**category_dict)

@router.get("/categories/{category_id}", response_model=MenuCategory)
async def get_menu_category(category_id: str):
    """Get a specific menu category by ID."""
    if not ObjectId.is_valid(category_id):
        raise HTTPException(status_code=400, detail="Invalid category ID")
    
    collection = await mongodb.get_collection("menu_categories")
    category = await collection.find_one({"_id": ObjectId(category_id)})
    
    if not category:
        raise HTTPException(status_code=404, detail="Menu category not found")
    
    return MenuCategory(**category)

@router.get("/categories/restaurant/{restaurant_id}", response_model=List[MenuCategory])
async def get_restaurant_categories(restaurant_id: str):
    """Get all menu categories for a restaurant."""
    collection = await mongodb.get_collection("menu_categories")
    cursor = collection.find({"restaurant_id": restaurant_id}).sort("display_order", 1)
    categories = await cursor.to_list(length=None)
    
    return [MenuCategory(**category) for category in categories]

@router.put("/categories/{category_id}", response_model=MenuCategory)
async def update_menu_category(category_id: str, category: MenuCategory):
    """Update a menu category."""
    if not ObjectId.is_valid(category_id):
        raise HTTPException(status_code=400, detail="Invalid category ID")
    
    collection = await mongodb.get_collection("menu_categories")
    
    # Update timestamps
    category.updated_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    category_dict = category.dict(exclude_none=True)
    
    # Update in database
    result = await collection.update_one(
        {"_id": ObjectId(category_id)},
        {"$set": category_dict}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Menu category not found")
    
    return category

@router.delete("/categories/{category_id}")
async def delete_menu_category(category_id: str):
    """Delete a menu category."""
    if not ObjectId.is_valid(category_id):
        raise HTTPException(status_code=400, detail="Invalid category ID")
    
    collection = await mongodb.get_collection("menu_categories")
    result = await collection.delete_one({"_id": ObjectId(category_id)})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Menu category not found")
    
    return {"message": "Menu category deleted"}

# Menu Version Routes
@router.post("/versions/", response_model=MenuVersion)
async def create_menu_version(version: MenuVersion):
    """Create a new menu version."""
    collection = await mongodb.get_collection("menu_versions")
    
    # Add timestamp
    version.created_at = datetime.utcnow()
    
    # Convert to dict and remove None values
    version_dict = version.dict(exclude_none=True)
    
    # Insert into database
    result = await collection.insert_one(version_dict)
    version_dict["_id"] = result.inserted_id
    
    return MenuVersion(**version_dict)

@router.get("/versions/menu/{menu_id}", response_model=List[MenuVersion])
async def get_menu_versions(menu_id: str):
    """Get all versions of a menu."""
    collection = await mongodb.get_collection("menu_versions")
    cursor = collection.find({"menu_id": menu_id}).sort("version_number", -1)
    versions = await cursor.to_list(length=None)
    
    return [MenuVersion(**version) for version in versions] 