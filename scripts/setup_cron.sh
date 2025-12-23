#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [자동화 작업(Cron) 등록 스크립트]
# 자동 백업과 스마트 업데이트 기능을 리눅스 크론탭(Crontab)에 등록합니다.
# root 권한으로 실행해야 합니다.
# -----------------------------------------------------------------------------

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SCRIPT="$SCRIPTS_DIR/auto_backup.sh"
UPDATE_SCRIPT="$SCRIPTS_DIR/check_updates.sh"

echo "[setup_cron] 크론 작업(Cron Jobs)을 등록합니다..."

# 1. 현재 크론탭 백업 및 임시 파일 생성
TMP_CRON=$(mktemp)
crontab -l > "$TMP_CRON" 2>/dev/null || true

# 2. 기존 PZ 관련 작업 제거 (중복 방지)
sed -i '/auto_backup.sh/d' "$TMP_CRON"
sed -i '/check_updates.sh/d' "$TMP_CRON"

# 3. 새 작업 추가
# 매시간 15분에 백업 실행 (인게임 자동 저장인 00분/30분과 겹치지 않도록 설정)
echo "15 * * * * /bin/bash $BACKUP_SCRIPT >> /var/log/pz_backup.log 2>&1" >> "$TMP_CRON"
# 매일 새벽 3시에 업데이트 확인 및 실행
echo "0 3 * * * /bin/bash $UPDATE_SCRIPT >> /var/log/pz_update.log 2>&1" >> "$TMP_CRON"

# 4. 크론탭 적용
crontab "$TMP_CRON"
rm "$TMP_CRON"

echo "[setup_cron] ✅ 등록 완료. 현재 설정된 작업 목록:"
crontab -l | grep -E "auto_backup|check_updates"
