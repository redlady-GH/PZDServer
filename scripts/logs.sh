#!/bin/bash
# 최신 서버 로그를 실시간으로 확인합니다.
# 사용법: ./logs.sh

LOG_FILE=$(ls -t /home/steam/Zomboid/Logs/*_DebugLog-server.txt | head -n 1)

if [ -z "$LOG_FILE" ]; then
    echo "로그 파일을 찾을 수 없습니다."
    exit 1
fi

echo "최신 로그 확인 중: $LOG_FILE"
sudo tail -f "$LOG_FILE"
