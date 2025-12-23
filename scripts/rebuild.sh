#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [서버 재구축 및 통합 실행 스크립트]
# 서버 설치, 설정, 모드 적용, 크론잡 등록 등 모든 과정을 순차적으로 실행합니다.
# 실수 방지를 위해 기본적으로 'Dry Run(가상 실행)' 모드로 동작하며,
# 실제 실행하려면 --confirm 옵션을 붙여야 합니다.
# -----------------------------------------------------------------------------

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=true

if [ "${1:-}" = "--confirm" ]; then
  DRY_RUN=false
fi

# 명령어 실행 함수 (Dry Run 체크)
run() {
  echo "+ $*"
  if [ "$DRY_RUN" = false ]; then
    eval "$@"
  fi
}

echo "[rebuild] 현재 모드: $( [ "$DRY_RUN" = true ] && echo "가상 실행 (Dry Run)" || echo "실제 실행 (Live)" )"

# 단계별 스크립트 실행
run "bash $SCRIPTS_DIR/install_steamcmd.sh"   # 1. SteamCMD 설치
run "bash $SCRIPTS_DIR/fix_steamcmd.sh"       # 2. SteamCMD 경로 수정
run "bash $SCRIPTS_DIR/install_pz.sh"         # 3. 프로젝트 좀보이드 설치
run "bash $SCRIPTS_DIR/configure_server.sh"   # 4. 서버 환경 설정 (메모리, 서비스 등)
run "bash $SCRIPTS_DIR/setup_mods.sh"         # 5. 모드 설정 적용 (.ini 생성)
run "bash $SCRIPTS_DIR/setup_cron.sh"         # 6. 자동화 작업(Cron) 등록

echo "[rebuild] pzserver 서비스 재시작 중..."
run "systemctl restart pzserver"

echo "[rebuild] 작업 완료. (Dry Run 여부: $DRY_RUN)"
if [ "$DRY_RUN" = true ]; then
  echo "💡 실제로 실행하려면 다음 명령어를 입력하세요: sudo bash $0 --confirm"
fi
