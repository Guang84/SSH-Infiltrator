#!/bin/bash
VERSION="2024.10.22"

# Define color variables
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
NC='\033[0m' # No Color

# Required dependencies check
check_dependencies() {
    if ! command -v sshpass &> /dev/null; then
        echo "sshpass is required but not installed. Please install it."
        exit 1
    fi

    if ! command -v stress &> /dev/null && [[ "$OS_TYPE" != "Windows" ]]; then
        echo "stress is required for stress testing but not installed. Please install it."
        exit 1
    fi

    if ! command -v tar &> /dev/null; then
        echo "tar is required for backup but not installed. Please install it."
        exit 1
    fi

    if ! command -v uptime &> /dev/null; then
        echo "uptime is required for monitoring system resources but not installed. Please install it."
        exit 1
    fi
}

# Function to log messages with different log levels
log_message() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] - $message" >> "ssh_tool_log.txt"
}

# Function to display help
show_help() {
    echo "Usage: $0"
    echo "SSH Infiltrator Tool for Monitoring and Managing Servers"
    echo "Options:"
    echo "  -h, --help              Display this help message"
    echo "  -v, --version           Show version information"
    echo "  -i, --ip <IP>           Set the server IP address"
    echo "  -u, --username <USER>   Set the username"
    echo "  -p, --password <PASS>   Set the password (prompted if not provided)"
    echo "  -c, --command <CMD>     Execute a custom command on the server"
    echo "  --interactive           Start an interactive SSH session"
    echo "  --multi-server          Manage multiple servers in parallel"
    echo "  --schedule              Schedule a task"
    echo "  --generate-report       Generate a system report"
    echo "  --reboot                Reboot the server"
    echo "  --shutdown              Shutdown the server"
    echo "  --backup                Backup files"
    echo "  --stress-test           Run a stress test"
    echo "  --list-files            List files in a directory"
    echo "  --delete-dir            Delete a directory"
    echo "  --open-notepad          Open Notepad (Windows only)"
    echo "  --slow-down             Slow down the system (Linux only)"
    echo "  --monitor               Monitor system resources"
    exit 0
}

# Function to detect OS type
detect_os() {
    OS_INFO=$(ssh "$USERNAME@$SERVER_IP" "cat /etc/os-release || lsb_release -a || uname -s" 2>/dev/null)
    echo "Detected OS: $OS_INFO"
}

# Function to display banner
display_banner() {
    echo ""
    echo -e "${R}╔═════════════════════════════════════════════════════════════════════════════╗        ${NC}"
    echo -e "${R}                                                                                       ${NC}"
    echo -e "${R}    ║█████████████████████████║          ║█████████████████████║            ${NC} "
    echo -e "${Y}    ║█████████████████████████║          ║█████████████████████║            ${NC} " 
    echo -e "${R}    ║██████║                                     ║██████║                   ${NC} "
    echo -e "${G}    ║██████║                                     ║██████║                   ${NC} "
    echo -e "${Y}    ║██████║                                     ║██████║                   ${NC} "
    echo -e "${R}    ║█████████████████████████║                  ║██████║                   ${NC} "
    echo -e "${G}    ║█████████████████████████║                  ║██████║                   ${NC} "
    echo -e "${Y}                         ║█████║                  ║██████║                   ${NC} "
    echo -e "${R}                        ║█████║                  ║██████║                   ${NC} "
    echo -e "${G}                        ║█████║                  ║██████║                   ${NC} "
    echo -e "${Y}     ║████████████████████████║          ║█████████████████████║            ${NC} "
    echo -e "${R}     ║████████████████████████║          ║█████████████████████║            ${NC} "
    echo -e "${G}                         ${Y}NETWORK ANALYZER ${R}v$VERSION                 ${NC} "
    echo -e "${R}╚════════════════════════════════════════════════════════════════════════════╝         ${NC}"
    echo ""
}

# Bulk SSH command execution for performance improvement
bulk_execute_commands() {
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$SERVER_IP" "$1"
}

# Parallel execution for multiple servers
parallel_ssh_execution() {
    echo "Managing multiple servers in parallel..."
    cat "servers.csv" | while IFS=',' read -r ip user pass; do
        {
            SERVER_IP="$ip"
            USERNAME="$user"
            PASSWORD="$pass"
            check_login
        } &
    done
    wait  # Wait for all background processes to complete
}

# Validate IP address
is_valid_ip() {
    local ip=$1
    local stat=1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        stat=0
    fi
    return $stat
}

# Function to execute SSH commands
execute_ssh_command() {
    local command=$1
    output=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$SERVER_IP" "$command" 2>&1)
    if [[ $? -ne 0 ]]; then
        log_message "ERROR" "Command failed: $command. Output: $output"
        echo "Error executing command: $command"
        return 1
    else
        log_message "INFO" "Executed command: $command. Output: $output"
        echo "$output"
        return 0
    fi
}

# Slow Down System
slow_down_system() {
    echo "Slowing down the system..."
    execute_ssh_command "dd if=/dev/zero of=/dev/null bs=1M count=1024" # Example of a command that could slow down the system
}

# Monitor System Resources
monitor_system_resources() {
    echo "Monitoring system resources..."
    execute_ssh_command "top -b -n 1 | head -n 20"  # Display the top 20 lines from the 'top' command
}

# Reboot Server
reboot_server() {
    case "$OS_TYPE" in
        "Ubuntu/Debian" | "Kali Linux" | "Fedora" | "Arch Linux" | "CentOS" | "RHEL") execute_ssh_command "sudo reboot";;
        "Windows") execute_ssh_command "shutdown /r /t 0";;
        "macOS") execute_ssh_command "sudo shutdown -r now";;
    esac
}

# Shutdown Server
shutdown_server() {
    case "$OS_TYPE" in
        "Ubuntu/Debian" | "Kali Linux" | "Fedora" | "Arch Linux" | "CentOS" | "RHEL") execute_ssh_command "sudo shutdown now";;
        "Windows") execute_ssh_command "shutdown /s /t 0";;
        "macOS") execute_ssh_command "sudo shutdown -h now";;
    esac
}

# Open Notepad (Windows only)
open_notepad() {
    if [[ "$OS_TYPE" == "Windows" ]]; then
        echo "Opening Notepad..."
        execute_ssh_command "notepad"
    else
        echo "Notepad is only available on Windows."
    fi
}

# List Files in a Directory
list_files() {
    local dir=$1
    case "$OS_TYPE" in
        "Ubuntu/Debian" | "Kali Linux" | "Fedora" | "Arch Linux" | "CentOS" | "RHEL" | "macOS") execute_ssh_command "ls -la $dir";;
        "Windows") execute_ssh_command "dir $dir";;
    esac
}

# Delete Directory
delete_directory() {
    local dir=$1
    case "$OS_TYPE" in
        "Ubuntu/Debian" | "Kali Linux" | "Fedora" | "Arch Linux" | "CentOS" | "RHEL" | "macOS") execute_ssh_command "rm -rf $dir";;
        "Windows") execute_ssh_command "rmdir /s /q $dir";;
    esac
}

# Backup Files
backup_files() {
    local source_dir=$1
    local dest_dir=$2
    echo "Backing up files from $source_dir to $dest_dir..."
    execute_ssh_command "tar -czf $dest_dir/backup_$(date +%Y%m%d).tar.gz -C $source_dir ."
}

# Update System
update_system() {
    case "$OS_TYPE" in
        "Ubuntu/Debian" | "Kali Linux" | "Fedora") execute_ssh_command "sudo apt update && sudo apt upgrade -y";;
        "CentOS" | "RHEL") execute_ssh_command "sudo yum update -y";;
        "Arch Linux") execute_ssh_command "sudo pacman -Syu --noconfirm";;
        "Windows") execute_ssh_command "choco upgrade all -y";;
    esac
}

# Stress Test
stress_test() {
    echo "Running stress test..."
    if [[ "$OS_TYPE" != "Windows" ]]; then
        execute_ssh_command "stress --cpu 4 --timeout 30"  # Stress test with 4 CPU workers for 30 seconds
    else
        echo "Stress testing is not supported on Windows."
    fi
}

# Generate System Report
generate_system_report() {
    echo "Generating system report..."
    report=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$SERVER_IP" "uname -a; uptime; df -h; free -m; top -b -n 1")
    echo "$report"
}

# Custom SSH Command
custom_ssh_command() {
    local custom_command=$1
    execute_ssh_command "$custom_command"
}

# Show menu after successful login
show_menu() {
    while true; do
        echo ""
        echo "What would you like to do next?"
        echo "1. Execute a custom command"
        echo "2. Start an interactive SSH session"
        echo "3. Reboot the server"
        echo "4. Shutdown the server"
        echo "5. Open Notepad (Windows only)"
        echo "6. List files in a directory"
        echo "7. Delete a directory"
        echo "8. Backup files"
        echo "9. Run a stress test"
        echo "10. Update the system"
        echo "11. Slow down the system"
        echo "12. Monitor system resources"
        echo "13. Generate system report"
        echo "14. Exit"
        read -p "Choose an option (1-14): " choice
        
        case $choice in
            1)
                read -p "Enter the custom SSH command: " CUSTOM_COMMAND
                custom_ssh_command "$CUSTOM_COMMAND"
                ;;
            2)
                ssh "$USERNAME@$SERVER_IP"  # Start an interactive SSH session
                break
                ;;
            3)
                reboot_server
                ;;
            4)
                shutdown_server
                ;;
            5)
                open_notepad
                ;;
            6)
                read -p "Enter the directory to list: " LIST_DIR
                list_files "$LIST_DIR"
                ;;
            7)
                read -p "Enter the directory to delete: " DELETE_DIR
                delete_directory "$DELETE_DIR"
                ;;
            8)
                read -p "Enter the source directory: " SOURCE_DIR
                read -p "Enter the destination directory: " DEST_DIR
                backup_files "$SOURCE_DIR" "$DEST_DIR"
                ;;
            9)
                stress_test
                ;;
            10)
                update_system
                ;;
            11)
                slow_down_system
                ;;
            12)
                monitor_system_resources
                ;;
            13)
                generate_system_report
                ;;
            14)
                echo "Exiting the tool."
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Check login validity
check_login() {
    echo -n "Checking login for $USERNAME@$SERVER_IP..."
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$SERVER_IP" "exit"
    if [[ $? -eq 0 ]]; then
        echo -e "${G}Login successful!${NC}"
        detect_os
        show_menu
    else
        echo -e "${R}Login failed! Please check your credentials.${NC}"
        log_message "ERROR" "Login failed for $USERNAME@$SERVER_IP"
    fi
}

# Check command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        -v|--version) echo "Version: $VERSION"; exit 0 ;;
        -i|--ip) SERVER_IP="$2"; shift ;;
        -u|--username) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -c|--command) COMMAND="$2"; shift ;;
        --interactive) INTERACTIVE_MODE=true ;;
        --multi-server) MULTI_SERVER_MODE=true ;;
        --schedule) SCHEDULE_MODE=true ;;
        --generate-report) GENERATE_REPORT=true ;;
        --reboot) REBOOT=true ;;
        --shutdown) SHUTDOWN=true ;;
        --backup) BACKUP=true ;;
        --stress-test) STRESS_TEST=true ;;
        --list-files) LIST_FILES=true ;;
        --delete-dir) DELETE_DIR=true ;;
        --open-notepad) OPEN_NOTEPAD=true ;;
        --slow-down) SLOW_DOWN=true ;;
        --monitor) MONITOR=true ;;
        *) echo "Unknown option: $1"; show_help ;;
    esac
    shift
done

# Check if necessary dependencies are installed
check_dependencies

# Validate IP address
if ! is_valid_ip "$SERVER_IP"; then
    echo "Invalid IP address: $SERVER_IP"
    exit 1
fi

# Start the tool
display_banner
check_login
