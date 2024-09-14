#!/bin/bash

REMOTE_SERVER="10.1.0.150"
BITRATE="500M"
DURATION=20 # Set duration of each iperf3 run to 5 seconds
LOG_FILE="/tmp/iperf3_log.txt"
IPERF3_CMD="iperf3 --udp --client $REMOTE_SERVER --bitrate $BITRATE -t $DURATION"

# Start time tracking
LAST_START=0

# Function to start iperf3 and redirect output to log file
start_iperf() {
    echo "Starting iperf3 client..."
    $IPERF3_CMD > $LOG_FILE 2>&1 &
    IPERF_PID=$!
    LAST_START=$(date +%s)
}

# Function to check if it's time to restart iperf3 based on duration
should_restart_iperf() {
    local current_time=$(date +%s)
    local elapsed=$(( current_time - LAST_START ))

    # Check if the elapsed time since last start is greater than duration plus a buffer
    if (( elapsed > DURATION + 5 )); then  # 5-second pause between runs
        return 0 # True, should restart
    else
        return 1 # False, should not restart
    fi
}

# Function to extract and report the last recorded speed from iperf3 output
report_speed() {
    # Check for lines containing "Mbits/sec" and ensure the line has enough fields before parsing
    SPEED=$(awk '/Mbits\/sec/ && NF >= 3 {print $(NF-1), $NF}' $LOG_FILE | tail -n 3)
    if [ -n "$SPEED" ]; then
        echo "Current Speed: $SPEED"
    else
        echo "Unable to determine current speed. Check iperf3 output in $LOG_FILE for details."
    fi
}

# Initial start of iperf3
start_iperf

# Main loop to manage iperf3 execution and report speed
while true; do
    sleep 1 # Adjust sleep to 5 seconds for pause between tests

    if should_restart_iperf; then
        echo "iperf3 has completed or is unresponsive. Restarting..."
        start_iperf
    fi
    report_speed
done
