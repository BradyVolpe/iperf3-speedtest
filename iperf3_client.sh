#!/bin/bash

# Define up to 5 interfaces
INTERFACE1_IP="10.2.4.126"
INTERFACE1_MODE="r"   # t for transmit, r for receive
INTERFACE1_RATE="100" # Data rate in Mbps
INTERFACE1_ACTIVE="yes" # yes if this interface is active
INTERFACE1_PORT=5201  # Port number for interface 1

INTERFACE2_IP="10.2.4.131"
INTERFACE2_MODE="t"   # t for transmit, r for receive
INTERFACE2_RATE="50" # Data rate in Mbps
INTERFACE2_ACTIVE="yes" # yes if this interface is active
INTERFACE2_PORT=5202  # Port number for interface 2

INTERFACE3_IP=""
INTERFACE3_MODE="t"   # t for transmit, r for receive
INTERFACE3_RATE="100" # Data rate in Mbps
INTERFACE3_ACTIVE="no" # yes if this interface is active
INTERFACE3_PORT=5203  # Port number for interface 3

INTERFACE4_IP=""
INTERFACE4_MODE="r"   # t for transmit, r for receive
INTERFACE4_RATE="200" # Data rate in Mbps
INTERFACE4_ACTIVE="no" # yes if this interface is active
INTERFACE4_PORT=5204  # Port number for interface 4

INTERFACE5_IP=""
INTERFACE5_MODE="t"   # t for transmit, r for receive
INTERFACE5_RATE="300" # Data rate in Mbps
INTERFACE5_ACTIVE="no" # yes if this interface is active
INTERFACE5_PORT=5205  # Port number for interface 5

REMOTE_SERVER="10.1.0.150"
DURATION=20 # Set duration of each iperf3 run to 20 seconds
LOG_FILE="/tmp/iperf3_log.txt"

# Function to start iperf3 for a specific interface
start_iperf() {
    local ip=$1
    local mode=$2
    local rate=$3
    local active=$4
    local port=$5

    if [ "$active" == "yes" ]; then
        if [ "$mode" == "t" ]; then
            # Transmit mode
            echo "Starting iperf3 client on $ip for transmitting at ${rate} Mbps on port $port..."
            iperf3 --udp --client $REMOTE_SERVER --bitrate "${rate}"M -t $DURATION -B "$ip" -p "$port" > $LOG_FILE 2>&1 &
        elif [ "$mode" == "r" ]; then
            # Receive mode include -R option
            echo "Starting iperf3 client on $ip for receiving at ${rate} Mbps on port $port..."
            iperf3 --udp --client $REMOTE_SERVER --bitrate "${rate}"M -t $DURATION -B "$ip" -p "$port" -R > $LOG_FILE 2>&1 &
        fi
    fi
}

# Function to extract and report the last recorded speed from iperf3 output
report_speed() {
    SPEED=$(awk '/Mbits\/sec/ && NF >= 3 {print $(NF-1), $NF}' $LOG_FILE | tail -n 3)
    if [ -n "$SPEED" ]; then
        echo "Current Speed: $SPEED"
    else
        echo "Unable to determine current speed. Check iperf3 output in $LOG_FILE for details."
    fi
}

# Start iperf3 for each active interface
start_iperf "$INTERFACE1_IP" "$INTERFACE1_MODE" "$INTERFACE1_RATE" "$INTERFACE1_ACTIVE" "$INTERFACE1_PORT"
start_iperf "$INTERFACE2_IP" "$INTERFACE2_MODE" "$INTERFACE2_RATE" "$INTERFACE2_ACTIVE" "$INTERFACE2_PORT"
start_iperf "$INTERFACE3_IP" "$INTERFACE3_MODE" "$INTERFACE3_RATE" "$INTERFACE3_ACTIVE" "$INTERFACE3_PORT"
start_iperf "$INTERFACE4_IP" "$INTERFACE4_MODE" "$INTERFACE4_RATE" "$INTERFACE4_ACTIVE" "$INTERFACE4_PORT"
start_iperf "$INTERFACE5_IP" "$INTERFACE5_MODE" "$INTERFACE5_RATE" "$INTERFACE5_ACTIVE" "$INTERFACE5_PORT"

# Main loop to manage iperf3 execution and report speed
while true; do
    sleep 1 # Adjust sleep to 5 seconds for pause between tests

    report_speed

    # Restart iperf3 after the duration
    if [ "$(pgrep -x iperf3)" == "" ]; then
        echo "iperf3 has completed or is unresponsive. Restarting..."
        start_iperf "$INTERFACE1_IP" "$INTERFACE1_MODE" "$INTERFACE1_RATE" "$INTERFACE1_ACTIVE" "$INTERFACE1_PORT"
        start_iperf "$INTERFACE2_IP" "$INTERFACE2_MODE" "$INTERFACE2_RATE" "$INTERFACE2_ACTIVE" "$INTERFACE2_PORT"
        start_iperf "$INTERFACE3_IP" "$INTERFACE3_MODE" "$INTERFACE3_RATE" "$INTERFACE3_ACTIVE" "$INTERFACE3_PORT"
        start_iperf "$INTERFACE4_IP" "$INTERFACE4_MODE" "$INTERFACE4_RATE" "$INTERFACE4_ACTIVE" "$INTERFACE4_PORT"
        start_iperf "$INTERFACE5_IP" "$INTERFACE5_MODE" "$INTERFACE5_RATE" "$INTERFACE5_ACTIVE" "$INTERFACE5_PORT"
    fi
done
