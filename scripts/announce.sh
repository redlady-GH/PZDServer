#!/bin/bash
# 서버에 공지 메시지를 보냅니다.
# 사용법: ./announce.sh "메시지 내용"

if [ -z "$1" ]; then
    echo "사용법: $0 \"메시지 내용\""
    exit 1
fi

MESSAGE="$1"
sudo -u steam screen -S pzserver -X stuff "servermsg \"$MESSAGE\"\n"
echo "공지 전송 완료: $MESSAGE"
