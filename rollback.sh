#!/bin/bash

# Define variables
INSTALL_DIR="/opt/morpheus"
BACKUP_DIR="$INSTALL_DIR/backup"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory $BACKUP_DIR does not exist. Cannot rollback."
    exit 1
fi

echo "Stopping services before rollback..."
for SERVICE_FILE in "$INSTALL_DIR/services/"*.service; do
    SERVICE_NAME=$(basename "$SERVICE_FILE")
    sudo systemctl stop "$SERVICE_NAME" || { echo "Failed to stop service $SERVICE_NAME"; exit 1; }
done

echo "Rolling back to previous version..."
sudo rsync -a --delete "$BACKUP_DIR/" "$INSTALL_DIR/" || { echo "Failed to restore backup"; exit 1; }

echo "Setting execute permissions on binaries..."
sudo chmod +x "$INSTALL_DIR/"* || { echo "Failed to set execute permissions"; exit 1; }

echo "Restarting services..."
for SERVICE_FILE in "$INSTALL_DIR/services/"*.service; do
    SERVICE_NAME=$(basename "$SERVICE_FILE")
    sudo systemctl start "$SERVICE_NAME" || { echo "Failed to restart service $SERVICE_NAME"; exit 1; }
done

echo "Rollback completed successfully."
