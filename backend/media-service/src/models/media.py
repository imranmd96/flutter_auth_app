from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from bson import ObjectId
from enum import Enum

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")

class MediaType(str, Enum):
    IMAGE = "image"
    VIDEO = "video"
    AUDIO = "audio"
    DOCUMENT = "document"

class MediaFormat(str, Enum):
    # Image formats
    JPEG = "jpeg"
    PNG = "png"
    GIF = "gif"
    WEBP = "webp"
    # Video formats
    MP4 = "mp4"
    WEBM = "webm"
    # Audio formats
    MP3 = "mp3"
    WAV = "wav"
    # Document formats
    PDF = "pdf"
    DOC = "doc"
    DOCX = "docx"

class MediaStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    READY = "ready"
    FAILED = "failed"

class MediaMetadata(BaseModel):
    width: Optional[int] = None
    height: Optional[int] = None
    duration: Optional[float] = None
    format: MediaFormat
    size: int  # Size in bytes
    mime_type: str
    encoding: Optional[str] = None
    bitrate: Optional[int] = None
    fps: Optional[float] = None
    channels: Optional[int] = None
    sample_rate: Optional[int] = None

class Media(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    filename: str
    original_filename: str
    type: MediaType
    metadata: MediaMetadata
    status: MediaStatus = MediaStatus.PENDING
    url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    storage_path: str
    owner_id: str
    owner_type: str
    tags: List[str] = Field(default_factory=list)
    is_public: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class MediaUploadResponse(BaseModel):
    id: str
    upload_url: str
    fields: Dict[str, str]

class MediaProcessingTask(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    media_id: str
    type: str
    status: str
    progress: float = 0.0
    error: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class MediaUsage(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    media_id: str
    entity_id: str
    entity_type: str
    usage_type: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True 