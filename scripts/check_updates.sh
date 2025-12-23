#!/usr/bin/env bash
set -euo pipefail

# Smart update script for Project Zomboid
# Runs daily at 3 AM
# Checks for player count and performs update if 0 players

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="/home/steam/Zomboid/Logs"
REBUILD_SCRIPT="$SCRIPTS_DIR/rebuild.sh"

echo "[check_updates] Starting daily update check (3 AM)..."

# 1. Find the latest server log
LATEST_LOG=$(sudo ls -t "$LOG_DIR"/*_DebugLog-server.txt 2>/dev/null | head -n 1 || true)

if [ -z "$LATEST_LOG" ]; then
  echo "[check_updates] Warning: No server log found. Assuming 0 players."
  PLAYER_COUNT=0
else
  # 2. Check player count from the last 50 lines of the log
  # Look for pattern: "Players: X"
  PLAYER_COUNT=$(sudo tail -n 100 "$LATEST_LOG" | grep -o "Players: [0-9]*" | tail -n 1 | awk '{print $2}' || echo "0")
  echo "[check_updates] Current player count: $PLAYER_COUNT"
fi

# 3. Perform update if 0 players
if [ "$PLAYER_COUNT" -eq 0 ]; then
  echo "[check_updates] 0 players online. Proceeding with update..."
  
  # Send shutdown command to be safe
  if pgrep -f "screen.*pzserver" > /dev/null; then
    echo "[check_updates] Sending /quit to server..."
    sudo -u steam screen -S pzserver -X stuff "quit$(echo -ne '\r')"
    sleep 30
  fi
  
  # Run rebuild (which includes app_update and setup_mods)
  sudo bash "$REBUILD_SCRIPT" --confirm
  
  echo "[check_updates] Update and restart completed."
else
  echo "[check_updates] Players are online ($PLAYER_COUNT). Skipping update to avoid disruption."
fi
