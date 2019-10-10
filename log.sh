#!/bin/bash
export log_name=$(pwd)/log-$(env TZ='Asia/Jakarta' date +%Y%m%d).txt
bash build.sh > $log_name
curl -v -F "chat_id=$TELEGRAM_CHAT" -F document=@$log_name -F "parse_mode=html" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument
