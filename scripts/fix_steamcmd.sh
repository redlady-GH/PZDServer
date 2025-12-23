#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [SteamCMD 경로 수정 스크립트]
# /usr/local/bin/steamcmd 실행 파일이 올바른 설치 경로를 가리키도록 수정합니다.
# 이 스크립트는 root 권한으로 실행해야 합니다.
# -----------------------------------------------------------------------------

echo "[fix_steamcmd] /usr/local/bin/steamcmd 래퍼(wrapper) 업데이트 중..."

# steamcmd 실행 시 /home/steam/steamcmd.sh를 호출하도록 스크립트 작성
# (install_steamcmd.sh 설치 경로 기준)
cat > /usr/local/bin/steamcmd <<'EOF'
#!/usr/bin/env bash
/home/steam/steamcmd.sh "$@"
