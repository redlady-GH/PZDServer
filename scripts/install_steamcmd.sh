#!/usr/bin/env bash
set -euo pipefail

# Install SteamCMD and required 32-bit libs
# Run as root. Steam account operations use sudo -u steam.

echo "[install_steamcmd] Installing prerequisites..."
apt update
apt install -y lib32gcc-s1 wget ca-certificates tar

STEAM_HOME=/home/steam
sudo -u steam mkdir -p "$STEAM_HOME/Steam"
echo "[install_steamcmd] Downloading steamcmd..."
sudo -u steam wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | sudo -u steam tar xvz -C "$STEAM_HOME"

echo "[install_steamcmd] Done. SteamCMD at $STEAM_HOME/steamcmd.sh"
