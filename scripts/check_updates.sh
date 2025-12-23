#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [스마트 업데이트 스크립트]
# 매일 새벽(예: 03:00)에 실행하여 서버 업데이트를 확인하고 적용합니다.
# 단, 플레이어가 접속해 있다면 업데이트를 미루어 게임 끊김을 방지합니다.
#
# [작동 원리]
# 1. 최신 서버 로그를 분석하여 현재 접속자 수 확인
# 2. 접속자가 0명일 때만 서버 종료 -> 업데이트 -> 재시작
# -----------------------------------------------------------------------------

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="/home/steam/Zomboid/Logs"
REBUILD_SCRIPT="$SCRIPTS_DIR/rebuild.sh"

echo "[check_updates] 일일 업데이트 점검을 시작합니다..."

# 1. 최신 서버 로그 파일 찾기
# 가장 최근에 수정된 _DebugLog-server.txt 파일을 찾습니다.
LATEST_LOG=$(sudo ls -t "$LOG_DIR"/*_DebugLog-server.txt 2>/dev/null | head -n 1 || true)

if [ -z "$LATEST_LOG" ]; then
  echo "[check_updates] ⚠️ 경고: 서버 로그를 찾을 수 없습니다. 접속자가 없는 것으로 간주합니다."
  PLAYER_COUNT=0
else
  # 2. 접속자 수 확인
  # 로그의 마지막 100줄에서 "Players: X" 패턴을 찾아 가장 최근 값을 가져옵니다.
  PLAYER_COUNT=$(sudo tail -n 100 "$LATEST_LOG" | grep -o "Players: [0-9]*" | tail -n 1 | awk '{print $2}' || echo "0")
  echo "[check_updates] 현재 접속자 수: $PLAYER_COUNT 명"
fi

# 3. 업데이트 진행 여부 결정
if [ "$PLAYER_COUNT" -eq 0 ]; then
  echo "[check_updates] 접속자가 0명이므로 업데이트를 진행합니다."
  
  # 안전한 종료를 위해 quit 명령 전송
  if pgrep -f "screen.*pzserver" > /dev/null; then
    echo "[check_updates] 서버를 안전하게 종료합니다 (/quit)..."
    sudo -u steam screen -S pzserver -X stuff "quit$(echo -ne '\r')"
    sleep 30 # 종료 대기
  fi
  
  # 서버 재구축 및 업데이트 실행 (rebuild.sh 호출)
  # --confirm 옵션으로 사용자 확인 없이 진행
  sudo bash "$REBUILD_SCRIPT" --confirm
  
  echo "[check_updates] ✅ 업데이트 및 재시작이 완료되었습니다."
else
  echo "[check_updates] ⛔ 현재 플레이어가 접속 중입니다 ($PLAYER_COUNT 명). 업데이트를 건너뜁니다."
fi
