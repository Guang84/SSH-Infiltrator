#!/bin/bash

# Function to log messages with different log levels
log_message() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] - $message" >> "ssh_tool_log.txt"
}

# Function to display help
show_help() {
    echo "Usage: $0"
    echo "SSH Infiltrator Tool for Monitoring Servers"
    echo "Options:"
    echo "  -h, --help          Display this help message"
    echo "  -v, --version       Show version information"
    echo "  -i, --ip <IP>       Set the server IP address"
    echo "  -u, --username <USER>   Set the username"
    echo "  -p, --password <PASS>   Set the password (prompted if not provided)"
    echo "  -c, --command <CMD>     Execute a custom command on the server"
    echo "  --interactive        Start an interactive SSH session"
    echo "  --normal             Run in normal mode (monitoring functions)"
    exit 0
}

# Function to display banner
display_banner() {
    echo "============================="
    echo "   SSH Infiltrator Tool v1.0   "
    echo "============================="
    echo
}

# Function to check if a string is a valid IP address
is_valid_ip() {
    local ip=$1
    local stat=1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        stat=0
    fi
    return $stat
}

# Function to execute SSH commands
execute_ssh_command() {
    local command=$1
    local output
    output=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$SERVER_IP" "$command" 2>&1)

    # Handle output based on error messages
    case "$output" in
        *"Permission denied"*)
            log_message "ERROR" "Permission denied while trying to connect."
            echo "Permission denied."
            return 1
            ;;
        *"Connection refused"*)
            log_message "ERROR" "Connection refused. Check server status."
            echo "Connection refused."
            return 1
            ;;
        *"Could not resolve hostname"*)
            log_message "ERROR" "Could not resolve hostname. Check the IP address."
            echo "Could not resolve hostname."
            return 1
            ;;
        *)
            log_message "INFO" "Executed command: $command"
            echo "$output"
            return 0
            ;;
    esac
}

# Function to check SSH login
check_login() {
    if execute_ssh_command "echo 'Login Successful'"; then
        return 0  # Successful login
    else
        echo "Login failed."
        log_message "ERROR" "Login failed."
        return 1
    fi
}

# Function to start an interactive SSH session
start_interactive_session() {
    echo "Starting interactive SSH session..."
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$SERVER_IP" -t
}

# Function to monitor CPU usage
monitor_cpu() {
    echo "===== CPU Usage ====="
    if [[ "$OS" == "Windows" ]]; then
        execute_ssh_command "wmic cpu get loadpercentage"
    else
        execute_ssh_command "top -b -n1 | grep 'Cpu(s)'"
    fi
}

# Function to monitor Memory usage
monitor_memory() {
    echo "===== Memory Usage ====="
    if [[ "$OS" == "Windows" ]]; then
        execute_ssh_command "wmic OS get FreePhysicalMemory,TotalVisibleMemorySize"
    else
        execute_ssh_command "free -m"
    fi
}

# Function to monitor Disk usage
monitor_disk() {
    echo "===== Disk Usage ====="
    if [[ "$OS" == "Windows" ]]; then
        execute_ssh_command "wmic logicaldisk get size,freespace,caption"
    else
        execute_ssh_command "df -h"
    fi
}

# Function to monitor Network usage
monitor_network() {
    echo "===== Network Statistics ====="
    if [[ "$OS" == "Windows" ]]; then
        execute_ssh_command "netstat -e"
    else
        execute_ssh_command "ifconfig"
    fi
}

# Function to check if a service is running
check_service_status() {
    local service_name=$1
    echo "===== Checking Status of $service_name ====="
    if [[ "$OS" == "Windows" ]]; then
        execute_ssh_command "sc query $service_name"
    else
        execute_ssh_command "systemctl is-active $service_name"
    fi
}

# Function to monitor disk space and alert if usage exceeds threshold
monitor_disk_space() {
    echo "===== Disk Space Monitoring ====="
    THRESHOLD=80  # Set threshold percentage
    if [[ "$OS" == "Windows" ]]; then
        output=$(execute_ssh_command "Get-PSDrive -PSProvider FileSystem | Select-Object Used,Free, @{Name='UsedPercentage';Expression={([math]::round(($_.Used / ($_.Used + $_.Free)) * 100), 2)}}")
        while read -r line; do
            USAGE=$(echo "$line" | awk '{print $4}')  # Assuming UsedPercentage is the 4th field
            MOUNT_POINT=$(echo "$line" | awk '{print $1}')  # Adjust as necessary
            if (( $(echo "$USAGE > $THRESHOLD" | bc -l) )); then
                echo "Warning: Disk usage on $MOUNT_POINT is at ${USAGE}%"
                log_message "WARNING" "Disk usage on $MOUNT_POINT is at ${USAGE}%"
            fi
        done <<< "$output"
    else
        output=$(execute_ssh_command "df -h --output=pcent,target | grep -v 'Use%' | sed 's/%//'")
        while read -r line; do
            USAGE=$(echo "$line" | awk '{print $1}')
            MOUNT_POINT=$(echo "$line" | awk '{print $2}')
            if (( USAGE > THRESHOLD )); then
                echo "Warning: Disk usage on $MOUNT_POINT is at ${USAGE}%"
                log_message "WARNING" "Disk usage on $MOUNT_POINT is at ${USAGE}%"
            fi
        done <<< "$output"
    fi
}

# Function to execute a custom command on the server
execute_custom_command() {
    read -p "Enter the command to execute on the server: " CUSTOM_COMMAND
    echo "Executing command: $CUSTOM_COMMAND"
    execute_ssh_command "$CUSTOM_COMMAND"
}

# Function to run monitoring tasks in normal mode automatically
run_normal_mode_auto() {
    echo "Running in normal mode. Automatic monitoring will start..."

    # Handle CTRL+C gracefully
    trap 'echo "Exiting monitoring."; exit' INT

    while true; do
        monitor_cpu
        monitor_memory
        monitor_disk
        monitor_network
        monitor_disk_space
        echo "Press [CTRL+C] to stop monitoring."
        sleep 10  # Wait before the next round of monitoring
    done
}

# Function to interactively send commands to the terminal
interactive_terminal() {
    echo "Interactive Terminal Mode. You can enter any command."
    while true; do
        read -p "Enter your command (or 'exit' to quit): " USER_COMMAND
        if [[ "$USER_COMMAND" == "exit" ]]; then
            echo "Exiting interactive terminal."
            break
        else
            execute_ssh_command "$USER_COMMAND"
        fi
    done
}

# Input Prompt with argument parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        -v|--version) echo "SSH Infiltrator Tool v1.0" && exit 0 ;;
        -i|--ip) SERVER_IP="$2"; shift ;;
        -u|--username) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -c|--command) CUSTOM_COMMAND="$2"; shift ;;
        --interactive) INTERACTIVE_MODE=true ;;
        --normal) NORMAL_MODE=true ;;
        *) echo "Unknown option: $1" && show_help ;;
    esac
    shift
done

# Display the banner at the start
display_banner

# Prompt for missing inputs
if [[ -z "$SERVER_IP" ]]; then
    read -p "Enter the Server IP: " SERVER_IP
fi
if [[ -z "$USERNAME" ]]; then
    read -p "Enter the Username: " USERNAME
fi
if [[ -z "$PASSWORD" ]]; then
    read -s -p "Enter the Password: " PASSWORD
    echo  # Newline after password input
fi

# Validate IP address format
if ! is_valid_ip "$SERVER_IP"; then
    echo "Invalid IP address format. Please provide a valid IP."
    exit 1
fi

# Check SSH login
if ! check_login; then
    exit 1  # Exit if login fails
fi

# Execute based on selected mode
if [[ "$NORMAL_MODE" == true ]]; then
    run_normal_mode_auto
elif [[ "$INTERACTIVE_MODE" == true ]]; then
    start_interactive_session
elif [[ -n "$CUSTOM_COMMAND" ]]; then
    execute_custom_command
else
    echo "No mode selected. Please use --normal or --interactive."
    exit 1
fi
