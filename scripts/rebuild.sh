#!/usr/bin/env bash
set -euo pipefail

# Top-level orchestration script for rebuild. Supports --dry-run and --confirm.

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=true

if [ "${1:-}" = "--confirm" ]; then
  DRY_RUN=false
fi

run() {
  echo "+ $*"
  if [ "$DRY_RUN" = false ]; then
    eval "$@"
  fi
}

echo "[rebuild] Dry run mode: $DRY_RUN"

# Steps
run "bash $SCRIPTS_DIR/install_steamcmd.sh"
run "bash $SCRIPTS_DIR/fix_steamcmd.sh"
run "bash $SCRIPTS_DIR/install_pz.sh"
run "bash $SCRIPTS_DIR/configure_server.sh"
run "bash $SCRIPTS_DIR/setup_mods.sh"
run "bash $SCRIPTS_DIR/setup_cron.sh"

echo "[rebuild] Restarting pzserver service"
run "systemctl restart pzserver"

echo "[rebuild] Completed (dry-run=$DRY_RUN). To execute for real: sudo bash $0 --confirm"
