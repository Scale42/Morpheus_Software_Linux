#!/bin/bash

INSTALL_DIR="/opt/morpheus"
REPO_URL="https://github.com/Scale42/Morpheus_Software_Linux.git"
TMP_DIR="/tmp/morpheus-update"
BACKUP_DIR="$INSTALL_DIR/backup"

if [ ! -d "$INSTALL_DIR" ]; then
echo "Installation directory $INSTALL_DIR does not exist. Please run the installation script first."
exit 1
fi

if [ -d "$TMP_DIR" ]; then
echo "Removing existing temporary directory $TMP_DIR..."
sudo rm -rf "$TMP_DIR" || { echo "Failed to remove temporary directory"; exit 1; }
fi

echo "Cloning repository from $REPO_URL..."
git clone "$REPO_URL" "$TMP_DIR" || { echo "Failed to clone repository"; exit 1; }

if [ -d "$BACKUP_DIR" ]; then
echo "Clearing old backup in $BACKUP_DIR..."
sudo rm -rf "$BACKUP_DIR"/* || { echo "Failed to clear old backup"; exit 1; }
else
echo "Creating backup directory $BACKUP_DIR..."
sudo mkdir -p "$BACKUP_DIR" || { echo "Failed to create backup directory"; exit 1; }
fi

echo "Backing up current binaries from $INSTALL_DIR to $BACKUP_DIR..."
sudo rsync -a --delete "$INSTALL_DIR/" "$BACKUP_DIR/" || { echo "Backup failed"; exit 1; }

SERVICES_RELOADED=false
for SERVICE_FILE in "$TMP_DIR/services/"*.service; do
SERVICE_NAME=$(basename "$SERVICE_FILE")
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
if [ ! -f "$SERVICE_PATH" ]; then
echo "Installing new service: $SERVICE_NAME"
sudo cp "$SERVICE_FILE" "$SERVICE_PATH" || { echo "Failed to copy $SERVICE_NAME"; exit 1; }
SERVICES_RELOADED=true
fi
done

if [ "$SERVICES_RELOADED" = true ]; then
echo "Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
fi

echo "Stopping services..."
for SERVICE_FILE in "$TMP_DIR/services/"*.service; do
SERVICE_NAME=$(basename "$SERVICE_FILE")
if systemctl list-unit-files | grep -q "^$SERVICE_NAME"; then
if systemctl is-active --quiet "$SERVICE_NAME"; then
echo "Stopping $SERVICE_NAME..."
sudo systemctl stop "$SERVICE_NAME" || echo "Warning: Failed to stop $SERVICE_NAME"
else
echo "$SERVICE_NAME is not active — skipping stop"
fi
else
echo "$SERVICE_NAME is not yet registered — skipping stop"
fi
done

echo "Updating binaries..."
sudo cp "$TMP_DIR/binaries/"* "$INSTALL_DIR/" || { echo "Failed to copy binaries"; exit 1; }
sudo chmod +x "$INSTALL_DIR/"* || { echo "Failed to set executable permissions"; exit 1; }

echo "Starting services..."
for SERVICE_FILE in "$TMP_DIR/services/"*.service; do
SERVICE_NAME=$(basename "$SERVICE_FILE")
echo "Starting $SERVICE_NAME..."
sudo systemctl enable "$SERVICE_NAME" >/dev/null 2>&1 || echo "Warning: Could not enable $SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME" || echo "Warning: Failed to restart $SERVICE_NAME"
done

echo "Cleaning up temporary files..."
sudo rm -rf "$TMP_DIR"

echo "Update completed successfully."
