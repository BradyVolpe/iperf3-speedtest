#!/bin/bash

# Variables
LOG_DIR="/tmp"
IPERF3_PORT_START=5201  # Start port for iperf3 servers
IPERF3_PORT_END=5210    # End port for iperf3 servers
IPERF3_SERVER_IP="localhost" # Use the server IP or localhost

# Function to start iperf3 server on multiple ports
start_iperf_servers() {
    echo "Attempting to stop any existing iperf3 server instances..."
    pkill -f "iperf3 -s"
    sleep 2 # Give it a moment to terminate

    # Loop to start multiple iperf3 servers on different ports
    for port in $(seq $IPERF3_PORT_START $IPERF3_PORT_END); do
        LOG_FILE="$LOG_DIR/iperf3_server_log_$port.txt"
        echo "Starting iperf3 server on port $port..."
        iperf3 -s -p $port -D > "$LOG_FILE" 2>&1
        echo "iperf3 server started on port $port."
    done
}

# Function to perform a lightweight iperf3 client test to check server responsiveness
test_iperf3_server() {
    local port=$1
    # Perform a quick test; adjust parameters as needed
    iperf3 -c $IPERF3_SERVER_IP -p $port -t 2
}

# Function to check if iperf3 servers are running and accepting connections
check_iperf_servers() {
    for port in $(seq $IPERF3_PORT_START $IPERF3_PORT_END); do
        if pgrep -x "iperf3" > /dev/null; then
            echo "iperf3 process is running on port $port."
            
            # Perform a real client test instead of just checking port openness
            if test_iperf3_server $port; then
                echo "iperf3 server on port $port is functioning correctly."
            else
                echo "iperf3 server on port $port may be running but is not responding properly. Restarting..."
                start_iperf_servers
                break
            fi
        else
            echo "iperf3 server process not found on port $port. Starting iperf3..."
            start_iperf_servers
            break
        fi
    done
}

# Initial start of all iperf3 servers
start_iperf_servers

# Main loop
while true; do
    check_iperf_servers
    sleep 600 # Check interval
done
