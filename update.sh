#!/bin/bash

# Define variables
INSTALL_DIR="/opt/morpheus"
REPO_URL="https://github.com/Scale42/Morpheus_Software_Linux.git"
TMP_DIR="/tmp/morpheus-update"

# Check if INSTALL_DIR exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Installation directory $INSTALL_DIR does not exist. Please run the installation script first."
    exit 1
fi

# Create temporary directory for the update
if [ -d "$TMP_DIR" ]; then
    echo "Removing existing temporary directory $TMP_DIR..."
    sudo rm -rf "$TMP_DIR" || { echo "Failed to remove existing temporary directory"; exit 1; }
fi

echo "Cloning repository to $TMP_DIR..."
git clone "$REPO_URL" "$TMP_DIR" || { echo "Failed to clone repository"; exit 1; }

# Backup existing binaries
BACKUP_DIR="$INSTALL_DIR/backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup directory $BACKUP_DIR..."
sudo mkdir -p "$BACKUP_DIR" || { echo "Failed to create backup directory"; exit 1; }
sudo cp "$INSTALL_DIR"/* "$BACKUP_DIR/" || { echo "Failed to backup binaries"; exit 1; }

# Update binaries
echo "Updating binaries in $INSTALL_DIR..."
sudo cp "$TMP_DIR/binaries/"* "$INSTALL_DIR/" || { echo "Failed to update binaries"; exit 1; }
sudo chmod +x "$INSTALL_DIR/"* || { echo "Failed to set execute permissions on binaries"; exit 1; }

# Restart services
echo "Restarting services..."
for SERVICE_FILE in "$INSTALL_DIR"/services/*.service; do
    SERVICE_NAME=$(basename "$SERVICE_FILE")
    sudo systemctl restart "$SERVICE_NAME" || { echo "Failed to restart $SERVICE_NAME"; exit 1; }
done

# Clean up
echo "Cleaning up temporary files..."
sudo rm -rf "$TMP_DIR"

echo "Update completed successfully."
