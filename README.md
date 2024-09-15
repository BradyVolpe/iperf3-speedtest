
# iperf3 Network Testing Script

## Overview

This repository contains scripts for running continuous upstream and downstream speed tests using `iperf3` on a client-server setup. The scripts are designed for use with MacOS on the client side and Ubuntu on the server side. The client script generates traffic to test network performance in both directions (upstream and downstream), and the server listens for these tests.

## Server Script

The server script (`iperf3_server.sh`) starts multiple `iperf3` server instances on ports 5201 to 5210 to handle multiple incoming sessions. It checks for any running instances of `iperf3`, kills them, and starts new server instances.

### Usage

1. Copy the server script to your Ubuntu server.
2. Make the script executable:
    ```bash
    chmod +x iperf3_server.sh
    ```
3. Run the script:
    ```bash
    ./iperf3_server.sh
    ```

## Client Script

The client script (`iperf3_client.sh`) runs multiple `iperf3` tests from a MacOS client, sending traffic to a remote server and receiving traffic from it. The script supports up to five different network interfaces, with the ability to specify the IP, direction (upstream or downstream), and bitrate for each interface.

### Changes

The following changes have been made to the client script:

1. **Fixed-Length Speed History**: The script now maintains a maximum length of 10 entries in the speed history to prevent indefinite growth.
2. **Timestamp and Interface Display**: Each speed entry now includes the time, interface, and direction (upstream or downstream).
3. **Clearing Duplicated Output**: The script clears the terminal screen before each graph update to avoid duplicating lines and causing cluttered output.

### Usage

1. Copy the client script to your MacOS client machine.
2. Make the script executable:
    ```bash
    chmod +x iperf3_client.sh
    ```
3. Run the script:
    ```bash
    ./iperf3_client.sh
    ```

### Example Output

```
Time-Series Graph (Mbps)
Time                     | Interface | Direction  | Data Rate
-------------------------|-----------|------------|--------------------------------------------------
2024-09-13 20:27:25 | 10.2.4.126 | downstream | 50.0 Mbps | ##
2024-09-13 20:27:30 | 10.2.4.131 | upstream   | 274 Mbps  | #############
2024-09-13 20:27:35 | 10.2.4.126 | downstream | 256 Mbps  | ############
...
```

### Key Parameters

- **INTERFACE1_IP**: The IP address of the first interface.
- **INTERFACE1_MODE**: The mode for the first interface (`t` for transmit, `r` for receive).
- **INTERFACE1_RATE**: The data rate in Mbps for the first interface.
- **INTERFACE1_ACTIVE**: Set to `yes` if this interface is active.
- **INTERFACE1_PORT**: The port number for the first interface.

Repeat for up to 5 interfaces as required.

### Additional Features

- **Automatic Restart**: The script automatically restarts `iperf3` tests if the server becomes unresponsive.
- **Dynamic Graph Updates**: Displays a time-series ASCII graph with the latest speed data, updated every 5 seconds.

## Requirements

- `iperf3` installed on both the client and server machines.
- `awk` for processing the output.
- Bash shell for running the scripts.

## Installation

1. Install `iperf3`:
    ```bash
    sudo apt-get install iperf3  # For Ubuntu
    brew install iperf3          # For MacOS
    ```

## Contributing

Feel free to contribute to the project by creating pull requests or submitting issues.

## License

This project is licensed under the MIT License.
