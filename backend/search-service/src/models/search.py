from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
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

class SearchType(str, Enum):
    RESTAURANT = "restaurant"
    MENU_ITEM = "menu_item"
    CATEGORY = "category"
    CUSTOMER = "customer"
    ORDER = "order"

class SearchFilter(BaseModel):
    field: str
    operator: str
    value: Any

class SearchSort(BaseModel):
    field: str
    direction: str = "asc"

class SearchQuery(BaseModel):
    query: str
    search_type: SearchType
    filters: List[SearchFilter] = Field(default_factory=list)
    sort: Optional[SearchSort] = None
    page: int = 1
    page_size: int = 10

class SearchResult(BaseModel):
    id: str
    type: SearchType
    score: float
    data: Dict[str, Any]
    highlights: Optional[Dict[str, List[str]]] = None

class SearchResponse(BaseModel):
    total: int
    page: int
    page_size: int
    results: List[SearchResult]
    facets: Optional[Dict[str, Dict[str, int]]] = None

class SearchIndex(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    type: SearchType
    document_id: str
    content: Dict[str, Any]
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class SearchHistory(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    user_id: str
    query: str
    search_type: SearchType
    filters: List[SearchFilter] = Field(default_factory=list)
    results_count: int
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class SearchSuggestion(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    type: SearchType
    term: str
    frequency: int = 1
    last_used: datetime = Field(default_factory=datetime.utcnow)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True

class SearchFacet(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    type: SearchType
    field: str
    values: Dict[str, int] = Field(default_factory=dict)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {ObjectId: str}
        populate_by_name = True 