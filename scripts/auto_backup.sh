#!/usr/bin/env bash
set -euo pipefail

# Automatic backup script for Project Zomboid
# Backs up save data and server configuration
# Retains backups for 7 days

BACKUP_ROOT="/home/dev/server/z/backups/auto"
ZOMBOID_DIR="/home/steam/Zomboid"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_ROOT/pz_backup_$TIMESTAMP.tar.gz"

echo "[auto_backup] Starting backup process..."

# Ensure backup directory exists
mkdir -p "$BACKUP_ROOT"

# 1. Sync data to disk by sending /save command to the server
echo "[auto_backup] Sending /save command to server..."
if pgrep -f "pzserver" > /dev/null; then
  sudo -u steam screen -S pzserver -X stuff "save$(echo -ne '\r')"
  sleep 5 # Wait for save to complete
else
  echo "[auto_backup] Warning: Server screen session not found. Skipping /save."
fi

# 2. Create compressed backup
echo "[auto_backup] Creating archive: $BACKUP_FILE"
if [ -d "$ZOMBOID_DIR" ]; then
  tar -czf "$BACKUP_FILE" -C "/home/steam" "Zomboid" 2>/dev/null || {
    echo "[auto_backup] Error: Backup failed during compression."
    exit 1
  }
else
  echo "[auto_backup] Error: $ZOMBOID_DIR not found. Nothing to backup."
  exit 1
fi

# 3. Cleanup old backups (older than 7 days)
echo "[auto_backup] Cleaning up backups older than 7 days..."
find "$BACKUP_ROOT" -name "pz_backup_*.tar.gz" -mtime +7 -delete

echo "[auto_backup] Backup completed successfully: $(ls -lh "$BACKUP_FILE" | awk '{print $5}')"
