#!/bin/bash

# Define variables
INSTALL_DIR="/opt/morpheus"
SERVICE_DIR="/etc/systemd/system"
REPO_URL="https://github.com/Scale42/Morpheus_Software_Linux.git"

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <api_key> <client_id>"
    exit 1
fi

API_KEY="$1"
CLIENT_ID="$2"

# Check if the directory exists and remove it
if [ -d "/tmp/morpheus-setup" ]; then
    echo "Removing existing directory /tmp/morpheus-setup..."
    sudo rm -rf /tmp/morpheus-setup || { echo "Failed to remove existing directory"; exit 1; }
fi

# Clone the repository
echo "Cloning repository..."
git clone "$REPO_URL" /tmp/morpheus-setup || { echo "Failed to clone repository"; exit 1; }

# Create installation directory
echo "Creating installation directory at $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR" || { echo "Failed to create installation directory"; exit 1; }

# Copy binaries
echo "Copying binaries..."
sudo cp /tmp/morpheus-setup/binaries/* "$INSTALL_DIR/" || { echo "Failed to copy binaries"; exit 1; }
sudo chmod +x "$INSTALL_DIR"/*

# Copy configuration files
echo "Copying configuration files..."
sudo cp /tmp/morpheus-setup/config/config.txt "$INSTALL_DIR/" || { echo "Failed to copy config.txt"; exit 1; }
sudo cp /tmp/morpheus-setup/config/morpheus.db "$INSTALL_DIR/" || { echo "Failed to copy morpheus.db"; exit 1; }
sudo chown sabre56:sabre56 "$INSTALL_DIR/morpheus.db"
sudo chmod 664 "$INSTALL_DIR/morpheus.db"

# Check if sqlite3 is installed
if ! command -v sqlite3 &>/dev/null; then
    echo "sqlite3 is not installed. Installing..."
    sudo apt update
    sudo apt install -y sqlite3 || { echo "Failed to install sqlite3"; exit 1; }
fi

# Update morpheus.db with provided API key and client ID
echo "Updating morpheus.db with credentials..."
DB_FILE="$INSTALL_DIR/morpheus.db"
SQL_UPDATE="UPDATE creds SET api_key='$API_KEY',client_id='$CLIENT_ID';"
echo "$SQL_UPDATE" | sqlite3 "$DB_FILE" || { echo "Failed to update morpheus.db"; exit 1; }

# Update service files and copy to systemd directory
echo "Configuring and installing service files..."
for SERVICE_FILE in /tmp/morpheus-setup/services/*.service; do
    SERVICE_NAME=$(basename "$SERVICE_FILE")
    sudo sed "s|<INSTALL_DIR>|$INSTALL_DIR|g" "$SERVICE_FILE" > "$SERVICE_DIR/$SERVICE_NAME" || { echo "Failed to configure $SERVICE_NAME"; exit 1; }
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
done

# Start the services
echo "Starting services..."
for SERVICE_FILE in /tmp/morpheus-setup/services/*.service; do
    SERVICE_NAME=$(basename "$SERVICE_FILE")
    sudo systemctl start "$SERVICE_NAME" || { echo "Failed to start $SERVICE_NAME"; exit 1; }
done

# Clean up
echo "Cleaning up..."
sudo rm -rf /tmp/morpheus-setup

echo "Installation completed successfully."
