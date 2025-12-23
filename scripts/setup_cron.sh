#!/usr/bin/env bash
set -euo pipefail

# Setup cron jobs for Project Zomboid server management
# Run as root

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SCRIPT="$SCRIPTS_DIR/auto_backup.sh"
UPDATE_SCRIPT="$SCRIPTS_DIR/check_updates.sh"

echo "[setup_cron] Registering cron jobs..."

# 1. Create a temporary crontab file
TMP_CRON=$(mktemp)
crontab -l > "$TMP_CRON" 2>/dev/null || true

# 2. Remove existing PZ related cron jobs to avoid duplicates
sed -i '/auto_backup.sh/d' "$TMP_CRON"
sed -i '/check_updates.sh/d' "$TMP_CRON"

# 3. Add new cron jobs
# Every 1 hour for backup (at 15 minutes past the hour to avoid collision with 30-min auto-save)
echo "15 * * * * /bin/bash $BACKUP_SCRIPT >> /var/log/pz_backup.log 2>&1" >> "$TMP_CRON"
# Every day at 3 AM for update check
echo "0 3 * * * /bin/bash $UPDATE_SCRIPT >> /var/log/pz_update.log 2>&1" >> "$TMP_CRON"

# 4. Apply the new crontab
crontab "$TMP_CRON"
rm "$TMP_CRON"

echo "[setup_cron] Done. Current crontab:"
crontab -l | grep -E "auto_backup|check_updates"
