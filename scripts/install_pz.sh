#!/usr/bin/env bash
set -euo pipefail

# Install Project Zomboid dedicated server using SteamCMD
# Run as root; server files will be owned by 'steam'

STEAM_HOME=/home/steam
PZ_DIR=$STEAM_HOME/pzsteam

if [ ! -f "$STEAM_HOME/steamcmd.sh" ]; then
  echo "steamcmd not found. Run scripts/install_steamcmd.sh first." >&2
  exit 1
fi

echo "[install_pz] Installing Project Zomboid to $PZ_DIR"
sudo -u steam mkdir -p "$PZ_DIR"
sudo -u steam "$STEAM_HOME/steamcmd.sh" +force_install_dir "$PZ_DIR" +login anonymous +app_update 380870 validate +quit

echo "[install_pz] Ensuring steamclient.so is available in SDK path"
sudo -u steam mkdir -p /home/steam/.steam/sdk64
if [ -f "$STEAM_HOME/linux64/steamclient.so" ]; then
  sudo -u steam cp "$STEAM_HOME/linux64/steamclient.so" /home/steam/.steam/sdk64/
  echo "[install_pz] Copied steamclient.so to ~/.steam/sdk64/"
else
  echo "[install_pz] Warning: $STEAM_HOME/linux64/steamclient.so not found — some workshop operations may fail" >&2
fi

echo "[install_pz] Done."
