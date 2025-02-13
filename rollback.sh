#!/bin/bash

# Define variables
INSTALL_DIR="/opt/morpheus"
BACKUP_DIR="$INSTALL_DIR/backup"

# List of services
SERVICES=("netscanner.service" "datacollector.service" "healthchecker.service" "remoteexecutor.service")

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory $BACKUP_DIR does not exist. Cannot rollback."
    exit 1
fi

echo "Stopping services before rollback..."
for SERVICE in "${SERVICES[@]}"; do
    sudo systemctl stop "$SERVICE" || echo "Warning: Failed to stop $SERVICE"
done

echo "Rolling back to previous version..."
sudo rsync -a --delete "$BACKUP_DIR/" "$INSTALL_DIR/" || { echo "Failed to restore backup"; exit 1; }

echo "Setting execute permissions on binaries..."
sudo chmod +x "$INSTALL_DIR/"* || { echo "Failed to set execute permissions"; exit 1; }

echo "Restarting services..."
for SERVICE in "${SERVICES[@]}"; do
    sudo systemctl start "$SERVICE" || echo "Warning: Failed to restart $SERVICE"
done

echo "Rollback completed successfully."
