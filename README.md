# SSH-Infiltrator

## Overview

**SSH-Infiltrator** is an SSH automation tool combined with a server monitoring script. It enables users to connect to remote servers securely, execute administrative tasks, and monitor system resources such as CPU usage, memory usage, disk space, and network statistics. This project is designed for educational purposes to demonstrate practical applications of Bash scripting in system administration.

### Features

- **SSH Connection Management**: Connect to remote servers using SSH with password authentication.
- **Command Execution**: Execute various commands on the remote server, including:
  - Rebooting and shutting down the server.
  - Managing files and directories (create, delete, list).
  - Opening applications like Notepad on the remote server.
- **System Monitoring**: Continuously monitor and display:
  - CPU usage
  - Memory usage
  - Disk space
  - Network statistics
- **Logging**: Maintain logs of executed commands and actions for auditing and debugging.
- **Input Validation**: Validate user inputs and handle errors gracefully.
- **Multi-Terminal Support**: Launch a separate terminal window for real-time monitoring.
- **Task Scheduling**: Schedule tasks using cron jobs for automated execution.
- **Backup and Reporting**: Backup files from the remote server and generate comprehensive system reports.

> **Note**: This project is still in development, and some features may not work as expected. Your feedback and contributions are welcome!

## Prerequisites

Before running the scripts, ensure you have the following installed:

- **Operating System**: Linux or macOS (Windows users can use WSL).
- **sshpass**: A command-line tool for non-interactive SSH password authentication. Install it using:
  ```bash
  sudo apt-get install sshpass   # For Debian/Ubuntu
  ```
- **Terminal Emulator**: Ensure you have a terminal emulator like `gnome-terminal`, `konsole`, or any preferred terminal installed.

## Installation

1. **Clone the repository** to your local machine:
   ```bash
   git clone <repository_url>
   cd <repository_name>
   ```

2. **Make the scripts executable**:
   ```bash
   chmod +x main_control.sh server_monitoring.sh
   ```

3. **Run the Setup Script**: (Optional, if you need to install additional dependencies)
   ```bash
   ./setup.sh
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
   After successful login, the following options will be displayed:
   - Reboot Server
   - Shutdown Server
   - Open Notepad
   - List Files
   - Slow Down System
   - Monitor System Resources
   - Stress Test
   - Backup Files
   - Update System
   - Delete Directory
   - Custom SSH Command
   - Multi-Server Management
   - Schedule Task
   - Generate System Report
   - Exit

4. **Monitoring Tool**:
   The server monitoring tool will open in a new terminal and continuously display:
   - CPU Usage: Current CPU load percentage.
   - Memory Usage: Free and total physical memory.
   - Disk Usage: Size and free space of each logical disk.
   - Network Statistics: Current network statistics.

## Logging

All actions performed by the main script and monitoring tool are logged in `ssh_tool_log.txt` and `server_monitoring_log.txt`, respectively. Review these logs for auditing and troubleshooting purposes.

## Error Handling

The tool includes basic error handling for input validation, connection issues, and command execution failures. Users are informed about any errors encountered during execution.

## Important Notes

- **Use with Caution**: This tool allows powerful commands like shutdown and delete, which can disrupt services or lead to data loss. Always double-check inputs.
- **Security**: Storing passwords in scripts or passing them as arguments can pose security risks. Consider using SSH keys for authentication in production environments.

## Contributing

Contributions are welcome! If you have suggestions, improvements, or bug fixes, please submit a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
