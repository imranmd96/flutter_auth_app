import boto3
import os
from botocore.config import Config
from botocore.exceptions import ClientError
from typing import Optional, Dict, Any
from ..config import settings

class StorageService:
    def __init__(self):
        self.s3_client = None
        if settings.STORAGE_TYPE == "s3":
            self._init_s3_client()

    def _init_s3_client(self):
        config = Config(
            region_name=settings.STORAGE_REGION,
            retries=dict(max_attempts=3)
        )
        
        self.s3_client = boto3.client(
            's3',
            endpoint_url=settings.STORAGE_ENDPOINT,
            aws_access_key_id=settings.STORAGE_ACCESS_KEY,
            aws_secret_access_key=settings.STORAGE_SECRET_KEY,
            config=config
        )

    async def generate_upload_url(self, key: str, content_type: str) -> Dict[str, Any]:
        """Generate a pre-signed URL for direct upload to storage."""
        if settings.STORAGE_TYPE == "s3":
            try:
                response = self.s3_client.generate_presigned_post(
                    settings.STORAGE_BUCKET,
                    key,
                    Fields={
                        'Content-Type': content_type
                    },
                    Conditions=[
                        {'Content-Type': content_type},
                        ['content-length-range', 0, settings.MAX_FILE_SIZE]
                    ],
                    ExpiresIn=settings.UPLOAD_EXPIRY
                )
                return {
                    "upload_url": response["url"],
                    "fields": response["fields"]
                }
            except ClientError as e:
                raise Exception(f"Failed to generate upload URL: {str(e)}")
        else:
            raise NotImplementedError("Local storage upload not implemented")

    async def get_download_url(self, key: str, expires_in: int = 3600) -> str:
        """Generate a pre-signed URL for downloading a file."""
        if settings.STORAGE_TYPE == "s3":
            try:
                url = self.s3_client.generate_presigned_url(
                    'get_object',
                    Params={
                        'Bucket': settings.STORAGE_BUCKET,
                        'Key': key
                    },
                    ExpiresIn=expires_in
                )
                return url
            except ClientError as e:
                raise Exception(f"Failed to generate download URL: {str(e)}")
        else:
            raise NotImplementedError("Local storage download not implemented")

    async def delete_file(self, key: str) -> bool:
        """Delete a file from storage."""
        if settings.STORAGE_TYPE == "s3":
            try:
                self.s3_client.delete_object(
                    Bucket=settings.STORAGE_BUCKET,
                    Key=key
                )
                return True
            except ClientError as e:
                raise Exception(f"Failed to delete file: {str(e)}")
        else:
            raise NotImplementedError("Local storage delete not implemented")

    async def get_file_metadata(self, key: str) -> Optional[Dict[str, Any]]:
        """Get metadata for a file."""
        if settings.STORAGE_TYPE == "s3":
            try:
                response = self.s3_client.head_object(
                    Bucket=settings.STORAGE_BUCKET,
                    Key=key
                )
                return {
                    "content_type": response.get("ContentType"),
                    "content_length": response.get("ContentLength"),
                    "last_modified": response.get("LastModified"),
                    "etag": response.get("ETag")
                }
            except ClientError as e:
                if e.response["Error"]["Code"] == "404":
                    return None
                raise Exception(f"Failed to get file metadata: {str(e)}")
        else:
            raise NotImplementedError("Local storage metadata not implemented")

storage_service = StorageService() 