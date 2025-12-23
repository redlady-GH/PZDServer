#!/usr/bin/env bash
set -euo pipefail

# Reads mods_list.txt (CSV: WorkshopID,ModID) and generates /home/steam/Zomboid/Server/servertest.ini
# Ensure to set SERVER_NAME and WORLD_NAME at the top of this script if you wish to override.

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
MODS_FILE="$SCRIPTS_DIR/mods_list.txt"
PW_FILE="$(dirname "$SCRIPTS_DIR")/pz_admin_pw.txt"
SERVER_DIR=/home/steam/Zomboid/Server

# Server name and world name (commented location for user):
# Set server name here:
SERVER_NAME="MyServer"  # <-- Set server name here
WORLD_NAME="MyWorld"   # <-- Set world name here
SERVER_PASSWORD="changeme" # <-- Set server password here

# Ensure directory exists and is owned by steam
mkdir -p "$SERVER_DIR"
chown steam:steam "$SERVER_DIR" || true

if [ ! -f "$MODS_FILE" ]; then
  echo "mods_list.txt not found at $MODS_FILE" >&2
  exit 1
fi

ADMIN_PW=""
if [ -f "$PW_FILE" ]; then
  ADMIN_PW=$(cat "$PW_FILE" | tr -d ' \t\n\r')
fi

WORKSHOP_IDS=()
MOD_IDS=()
while IFS= read -r line; do
  line="${line%%#*}" # strip comments
  # Strip leading/trailing whitespace but keep internal spaces
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  if [ -z "$line" ]; then
    continue
  fi
  IFS=',' read -r wid mid <<< "$line"
  # Trim wid and mid individually
  wid=$(echo "$wid" | tr -d ' \t')
  mid=$(echo "$mid" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  WORKSHOP_IDS+=("$wid")
  MOD_IDS+=("$mid")
done < "$MODS_FILE"

workshop_semicolon=$(IFS=';'; echo "${WORKSHOP_IDS[*]}")
mods_semicolon=$(IFS=';'; echo "${MOD_IDS[*]}")

# Ensure they are single lines (remove any accidental newlines)
workshop_semicolon=$(echo "$workshop_semicolon" | tr -d '\n\r')
mods_semicolon=$(echo "$mods_semicolon" | tr -d '\n\r')

SERVER_INI="$SERVER_DIR/${SERVER_NAME}.ini"
# Backup existing if not already backed up
if [ -f "$SERVER_INI" ] && [ ! -f "$SERVER_INI.bak" ]; then
  cp "$SERVER_INI" "$SERVER_INI.bak"
fi

# We use a template or just write the essential lines.
# Note: WorkshopItems MUST use semicolons.
cat > "$SERVER_INI" <<EOF
Public=true
Steam=true
Name=$SERVER_NAME
WorldName=$WORLD_NAME
WorkshopItems=$workshop_semicolon
Mods=$mods_semicolon
DefaultAdminPassword=$ADMIN_PW
Password=$SERVER_PASSWORD
EOF

chown steam:steam "$SERVER_INI"
chmod 644 "$SERVER_INI"

echo "[setup_mods] Wrote $SERVER_INI with $(echo "$workshop_semicolon" | tr ';' '\n' | wc -l) workshop items and AdminPassword."
