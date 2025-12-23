#!/usr/bin/env bash
set -euo pipefail

# Fixes the /usr/local/bin/steamcmd wrapper to point to the correct /opt/steamcmd installation.
# Run as root.

echo "[fix_steamcmd] Updating /usr/local/bin/steamcmd wrapper"

cat > /usr/local/bin/steamcmd <<'EOF'
#!/usr/bin/env bash
/opt/steamcmd/steamcmd.sh "$@"
EOF

chmod +x /usr/local/bin/steamcmd

echo "[fix_steamcmd] Done. steamcmd now points to /opt/steamcmd/steamcmd.sh"
