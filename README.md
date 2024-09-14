# iPerf3 Automated Server and Client Scripts

This repository contains two bash scripts for automating the setup and operation of an `iperf3` server and client on two different servers. The scripts are designed to ensure continuous network performance testing by managing `iperf3` processes and automatically restarting them if necessary.

## Overview

1. **Server Script (`iperf3_server.sh`)**: Runs multiple instances of an `iperf3` server on different ports, continuously checks their status, and restarts them if they stop or become unresponsive.
2. **Client Script (`iperf3_client.sh`)**: Runs multiple `iperf3` clients for different interfaces, each configured to either transmit or receive UDP traffic, and monitors their performance.

## Requirements

- Two servers: 
  - **Server 1**: Runs the `iperf3` server script.
  - **Server 2**: Runs the `iperf3` client script.
- `iperf3` must be installed on both servers.
- Bash shell environment for running the scripts.

## Installation

1. **Install `iperf3` on both servers:**

   On Ubuntu/Debian:
   ```bash
   sudo apt update
   sudo apt install iperf3
   ```

   On CentOS/RHEL:
   ```bash
   sudo yum install iperf3
   ```

2. **Clone this repository to both servers:**

   ```bash
   git clone https://github.com/yourusername/iperf3-scripts.git
   cd iperf3-scripts
   ```

3. **Make the scripts executable:**

   ```bash
   chmod +x iperf3_server.sh
   chmod +x iperf3_client.sh
   ```

## Usage

### 1. Running the Server Script

The `iperf3_server.sh` script should be run on **Server 1** to start and manage multiple `iperf3` server instances on ports 5201 to 5210.

```bash
./iperf3_server.sh
```

This script will:
- Stop any existing `iperf3` server instances.
- Start new `iperf3` server instances on ports 5201 to 5210 in the background.
- Check every 10 minutes to ensure all servers are running and responsive.
- Restart any server instance if it is unresponsive or not running.

### 2. Running the Client Script

The `iperf3_client.sh` script should be run on **Server 2** to start and manage the `iperf3` clients for each configured interface.

```bash
./iperf3_client.sh
```

This script will:
- Start an `iperf3` client for each active interface to either transmit or receive UDP traffic to/from the remote server (`10.1.0.150`).
- Monitor the performance and report the current speed.
- Restart the client periodically based on the specified duration (20 seconds in this example).

### Configuration

#### Server Script (`iperf3_server.sh`)

- **`IPERF3_PORT_START`**: The starting port number for the `iperf3` servers (default is `5201`).
- **`IPERF3_PORT_END`**: The ending port number for the `iperf3` servers (default is `5210`).
- **`IPERF3_SERVER_IP`**: The IP address of the server (default is `localhost`).

#### Client Script (`iperf3_client.sh`)

- **Interface Configuration:**
  - Up to 5 interfaces can be configured with the following variables:
    - **`INTERFACEX_IP`**: IP address for interface X (e.g., `INTERFACE1_IP`).
    - **`INTERFACEX_MODE`**: Mode for interface X (`t` for transmit, `r` for receive).
    - **`INTERFACEX_RATE`**: Data rate in Mbps for interface X.
    - **`INTERFACEX_ACTIVE`**: Set to `yes` if the interface is active, otherwise `no`.
    - **`INTERFACEX_PORT`**: Port number for interface X (e.g., `5201` for `INTERFACE1_PORT`).
- **`REMOTE_SERVER`**: IP address of the remote `iperf3` server. Set to `10.1.0.150` by default.
- **`DURATION`**: Duration of each `iperf3` run in seconds. Set to `20` seconds by default.
- **`LOG_FILE`**: Path to the log file where `iperf3` output is stored.

### Example Commands

- **To start a client for receiving UDP traffic:**

  ```bash
  iperf3 -c 10.1.0.150 -u -R -b 1000M -p 5202 -B 10.2.4.131
  ```

  - This command sets up the client to receive UDP traffic from the server at `10.1.0.150` on port `5202` with a bandwidth of `1000 Mbps` on interface `10.2.4.131`.

### Future Enhancements

The following features will be added in future updates:

- Support for dynamic port allocation and management.
- Improved logging and error handling.

## Logs

- **Server Log**: `/tmp/iperf3_server_log_PORT.txt` - Contains output and errors for each `iperf3` server instance on the specified port.
- **Client Log**: `/tmp/iperf3_log.txt` - Contains output and performance data for the `iperf3` client.

## Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
