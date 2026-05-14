#!/bin/bash

# jump to the main program directory (may be not necessary)
cd /home/pi/PiFmRds/src

# Define Stream URL to extract RDS data + FIFO pipe 
# (make sure URL and FIFO file match the 'playradio.sh' script)
STREAM_URL="http://173.249.33.152:8000/stream"
CONTROL_FILE="/home/pi/PiFmRds/src/rds_control"

# Loop to update RDS (rds_control)
while true; do
    # Get station info, songtitles, etc. from the streaming URL, loop (update) every 20 seconds
    TITLE=$(curl -s --max-time 10 --get "$STREAM_URL" -H "Icy-MetaData: 1" | strings | grep -i "StreamTitle" | tail -n 1 | sed "s/.*StreamTitle='\([^']*\)'.*/\1/")
    if [ -z "$TITLE" ]; then
        TITLE="RT No RDS text available"
    fi
    # Echo the output, the cat command in the playradio.sh script will pipe this output as input for the FIFO file. 
    # (The RT prefix is necessary for the 'pi_fm_rds' program to transmit it as RDS text)
    echo "RT $TITLE"
    # The 'pi_fm_rds' is connected to the other side of the FIFO pipe and will use it as RDS input 
    sleep 20
done
