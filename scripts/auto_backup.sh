#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [자동 백업 스크립트]
# 프로젝트 좀보이드 서버의 데이터(세이브 파일)와 설정을 자동으로 백업합니다.
# 데이터 유실 사고를 대비해 주기적으로 실행하는 것이 좋습니다. (예: 1시간마다)
#
# [기능]
# 1. 서버에 저장 명령(/save) 전송
# 2. Zomboid 폴더 전체 압축 및 저장
# 3. 7일이 지난 오래된 백업 파일 자동 삭제
# -----------------------------------------------------------------------------

# 백업 파일이 저장될 경로 (스크립트 위치 기준 상위 폴더의 backups/auto)
BACKUP_ROOT="$(dirname "$(cd "$(dirname "$0")" && pwd)")/../backups/auto"
ZOMBOID_DIR="/home/steam/Zomboid"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_ROOT/pz_backup_$TIMESTAMP.tar.gz"

echo "[auto_backup] 백업 프로세스를 시작합니다..."

# 백업 디렉토리가 없으면 생성합니다.
mkdir -p "$BACKUP_ROOT"

# 1. 데이터 동기화 (메모리 -> 디스크)
# 서버가 실행 중이라면 'save' 명령어를 보내 최신 상태를 저장합니다.
echo "[auto_backup] 서버에 저장 명령(save)을 전송합니다..."
if pgrep -f "pzserver" > /dev/null; then
  # screen 세션에 'save' 입력 후 엔터(\r)
  sudo -u steam screen -S pzserver -X stuff "save$(echo -ne '\r')"
  sleep 5 # 저장이 완료될 때까지 잠시 대기
else
  echo "[auto_backup] ⚠️ 경고: 서버가 실행 중이지 않습니다. 저장 명령을 건너뜁니다."
fi

# 2. 압축 백업 생성
# /home/steam/Zomboid 폴더를 통째로 압축합니다.
echo "[auto_backup] 백업 파일 생성 중: $BACKUP_FILE"
if [ -d "$ZOMBOID_DIR" ]; then
  # tar 명령어로 압축 (절대 경로 문제 방지를 위해 -C 옵션 사용)
  tar -czf "$BACKUP_FILE" -C "/home/steam" "Zomboid" 2>/dev/null || {
    echo "[auto_backup] ❌ 오류: 압축 과정에서 문제가 발생했습니다."
    exit 1
  }
else
  echo "[auto_backup] ❌ 오류: $ZOMBOID_DIR 폴더를 찾을 수 없습니다."
  exit 1
fi

# 3. 오래된 백업 정리
# 디스크 용량 확보를 위해 7일 이상 된 파일은 삭제합니다.
echo "[auto_backup] 7일 지난 오래된 백업 파일을 정리합니다..."
find "$BACKUP_ROOT" -name "pz_backup_*.tar.gz" -mtime +7 -delete

echo "[auto_backup] ✅ 백업이 성공적으로 완료되었습니다. (크기: $(ls -lh "$BACKUP_FILE" | awk '{print $5}'))"
