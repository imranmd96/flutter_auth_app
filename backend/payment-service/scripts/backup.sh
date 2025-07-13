#!/bin/bash

# Configuration
BACKUP_DIR="/backups"
MONGODB_URI="mongodb://localhost:27017/payment-service"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/payment-service_$DATE.gz"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create backup
mongodump --uri="$MONGODB_URI" --gzip --archive="$BACKUP_FILE"

# Remove old backups
find $BACKUP_DIR -name "payment-service_*.gz" -mtime +$RETENTION_DAYS -delete

# Upload to S3 (if configured)
if [ ! -z "$AWS_BACKUP_BUCKET" ]; then
    aws s3 cp "$BACKUP_FILE" "s3://$AWS_BACKUP_BUCKET/backups/"
fi

echo "Backup completed: $BACKUP_FILE" 