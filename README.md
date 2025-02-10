# Morpheus Software Installation, Update & Rollback System

## Overview
This repository provides scripts to install, update, and rollback the Morpheus software on a Linux system. The update process ensures that only one backup version is kept, and rollback functionality allows restoring the previous version if issues occur.

## Scripts
- **`install.sh`** - Installs the software for the first time, setting up binaries, configuration files, and services.
- **`update.sh`** - Updates the software with the latest binaries from the GitHub repository, while maintaining a single backup.
- **`rollback.sh`** - Restores the previous version from backup if the new update has issues.

## Installation
To install Morpheus software for the first time, run the installation script with the required API key and client ID:

```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/refs/heads/main/install.sh | bash -s <api_key> <client_id>
```

This script will:
- Clone the repository.
- Install necessary dependencies (e.g., `git`, `sqlite3`).
- Copy binaries and configuration files to `/opt/morpheus/`.
- Configure and start system services.
- Store API credentials in `morpheus.db`.

Once installed, you can use the update and rollback scripts to manage software versions.

---

## Case Study: Installation, Update & Rollback Process

### **Step 1: Running `install.sh`**
1. Installs **Version A** of the software in `/opt/morpheus/`.
2. Configures system services and starts them.
3. Stores API credentials in `morpheus.db`.

### **Step 2: Running `update.sh`**
1. **Backs up** Version A to `/opt/morpheus/backup/`.
2. **Downloads the latest version (Version B)** from the repository.
3. **Stops services**, replaces Version A with Version B, and **restarts services**.
4. The system is now running **Version B**.

```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/main/update.sh | bash
```

### **Step 3: Issue Detected in Version B**
- If the new update (Version B) has issues, the rollback process is initiated.

### **Step 4: Running `rollback.sh`**
1. **Stops services** before rollback.
2. **Restores Version A** from `/opt/morpheus/backup/`.
3. **Removes Version B completely**.
4. **Restarts services** running Version A.
5. The system is now back to **Version A**.

```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/main/rollback.sh | bash
```

### **Step 5: Running `update.sh` Again**
1. The script **removes the previous backup (which contained Version A)** and creates a fresh backup of the current active version (Version A).
2. **Downloads the latest version again (Version B or newer Version C)**.
3. **Stops services, updates binaries, and restarts services**.
4. The system is now running **Version B (again) or Version C (if updated in the repository)**.

---

## Important Notes
- **Only one backup version is stored at a time.** When `update.sh` runs, it overwrites the previous backup.
- **If the repository has not changed**, running `update.sh` after rollback **will reinstall the same broken version**.
- **Check the repository before updating** to ensure a fixed version is available.
- **If the update involves database changes**, additional rollback steps may be needed.

---

## Commands
### **Install the software**
```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/refs/heads/main/install.sh | bash -s <api_key> <client_id>
```

### **Update the software**
```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/main/update.sh | bash
```

### **Rollback to the previous version**
```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/main/rollback.sh | bash
```

### **Check service status**
```bash
sudo systemctl status <service-name>
```

---
