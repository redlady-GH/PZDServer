#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [SteamCMD 설치 스크립트]
# 밸브(Valve)의 커맨드라인 도구인 SteamCMD와 필수 의존성 패키지를 설치합니다.
# root 권한으로 실행해야 합니다.
# -----------------------------------------------------------------------------

echo "[install_steamcmd] 필수 패키지 설치 중..."
# 32비트 라이브러리 지원 등 필요한 패키지 설치
apt update
apt install -y lib32gcc-s1 wget ca-certificates tar

STEAM_HOME=/home/steam

# steam 사용자 계정의 홈 디렉토리에 설치합니다.
sudo -u steam mkdir -p "$STEAM_HOME/Steam"

echo "[install_steamcmd] SteamCMD 다운로드 및 압축 해제..."
# 공식 서버에서 다운로드하여 압축 해제
sudo -u steam wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | sudo -u steam tar xvz -C "$STEAM_HOME"

echo "[install_steamcmd] ✅ 설치 완료. 위치: $STEAM_HOME/steamcmd.sh"
