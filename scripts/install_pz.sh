#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [프로젝트 좀보이드 설치 스크립트]
# SteamCMD를 사용하여 프로젝트 좀보이드 전용 서버(App ID: 380870)를 설치합니다.
# root 권한으로 실행하지만, 실제 파일 소유권은 'steam' 계정이 가집니다.
# -----------------------------------------------------------------------------

STEAM_HOME=/home/steam
PZ_DIR=$STEAM_HOME/pzsteam

# SteamCMD 설치 여부 확인
if [ ! -f "$STEAM_HOME/steamcmd.sh" ]; then
  echo "❌ 오류: steamcmd가 설치되지 않았습니다. scripts/install_steamcmd.sh를 먼저 실행하세요." >&2
  exit 1
fi

echo "[install_pz] 프로젝트 좀보이드를 설치합니다 (경로: $PZ_DIR)"

# 설치 디렉토리 생성
sudo -u steam mkdir -p "$PZ_DIR"

# SteamCMD 실행: 익명 로그인 -> 설치 경로 설정 -> 앱 업데이트(설치) -> 종료
sudo -u steam "$STEAM_HOME/steamcmd.sh" +force_install_dir "$PZ_DIR" +login anonymous +app_update 380870 validate +quit

echo "[install_pz] steamclient.so 라이브러리 연결 (워크숍 모드 호환성)"
# 일부 모드나 워크숍 기능이 steamclient.so를 찾지 못하는 문제를 해결하기 위해 링크/복사합니다.
sudo -u steam mkdir -p /home/steam/.steam/sdk64
if [ -f "$STEAM_HOME/linux64/steamclient.so" ]; then
  sudo -u steam cp "$STEAM_HOME/linux64/steamclient.so" /home/steam/.steam/sdk64/
  echo "[install_pz] ✅ steamclient.so 복사 완료"
else
  echo "[install_pz] ⚠️ 경고: steamclient.so 파일을 찾을 수 없습니다. 일부 기능이 제한될 수 있습니다." >&2
fi

echo "[install_pz] ✅ 설치가 완료되었습니다."
