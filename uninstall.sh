#!/bin/bash

# Define variables
INSTALL_DIR="/opt/morpheus"
SERVICE_DIR="/etc/systemd/system"

# Stop and disable all Morpheus services
echo "Stopping and disabling Morpheus services..."
for SERVICE_FILE in "$SERVICE_DIR"/morpheus*.service; do
    if [ -f "$SERVICE_FILE" ]; then
        SERVICE_NAME=$(basename "$SERVICE_FILE")
        sudo systemctl stop "$SERVICE_NAME"
        sudo systemctl disable "$SERVICE_NAME"
        sudo rm "$SERVICE_FILE" || { echo "Failed to remove $SERVICE_FILE"; exit 1; }
    fi
done

# Reload systemd to apply changes
sudo systemctl daemon-reload

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing installation directory $INSTALL_DIR..."
    sudo rm -rf "$INSTALL_DIR" || { echo "Failed to remove $INSTALL_DIR"; exit 1; }
else
    echo "$INSTALL_DIR does not exist, skipping."
fi

# Final clean-up
echo "Performing final clean-up..."
sudo rm -rf /tmp/morpheus-setup

echo "Uninstallation completed successfully."
