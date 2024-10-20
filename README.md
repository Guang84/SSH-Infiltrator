# SSH-Infiltrator

# SSH Automation and Server Monitoring Tool

## Overview

This project is an SSH automation tool combined with a server monitoring script. It allows users to connect to remote servers securely, execute various administrative tasks, and monitor system resources such as CPU usage, memory usage, disk space, and network statistics.

### Features

- **SSH Connection Management**: Connect to remote servers using SSH with password authentication.
- **Command Execution**: Execute commands on the remote server, including system management tasks like rebooting and shutting down.
- **System Monitoring**: Monitor CPU, memory, disk, and network usage continuously.
- **Logging**: Maintain logs of executed commands and actions for auditing and debugging.
- **Input Validation**: Validate user inputs and handle errors gracefully.
- **Multi-Terminal Support**: Launch a separate terminal window for monitoring.

> **Note**: Some features may not work correctly as expected, and the project is still in development. Your feedback and contributions are welcome!

## Prerequisites

Before running the scripts, ensure you have the following installed:

- **Linux or MacOS** (Windows users can use WSL)
- **sshpass**: A command-line tool for non-interactive SSH password authentication. Install it using:

  ```bash
  sudo apt-get install sshpass   # For Debian/Ubuntu
  ```

- **Terminal Emulator**: Ensure you have a terminal emulator like `gnome-terminal`, `konsole`, or any preferred terminal installed.

## Installation

1. Clone the repository to your local machine:

   ```bash
   git clone <repository_url>
   cd <repository_name>
   ```

2. Make the scripts executable:

   ```bash
   chmod +x main_control.sh server_monitoring.sh
   ```

## Usage

1. **Run the Main Control Script**:

   To start using the tool, execute the main control script:

   ```bash
   ./main_control.sh
   ```

2. **Input Prompts**:

   You will be prompted to enter the following:

   - **Server IP**: The IP address of the remote server you wish to connect to.
   - **Username**: The username for the SSH connection.
   - **Password**: The password for the SSH connection (input will be hidden).

3. **Menu Options**:

   After successful login, the following options will be displayed in a menu:

   - **Reboot Server**: Reboot the connected server.
   - **Shutdown Server**: Shut down the connected server.
   - **Open Notepad**: Open Notepad on the remote server.
   - **List Files**: List files in the `C:\` directory of the server.
   - **Slow Down System**: Create multiple files to simulate system slowdown.
   - **Monitor System Resources**: Continuously monitor CPU, memory, disk, and network usage.
   - **Stress Test**: Initiate a stress test on the server.
   - **Backup Files**: Back up files from the remote server to your local machine.
   - **Update System**: Update system packages on the remote server.
   - **Delete Directory**: Delete a specified directory on the server.
   - **Custom SSH Command**: Execute custom SSH commands interactively.
   - **Multi-Server Management**: Manage multiple servers listed in a text file.
   - **Schedule Task**: Schedule tasks using cron jobs.
   - **Generate System Report**: Generate a comprehensive system report.
   - **Exit**: Exit the tool.

4. **Monitoring Tool**:

   The server monitoring tool will open in a new terminal and continuously display:

   - **CPU Usage**: Current CPU load percentage.
   - **Memory Usage**: Free and total physical memory.
   - **Disk Usage**: Size and free space of each logical disk.
   - **Network Statistics**: Current network statistics.

## Logging

All actions performed by the main script and monitoring tool are logged in `ssh_tool_log.txt` and `server_monitoring_log.txt`, respectively. Review these logs for auditing and troubleshooting purposes.

## Error Handling

The tool includes basic error handling for input validation, connection issues, and command execution failures. The user is informed about any errors encountered during execution.

## Educational Purpose

This project serves as a practical demonstration of using Bash scripting for system administration and monitoring. It helps users understand SSH connections, command execution, and system resource monitoring in a Linux environment.

### Important Notes

- **Use with Caution**: This tool allows powerful commands like shutdown and delete, which can disrupt services or lead to data loss. Always double-check inputs.
- **Security**: Storing passwords in scripts or passing them as arguments can pose security risks. Consider using SSH keys for authentication in production environments.
