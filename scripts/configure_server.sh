#!/usr/bin/env bash
set -euo pipefail

# Configure JVM settings, create systemd unit for pzserver
# Run as root; file edits use sudo -u steam where appropriate

STEAM_HOME=/home/steam
PZ_DIR=$STEAM_HOME/pzsteam

echo "[configure_server] Backing up ProjectZomboid64.json if present"
if [ -f "$PZ_DIR/ProjectZomboid64.json" ]; then
  sudo -u steam cp "$PZ_DIR/ProjectZomboid64.json" "$PZ_DIR/ProjectZomboid64.json.bak"
fi

echo "[configure_server] Applying JVM memory and GC defaults (8g, ZGC)"
# Attempt to set Xms/Xmx to 8g; commands are idempotent
if [ -f "$PZ_DIR/ProjectZomboid64.json" ]; then
  sudo -u steam sed -i 's/"-Xms[0-9]*g"/"-Xms8g"/g' "$PZ_DIR/ProjectZomboid64.json" || true
  sudo -u steam sed -i 's/"-Xmx[0-9]*g"/"-Xmx8g"/g' "$PZ_DIR/ProjectZomboid64.json" || true
fi

echo "[configure_server] Ensuring start-server.sh is executable"
chmod +x "$PZ_DIR/start-server.sh" || true
chown steam:steam "$PZ_DIR/start-server.sh" || true

echo "[configure_server] Writing systemd unit /etc/systemd/system/pzserver.service"
ADMIN_PW=$(cat /home/dev/server/z/scripts/pz_admin_pw.txt | tr -d ' \t\n\r')
cat > /etc/systemd/system/pzserver.service <<UNIT
[Unit]
Description=Project Zomboid Dedicated Server
After=network.target

[Service]
Type=simple
User=steam
WorkingDirectory=/home/steam/pzsteam
ExecStart=/usr/bin/screen -D -m -S pzserver /bin/bash ./start-server.sh -servername Labyrinth -adminpassword $ADMIN_PW
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
echo "[configure_server] systemd unit created. Enable with: systemctl enable pzserver"
