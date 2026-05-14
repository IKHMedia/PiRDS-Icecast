#!/bin/bash

# end any running playing processes
killall sox
killall pi_fm_rds

# jump to the main program directory (may be not necessary)
cd /home/pi/PiFmRds/src

# Define streaming URL & FIFO pipe
# (make sure URL and FIFO file match the 'updaterds.sh' script)
STREAM_URL="http://173.249.33.152:8000/stream"
CONTROL_FILE="/home/pi/PiFmRds/src/rds_control"

# recreate FIFO pipe
rm -f $CONTROL_FILE
mkfifo $CONTROL_FILE
chown pi:pi $CONTROL_FILE

# Start streaming
# (by ending with an '&' the command moves to the background, so the next command will run)
sox -t mp3 "$STREAM_URL" -t wav -c 2 - | sudo ./pi_fm_rds -freq 107.1 -ps "WNAM 1280" -rt "Blue 128 is Back" -audio - -ctl "$CONTROL_FILE"&

# Call the RDS updater script and pipe the output via cat to the FIFO file/pipe
"./updaterds.sh" | cat > rds_control
