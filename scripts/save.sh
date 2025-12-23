#!/bin/bash
# 서버 월드 데이터를 수동으로 저장합니다.
# 사용법: ./save.sh

sudo -u steam screen -S pzserver -X stuff "save\n"
echo "서버 저장 명령을 전송했습니다."
