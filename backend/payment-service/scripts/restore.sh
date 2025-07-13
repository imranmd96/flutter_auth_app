#!/bin/bash

# Configuration
BACKUP_DIR="/backups"
MONGODB_URI="mongodb://localhost:27017/payment-service"

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "Please provide backup file name"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Restore backup
mongorestore --uri="$MONGODB_URI" --gzip --archive="$BACKUP_FILE"

echo "Restore completed from: $BACKUP_FILE" 