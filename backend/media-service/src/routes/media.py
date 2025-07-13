from fastapi import APIRouter, HTTPException, Query, Depends, UploadFile, File
from typing import List, Optional
from datetime import datetime
from bson import ObjectId
from ..models.media import (
    Media,
    MediaType,
    MediaStatus,
    MediaUploadResponse,
    MediaProcessingTask,
    MediaUsage
)
from ..database.mongodb import mongodb
from ..services.storage_service import storage_service
from ..services.processing_service import processing_service
from ..config import settings

router = APIRouter()

@router.post("/upload", response_model=MediaUploadResponse)
async def initiate_upload(
    filename: str,
    content_type: str,
    media_type: MediaType,
    owner_id: str,
    owner_type: str,
    is_public: bool = False
):
    """Initiate a media upload and get a pre-signed URL."""
    # Validate file extension
    extension = filename.split(".")[-1].lower()
    if extension not in settings.ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"File extension not allowed. Allowed extensions: {settings.ALLOWED_EXTENSIONS}"
        )
    
    # Generate unique filename
    unique_filename = f"{ObjectId()}_{filename}"
    storage_path = f"{owner_type}/{owner_id}/{unique_filename}"
    
    # Generate upload URL
    upload_data = await storage_service.generate_upload_url(storage_path, content_type)
    
    # Create media record
    media = Media(
        filename=unique_filename,
        original_filename=filename,
        type=media_type,
        metadata={
            "format": extension,
            "size": 0,  # Will be updated after upload
            "mime_type": content_type
        },
        storage_path=storage_path,
        owner_id=owner_id,
        owner_type=owner_type,
        is_public=is_public
    )
    
    collection = await mongodb.get_collection("media")
    result = await collection.insert_one(media.dict(exclude_none=True))
    
    return MediaUploadResponse(
        id=str(result.inserted_id),
        upload_url=upload_data["upload_url"],
        fields=upload_data["fields"]
    )

@router.get("/{media_id}", response_model=Media)
async def get_media(media_id: str):
    """Get media details by ID."""
    collection = await mongodb.get_collection("media")
    media = await collection.find_one({"_id": ObjectId(media_id)})
    
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    
    return Media(**media)

@router.get("/{media_id}/url")
async def get_media_url(media_id: str, expires_in: int = 3600):
    """Get a pre-signed URL for downloading media."""
    collection = await mongodb.get_collection("media")
    media = await collection.find_one({"_id": ObjectId(media_id)})
    
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    
    url = await storage_service.get_download_url(media["storage_path"], expires_in)
    return {"url": url}

@router.delete("/{media_id}")
async def delete_media(media_id: str):
    """Delete media and its associated files."""
    collection = await mongodb.get_collection("media")
    media = await collection.find_one({"_id": ObjectId(media_id)})
    
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    
    # Delete from storage
    await storage_service.delete_file(media["storage_path"])
    
    # Delete from database
    await collection.delete_one({"_id": ObjectId(media_id)})
    
    return {"message": "Media deleted successfully"}

@router.get("/{media_id}/processing", response_model=MediaProcessingTask)
async def get_processing_status(media_id: str):
    """Get the processing status of media."""
    task = await processing_service.get_processing_status(media_id)
    if not task:
        raise HTTPException(status_code=404, detail="Processing task not found")
    return task

@router.post("/{media_id}/process")
async def process_media(media_id: str):
    """Trigger processing for media."""
    collection = await mongodb.get_collection("media")
    media = await collection.find_one({"_id": ObjectId(media_id)})
    
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    
    media_obj = Media(**media)
    await processing_service.process_media(media_obj)
    
    return {"message": "Processing started"}

@router.get("/owner/{owner_id}", response_model=List[Media])
async def get_owner_media(
    owner_id: str,
    owner_type: str,
    media_type: Optional[MediaType] = None,
    skip: int = 0,
    limit: int = 20
):
    """Get all media for an owner."""
    collection = await mongodb.get_collection("media")
    query = {
        "owner_id": owner_id,
        "owner_type": owner_type
    }
    
    if media_type:
        query["type"] = media_type
    
    cursor = collection.find(query).skip(skip).limit(limit)
    media_list = await cursor.to_list(length=limit)
    
    return [Media(**media) for media in media_list]

@router.post("/{media_id}/usage")
async def record_media_usage(
    media_id: str,
    entity_id: str,
    entity_type: str,
    usage_type: str
):
    """Record usage of media by an entity."""
    collection = await mongodb.get_collection("media_usage")
    usage = MediaUsage(
        media_id=media_id,
        entity_id=entity_id,
        entity_type=entity_type,
        usage_type=usage_type
    )
    
    await collection.insert_one(usage.dict(exclude_none=True))
    return {"message": "Usage recorded successfully"} 