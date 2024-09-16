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
LOG_FILE="/tmp/iperf3_log.txt"
MAX_HISTORY_LENGTH=10 # Maximum number of entries in the speed history

# Function to start iperf3 for a specific interface
start_iperf() {
    local ip=$1
    local mode=$2
    local rate=$3
    local active=$4
    local port=$5
    local direction

    if [ "$mode" == "t" ]; then
        direction="upstream"
    else
        direction="downstream"
    fi

    if [ "$active" == "yes" ]; then
        if [ "$mode" == "t" ]; then
            # Transmit mode
            echo "Starting iperf3 client on $ip for transmitting at ${rate} Mbps on port $port ($direction)..."
            iperf3 --udp --client $REMOTE_SERVER --bitrate ${rate}M -t $DURATION -B $ip -p $port > $LOG_FILE 2>&1 &
        elif [ "$mode" == "r" ]; then
            # Receive mode
            echo "Starting iperf3 client on $ip for receiving at ${rate} Mbps on port $port ($direction)..."
            iperf3 --udp --client $REMOTE_SERVER --bitrate ${rate}M -t $DURATION -B $ip -p $port -R > $LOG_FILE 2>&1 &
        fi
    fi
}

# Function to extract and report the last recorded speed from iperf3 output
report_speed() {
    local current_time=$(date "+%Y-%m-%d %H:%M:%S")

    # Extract the last recorded speed from iperf3 output using awk
    SPEED=$(awk '/[MG]bits\/sec/ {for(i=1;i<=NF;i++) if($i ~ /[MG]bits\/sec/) print $(i-1), $i}' $LOG_FILE | tail -n 1)

    if [[ $SPEED =~ ^[0-9]+\.?[0-9]*\ [MG]bits\/sec$ ]]; then
        echo "[$current_time] Current Speed: $SPEED"
    else
        echo "[$current_time] Unable to determine current speed. Check iperf3 output in $LOG_FILE for details."
    fi
}

# Function to display ASCII graph
display_ascii_graph() {
    local speed_values=("$@")
    local max_speed=1000 # Adjust the max speed for scale

    # Clear the screen before displaying the new graph
    clear

    echo "Time-Series Graph (Mbps)"
    echo "Time                     | Interface | Direction  | Data Rate"
    echo "-------------------------|-----------|------------|--------------------------------------------------"

    for entry in "${speed_values[@]}"; do
        local time_stamp=$(echo $entry | awk '{print $1, $2}')
        local interface=$(echo $entry | awk '{print $3}')
        local direction=$(echo $entry | awk '{print $4}')
        local rate=$(echo $entry | awk '{print $5}')

        # Check if rate is a valid number
        if [[ $rate =~ ^[0-9]+\.?[0-9]*$ ]]; then
            # Convert rate to integer for graph scaling
            local num_hashes=$(awk -v rate="$rate" -v max_speed="$max_speed" 'BEGIN {print int((rate * 50) / max_speed)}')
            local graph_bar=""

            for ((i=0; i<num_hashes; i++)); do
                graph_bar+="#"
            done

            echo "$time_stamp | $interface | $direction | $rate Mbps | $graph_bar"
        fi
    done
}

# Start iperf3 for each active interface
start_all_iperfs() {
    start_iperf "$INTERFACE1_IP" "$INTERFACE1_MODE" "$INTERFACE1_RATE" "$INTERFACE1_ACTIVE" "$INTERFACE1_PORT"
    start_iperf "$INTERFACE2_IP" "$INTERFACE2_MODE" "$INTERFACE2_RATE" "$INTERFACE2_ACTIVE" "$INTERFACE2_PORT"
    start_iperf "$INTERFACE3_IP" "$INTERFACE3_MODE" "$INTERFACE3_RATE" "$INTERFACE3_ACTIVE" "$INTERFACE3_PORT"
    start_iperf "$INTERFACE4_IP" "$INTERFACE4_MODE" "$INTERFACE4_RATE" "$INTERFACE4_ACTIVE" "$INTERFACE4_PORT"
    start_iperf "$INTERFACE5_IP" "$INTERFACE5_MODE" "$INTERFACE5_RATE" "$INTERFACE5_ACTIVE" "$INTERFACE5_PORT"
}

# Initialize array for storing speed data with timestamps, interface, and direction
declare -a speed_history=()

# Main loop to manage iperf3 execution and report speed
while true; do
    # Start all iperf3 tests continuously
    start_all_iperfs

    # Wait for the duration of the iperf3 run to complete
    sleep 1

    report_speed
    speed=$(awk '/[MG]bits\/sec/ {for(i=1;i<=NF;i++) if($i ~ /[MG]bits\/sec/) print $(i-1)}' $LOG_FILE | tail -n 1)
    current_time=$(date "+%Y-%m-%d %H:%M:%S")

    # Determine the interface and direction for logging
    if [ "$INTERFACE1_ACTIVE" == "yes" ]; then
        direction="upstream"
        [ "$INTERFACE1_MODE" == "r" ] && direction="downstream"
        speed_history+=("$current_time $INTERFACE1_IP $direction $speed")
    fi
    if [ "$INTERFACE2_ACTIVE" == "yes" ]; then
        direction="upstream"
        [ "$INTERFACE2_MODE" == "r" ] && direction="downstream"
        speed_history+=("$current_time $INTERFACE2_IP $direction $speed")
    fi
    # Repeat for remaining interfaces as needed...

    # Limit the history length to the maximum number of entries
    if [ "${#speed_history[@]}" -gt "$MAX_HISTORY_LENGTH" ]; then
        speed_history=("${speed_history[@]:1}") # Remove the oldest entry
    fi

    # Display the ASCII graph for the speed
    display_ascii_graph "${speed_history[@]}"

    # Clear the log file for the next test run
    echo "" > $LOG_FILE
done
