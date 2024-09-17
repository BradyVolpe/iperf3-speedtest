#!/bin/bash

# Define up to 5 interfaces
INTERFACE1_IP="10.2.4.126"
INTERFACE1_MODE="r"   # t for transmit (upstream), r for receive (downstream)
INTERFACE1_RATE="500" # Data rate in Mbps
INTERFACE1_ACTIVE="yes" # yes if this interface is active
INTERFACE1_PORT=5201  # Port number for interface 1

INTERFACE2_IP="10.2.4.131"
INTERFACE2_MODE="t"   # t for transmit (upstream), r for receive (downstream)
INTERFACE2_RATE="1500"  # Data rate in Mbps
INTERFACE2_ACTIVE="yes" # yes if this interface is active
INTERFACE2_PORT=5202  # Port number for interface 2

INTERFACE3_IP=""
INTERFACE3_MODE="t"   # t for transmit (upstream), r for receive (downstream)
INTERFACE3_RATE="100" # Data rate in Mbps
INTERFACE3_ACTIVE="no" # yes if this interface is active
INTERFACE3_PORT=5203  # Port number for interface 3

INTERFACE4_IP=""
INTERFACE4_MODE="r"   # t for transmit (upstream), r for receive (downstream)
INTERFACE4_RATE="200" # Data rate in Mbps
INTERFACE4_ACTIVE="no" # yes if this interface is active
INTERFACE4_PORT=5204  # Port number for interface 4

INTERFACE5_IP=""
INTERFACE5_MODE="t"   # t for transmit (upstream), r for receive (downstream)
INTERFACE5_RATE="300" # Data rate in Mbps
INTERFACE5_ACTIVE="no" # yes if this interface is active
INTERFACE5_PORT=5205  # Port number for interface 5

REMOTE_SERVER="10.1.0.150"
DURATION=300 # Set duration of each iperf3 run to 300 seconds

# Ensure the PATH includes directories where iperf3 might be located
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Function to start iperf3 for a specific interface
start_iperf() {
    local ip=$1
    local mode=$2
    local rate=$3
    local active=$4
    local port=$5
    local direction
    local log_file="/tmp/iperf3_log_$ip.txt"

    if [ "$mode" == "t" ]; then
        direction="upstream"
    else
        direction="downstream"
    fi

    if [ "$active" == "yes" ]; then
        if [ "$mode" == "t" ]; then
            # Transmit mode
            echo "Starting iperf3 client on $ip for transmitting at ${rate} Mbps on port $port ($direction)..." >&2
            iperf3 --udp --client $REMOTE_SERVER --bitrate "${rate}M" -t $DURATION -B $ip -p $port > "$log_file" 2>&1 &
            PIDS+=($!)
            INTERFACES+=("$ip")
        elif [ "$mode" == "r" ]; then
            # Receive mode
            echo "Starting iperf3 client on $ip for receiving at ${rate} Mbps on port $port ($direction)..." >&2
            iperf3 --udp --client $REMOTE_SERVER --bitrate "${rate}M" -t $DURATION -B $ip -p $port -R > "$log_file" 2>&1 &
            PIDS+=($!)
            INTERFACES+=("$ip")
        fi
    fi
}

# Start iperf3 for each active interface
start_all_iperfs() {
    PIDS=()
    INTERFACES=()

    if [ "$INTERFACE1_ACTIVE" == "yes" ]; then
        start_iperf "$INTERFACE1_IP" "$INTERFACE1_MODE" "$INTERFACE1_RATE" "$INTERFACE1_ACTIVE" "$INTERFACE1_PORT"
    fi

    if [ "$INTERFACE2_ACTIVE" == "yes" ]; then
        start_iperf "$INTERFACE2_IP" "$INTERFACE2_MODE" "$INTERFACE2_RATE" "$INTERFACE2_ACTIVE" "$INTERFACE2_PORT"
    fi

    if [ "$INTERFACE3_ACTIVE" == "yes" ]; then
        start_iperf "$INTERFACE3_IP" "$INTERFACE3_MODE" "$INTERFACE3_RATE" "$INTERFACE3_ACTIVE" "$INTERFACE3_PORT"
    fi

    if [ "$INTERFACE4_ACTIVE" == "yes" ]; then
        start_iperf "$INTERFACE4_IP" "$INTERFACE4_MODE" "$INTERFACE4_RATE" "$INTERFACE4_ACTIVE" "$INTERFACE4_PORT"
    fi

    if [ "$INTERFACE5_ACTIVE" == "yes" ]; then
        start_iperf "$INTERFACE5_IP" "$INTERFACE5_MODE" "$INTERFACE5_RATE" "$INTERFACE5_ACTIVE" "$INTERFACE5_PORT"
    fi
}

# Main loop to manage iperf3 execution and report status
while true; do
    # Start all iperf3 tests
    start_all_iperfs

    # Wait for all iperf3 processes to complete
    for i in "${!PIDS[@]}"; do
        PID=${PIDS[$i]}
        INTERFACE=${INTERFACES[$i]}
        if wait "$PID"; then
            echo "iperf3 test on interface $INTERFACE completed successfully."
        else
            EXIT_STATUS=$?
            echo "iperf3 test on interface $INTERFACE failed with exit status $EXIT_STATUS."
        fi
    done

    # Optional: Sleep before the next iteration
    sleep 1
done