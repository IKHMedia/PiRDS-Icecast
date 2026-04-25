#!/bin/bash
killall sox
killall pi_fm_rds

# Start streaming con file di controllo
STREAM_URL="http://74.208.108.39:8000/Test"
CONTROL_FILE="/tmp/rds_control"

cd /root/PiFmRds/src
sox  -t mp3 "$STREAM_URL" -t wav -c 2 - | sudo ./pi_fm_rds -freq 107.1 -ps "W296BF - WNAM" -rt "AM 1280 and FM 107.1" -audio - -ctl "$CONTROL_FILE" &

# Loop per aggiornare Radio Text
while true; do
    TITLE=$(curl -s --max-time 10 --get "$STREAM_URL" -H "Icy-MetaData: 1" | strings | grep -i "StreamTitle" | tail -n 1 | sed "s/.*StreamTitle='\([^']*\)'.*/\1/")
    if [ -z "$TITLE" ]; then
        TITLE="Nessun titolo disponibile"
    fi
    echo "Titolo corrente: $TITLE" | tee -a /tmp/radio_titles.log
    echo "RT $TITLE" > "$CONTROL_FILE"  # Aggiorna -rt
    sleep 10
done
