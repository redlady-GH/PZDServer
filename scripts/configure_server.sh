#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [서버 환경 설정 스크립트]
# JVM 메모리 설정, 시스템 서비스(systemd) 등록 등 서버 실행 환경을 구성합니다.
# 이 스크립트는 root 권한으로 실행해야 합니다.
# -----------------------------------------------------------------------------

STEAM_HOME=/home/steam
PZ_DIR=$STEAM_HOME/pzsteam
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# 관리자 비밀번호 파일 위치
ADMIN_PW_FILE="$SCRIPTS_DIR/pz_admin_pw.txt"

echo "[configure_server] ProjectZomboid64.json 백업 중..."
if [ -f "$PZ_DIR/ProjectZomboid64.json" ]; then
  sudo -u steam cp "$PZ_DIR/ProjectZomboid64.json" "$PZ_DIR/ProjectZomboid64.json.bak"
fi

echo "[configure_server] JVM 메모리 및 GC 설정 적용 (8GB, ZGC)"
# 기본 메모리를 8GB로 설정합니다. 서버 사양에 따라 수정 가능합니다.
# sed 명령어를 사용하여 설정 파일의 내용을 직접 수정합니다.
if [ -f "$PZ_DIR/ProjectZomboid64.json" ]; then
  sudo -u steam sed -i 's/"-Xms[0-9]*g"/"-Xms8g"/g' "$PZ_DIR/ProjectZomboid64.json" || true
  sudo -u steam sed -i 's/"-Xmx[0-9]*g"/"-Xmx8g"/g' "$PZ_DIR/ProjectZomboid64.json" || true
fi

echo "[configure_server] 실행 스크립트(start-server.sh) 권한 설정"
chmod +x "$PZ_DIR/start-server.sh" || true
chown steam:steam "$PZ_DIR/start-server.sh" || true

echo "[configure_server] systemd 서비스 파일 생성 (/etc/systemd/system/pzserver.service)"

# 관리자 비밀번호 읽기
if [ -f "$ADMIN_PW_FILE" ]; then
    ADMIN_PW=$(cat "$ADMIN_PW_FILE" | tr -d ' \t\n\r')
else
    echo "❌ 오류: 관리자 비밀번호 파일($ADMIN_PW_FILE)이 없습니다."
    exit 1
fi

# setup_mods.sh에서 서버 이름 가져오기 (없으면 기본값)
if [ -f "$SCRIPTS_DIR/setup_mods.sh" ]; then
    SERVER_NAME=$(grep '^SERVER_NAME=' "$SCRIPTS_DIR/setup_mods.sh" | cut -d'"' -f2)
fi
if [ -z "${SERVER_NAME:-}" ]; then SERVER_NAME="servertest"; fi

cat > /etc/systemd/system/pzserver.service <<UNIT
[Unit]
Description=Project Zomboid Dedicated Server
After=network.target

[Service]
Type=simple
User=steam
WorkingDirectory=/home/steam/pzsteam
# -servername 옵션에 감지된 이름을 사용합니다.
ExecStart=/usr/bin/screen -D -m -S pzserver /bin/bash ./start-server.sh -servername $SERVER_NAME -adminpassword $ADMIN_PW
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
echo "[configure_server] ✅ systemd 서비스가 생성되었습니다."
echo "다음 명령어로 서버를 부팅 시 자동 실행되게 할 수 있습니다: systemctl enable pzserver"
