#!/bin/bash

# Variables
LOG_FILE="/tmp/iperf3_server_log.txt"
IPERF3_PORT=5201 # Default port used by iperf3, adjust if different
IPERF3_SERVER_IP="localhost" # Use the server IP or localhost

# Function to start iperf3 server
start_iperf_server() {
    echo "Attempting to stop any existing iperf3 server instances..."
    pkill -f "iperf3 -s"
    sleep 2 # Give it a moment to terminate

    echo "Starting iperf3 server..."
    iperf3 -sD > "$LOG_FILE" 2>&1
    echo "iperf3 server started."
}

# Function to perform a lightweight iperf3 client test to check server responsiveness
test_iperf3_server() {
    # Perform a quick test; adjust parameters as needed
    iperf3 -c $IPERF3_SERVER_IP -p $IPERF3_PORT -t 2
}

# Function to check if iperf3 server is running and accepting connections
check_iperf_server() {
    if pgrep -x "iperf3" > /dev/null; then
        echo "iperf3 process is running."
        
        # Perform a real client test instead of just checking port openness
        if test_iperf3_server; then
            echo "iperf3 server is functioning correctly."
        else
            echo "iperf3 server may be running but is not responding properly. Restarting..."
            start_iperf_server
        fi
    else
        echo "iperf3 server process not found. Starting iperf3..."
        start_iperf_server
    fi
}

# Initial start
start_iperf_server

# Main loop
while true; do
    check_iperf_server
    sleep 600 # Check interval
done