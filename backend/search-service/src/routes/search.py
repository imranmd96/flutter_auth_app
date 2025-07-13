from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional, Dict, Any
from datetime import datetime
from bson import ObjectId
from ..models.search import (
    SearchQuery,
    SearchResponse,
    SearchResult,
    SearchType,
    SearchHistory,
    SearchSuggestion,
    SearchFacet
)
from ..database.mongodb import mongodb
from ..config import settings

router = APIRouter()

@router.post("/search", response_model=SearchResponse)
async def search(query: SearchQuery):
    """Perform a search across all indexed content."""
    # Get collections
    index_collection = await mongodb.get_collection("search_index")
    history_collection = await mongodb.get_collection("search_history")
    
    # Build search query
    search_query = {
        "type": query.search_type,
        "$text": {"$search": query.query}
    }
    
    # Add filters
    for filter in query.filters:
        search_query[filter.field] = {
            f"${filter.operator}": filter.value
        }
    
    # Execute search
    cursor = index_collection.find(search_query)
    
    # Apply sorting
    if query.sort:
        cursor = cursor.sort(query.sort.field, 1 if query.sort.direction == "asc" else -1)
    
    # Get total count
    total = await cursor.count()
    
    # Apply pagination
    skip = (query.page - 1) * query.page_size
    cursor = cursor.skip(skip).limit(query.page_size)
    
    # Get results
    results = await cursor.to_list(length=query.page_size)
    
    # Convert to SearchResult objects
    search_results = [
        SearchResult(
            id=str(result["document_id"]),
            type=result["type"],
            score=result.get("score", 0.0),
            data=result["content"]
        )
        for result in results
    ]
    
    # Record search history
    history = SearchHistory(
        query=query.query,
        search_type=query.search_type,
        filters=query.filters,
        results_count=total
    )
    await history_collection.insert_one(history.dict(exclude_none=True))
    
    # Update search suggestions
    suggestions_collection = await mongodb.get_collection("search_suggestions")
    await suggestions_collection.update_one(
        {
            "type": query.search_type,
            "term": query.query.lower()
        },
        {
            "$inc": {"frequency": 1},
            "$set": {"last_used": datetime.utcnow()}
        },
        upsert=True
    )
    
    return SearchResponse(
        total=total,
        page=query.page,
        page_size=query.page_size,
        results=search_results
    )

@router.get("/suggestions", response_model=List[str])
async def get_search_suggestions(
    query: str,
    search_type: SearchType,
    limit: int = Query(10, ge=1, le=50)
):
    """Get search suggestions based on partial query."""
    collection = await mongodb.get_collection("search_suggestions")
    
    # Find suggestions that start with the query
    cursor = collection.find({
        "type": search_type,
        "term": {"$regex": f"^{query.lower()}", "$options": "i"}
    }).sort("frequency", -1).limit(limit)
    
    suggestions = await cursor.to_list(length=limit)
    return [suggestion["term"] for suggestion in suggestions]

@router.get("/history", response_model=List[SearchHistory])
async def get_search_history(
    user_id: str,
    limit: int = Query(10, ge=1, le=100)
):
    """Get search history for a user."""
    collection = await mongodb.get_collection("search_history")
    cursor = collection.find({"user_id": user_id}).sort("created_at", -1).limit(limit)
    history = await cursor.to_list(length=limit)
    
    return [SearchHistory(**item) for item in history]

@router.get("/facets", response_model=Dict[str, Dict[str, int]])
async def get_search_facets(
    search_type: SearchType,
    field: str
):
    """Get facet counts for a specific field."""
    collection = await mongodb.get_collection("search_facets")
    facet = await collection.find_one({
        "type": search_type,
        "field": field
    })
    
    if not facet:
        return {}
    
    return facet["values"]

@router.post("/index", response_model=Dict[str, Any])
async def index_document(
    document_id: str,
    search_type: SearchType,
    content: Dict[str, Any]
):
    """Index a new document for searching."""
    collection = await mongodb.get_collection("search_index")
    
    # Create index document
    index_doc = {
        "document_id": document_id,
        "type": search_type,
        "content": content,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    # Insert or update
    result = await collection.update_one(
        {
            "document_id": document_id,
            "type": search_type
        },
        {"$set": index_doc},
        upsert=True
    )
    
    # Update facets
    await update_facets(search_type, content)
    
    return {
        "message": "Document indexed successfully",
        "document_id": document_id
    }

@router.delete("/index/{document_id}")
async def remove_from_index(
    document_id: str,
    search_type: SearchType
):
    """Remove a document from the search index."""
    collection = await mongodb.get_collection("search_index")
    result = await collection.delete_one({
        "document_id": document_id,
        "type": search_type
    })
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Document not found in index")
    
    return {"message": "Document removed from index"}

async def update_facets(search_type: SearchType, content: Dict[str, Any]):
    """Update facet counts for a document's content."""
    collection = await mongodb.get_collection("search_facets")
    
    # Update facets for each field in the content
    for field, value in content.items():
        if isinstance(value, (str, int, float, bool)):
            await collection.update_one(
                {
                    "type": search_type,
                    "field": field
                },
                {
                    "$inc": {f"values.{str(value)}": 1}
                },
                upsert=True
            ) 