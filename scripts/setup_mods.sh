#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# [모드 설정 및 서버 설정 생성 스크립트]
# mods_list.txt 파일을 읽어 서버 설정 파일(.ini)을 자동으로 생성합니다.
# 모드 ID와 워크숍 ID를 일일이 입력하는 번거로움을 줄여줍니다.
# -----------------------------------------------------------------------------

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
MODS_FILE="$SCRIPTS_DIR/mods_list.txt"
# 비밀번호 파일 위치 (배포판 기준)
PW_FILE="$SCRIPTS_DIR/pz_admin_pw.txt"
SERVER_DIR=/home/steam/Zomboid/Server

# -----------------------------------------------------------------------------
# [사용자 설정 영역]
# 아래 변수들을 자신의 서버 환경에 맞게 수정하세요.
# -----------------------------------------------------------------------------
SERVER_NAME="MyServer"      # 서버 이름 (설정 파일명으로도 사용됨)
WORLD_NAME="MyWorld"        # 월드(맵) 이름
SERVER_PASSWORD="changeme"  # 서버 접속 비밀번호 (사용자에게 공개)
# -----------------------------------------------------------------------------

# 디렉토리 생성 및 권한 설정
mkdir -p "$SERVER_DIR"
chown steam:steam "$SERVER_DIR" || true

if [ ! -f "$MODS_FILE" ]; then
  echo "❌ 오류: 모드 목록 파일($MODS_FILE)을 찾을 수 없습니다." >&2
  exit 1
fi

ADMIN_PW=""
if [ -f "$PW_FILE" ]; then
  ADMIN_PW=$(cat "$PW_FILE" | tr -d ' \t\n\r')
fi

# mods_list.txt 파싱 (CSV 형식: 워크숍ID, 모드ID)
WORKSHOP_IDS=()
MOD_IDS=()
while IFS= read -r line; do
  line="${line%%#*}" # 주석 제거
  # 앞뒤 공백 제거
  line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  if [ -z "$line" ]; then
    continue
  fi
  IFS=',' read -r wid mid <<< "$line"
  
  # 워크숍 ID와 모드 ID 추출 및 공백 제거
  wid=$(echo "$wid" | tr -d ' \t')
  mid=$(echo "$mid" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  
  if [ -n "$wid" ] && [ -n "$mid" ]; then
      WORKSHOP_IDS+=("$wid")
      MOD_IDS+=("$mid")
  fi
done < "$MODS_FILE"

# 세미콜론(;)으로 구분된 문자열 생성
workshop_semicolon=$(IFS=';'; echo "${WORKSHOP_IDS[*]}")
mods_semicolon=$(IFS=';'; echo "${MOD_IDS[*]}")

# 줄바꿈 문자 제거 (안전장치)
workshop_semicolon=$(echo "$workshop_semicolon" | tr -d '\n\r')
mods_semicolon=$(echo "$mods_semicolon" | tr -d '\n\r')

SERVER_INI="$SERVER_DIR/${SERVER_NAME}.ini"

# 기존 설정 파일 백업
if [ -f "$SERVER_INI" ] && [ ! -f "$SERVER_INI.bak" ]; then
  cp "$SERVER_INI" "$SERVER_INI.bak"
fi

# 설정 파일 생성 (덮어쓰기)
# 주의: WorkshopItems는 반드시 세미콜론으로 구분되어야 합니다.
cat > "$SERVER_INI" <<EOF
Public=true
Steam=true
Name=$SERVER_NAME
WorldName=$WORLD_NAME
WorkshopItems=$workshop_semicolon
Mods=$mods_semicolon
DefaultAdminPassword=$ADMIN_PW
Password=$SERVER_PASSWORD
EOF

chown steam:steam "$SERVER_INI"
chmod 644 "$SERVER_INI"

echo "[setup_mods] ✅ $SERVER_INI 파일 생성 완료."
echo "  - 포함된 워크숍 아이템 수: $(echo "$workshop_semicolon" | tr ';' '\n' | wc -l) 개"
