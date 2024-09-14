# iPerf3 Automated Server and Client Scripts

This repository contains two bash scripts for automating the setup and operation of an `iperf3` server and client on two different servers. The scripts are designed to ensure continuous network performance testing by managing `iperf3` processes and automatically restarting them if necessary.

## Overview

1. **Server Script (`iperf3_server.sh`)**: Runs an `iperf3` server, continuously checks its status, and restarts the server if it stops or becomes unresponsive.
2. **Client Script (`iperf3_client.sh`)**: Runs an `iperf3` client to generate upstream and downstream UDP traffic, monitors its performance, and restarts the client test periodically based on a specified duration.

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

The `iperf3_server.sh` script should be run on **Server 1** to start and manage the `iperf3` server.

```bash
./iperf3_server.sh
```

This script will:
- Stop any existing `iperf3` server instances.
- Start a new `iperf3` server in the background.
- Check every 10 minutes to ensure the server is running and responsive.
- Restart the server if it is unresponsive or not running.

### 2. Running the Client Script

The `iperf3_client.sh` script should be run on **Server 2** to start and manage the `iperf3` client.

```bash
./iperf3_client.sh
```

This script will:
- Start an `iperf3` client to send UDP traffic to the remote server (`10.1.0.150`).
- Monitor the performance and report the current speed.
- Restart the client periodically based on the specified duration (20 seconds in this example).

### Configuration

#### Server Script (`iperf3_server.sh`)

- **`IPERF3_PORT`**: The port on which the `iperf3` server listens. Default is `5201`.
- **`IPERF3_SERVER_IP`**: The IP address of the server (default is `localhost`).

#### Client Script (`iperf3_client.sh`)

- **`REMOTE_SERVER`**: IP address of the remote `iperf3` server. Set to `10.1.0.150` by default.
- **`BITRATE`**: Desired bandwidth for UDP traffic. Default is `500M` (500 Mbps).
- **`DURATION`**: Duration of each `iperf3` run in seconds. Set to `20` seconds by default.
- **`LOG_FILE`**: Path to the log file where `iperf3` output is stored.

### Future Enhancements

The following features will be added in future updates:

- Support for multiple ports (`5201` and `5202`) on the server side.
- Management of multiple interfaces or IP addresses on the client side.

## Logs

- **Server Log**: `/tmp/iperf3_server_log.txt` - Contains output and errors for the `iperf3` server.
- **Client Log**: `/tmp/iperf3_log.txt` - Contains output and performance data for the `iperf3` client.

## Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Contributions are welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
