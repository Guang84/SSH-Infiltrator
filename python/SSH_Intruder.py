import paramiko
import getpass
import logging
import time
import os
import socket

# Set up logging
logging.basicConfig(filename='ssh_tool_log.txt', level=logging.INFO, format='%(asctime)s - [%(levelname)s] - %(message)s')

def log_message(level, message):
    """Log messages with different levels."""
    logging.log(level, message)

def show_help():
    """Display help information."""
    print("Usage: python ssh_intruders.py")
    print("SSH Intruder Tool for Monitoring Servers")
    print("Options:")
    print("  -h, --help          Display this help message")
    print("  -v, --version       Show version information")
    print("  -i, --ip <IP>       Set the server IP address")
    print("  -u, --username <USER>   Set the username")
    print("  -p, --password <PASS>   Set the password (prompted if not provided)")
    exit(0)

def is_valid_ip(ip):
    """Check if a string is a valid IP address."""
    try:
        socket.inet_aton(ip)
        return True
    except socket.error:
        return False

def execute_ssh_command(client, command):
    """Execute a command over SSH and return the output."""
    try:
        stdin, stdout, stderr = client.exec_command(command)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if error:
            log_message(logging.ERROR, f"Error executing command '{command}': {error}")
            print(f"Error: {error}")
            return None
        log_message(logging.INFO, f"Executed command: {command}")
        return output
    except Exception as e:
        log_message(logging.ERROR, f"Failed to execute command '{command}': {str(e)}")
        print(f"Failed to execute command: {str(e)}")
        return None

def check_login(client):
    """Check SSH login by executing a simple command."""
    return execute_ssh_command(client, "echo 'Login Successful'") is not None

def monitor_resources(client):
    """Monitor server resources."""
    print("===== Server Monitoring =====")
    print("===== CPU Usage =====")
    print(execute_ssh_command(client, "wmic cpu get loadpercentage"))

    print("===== Memory Usage =====")
    print(execute_ssh_command(client, "wmic OS get FreePhysicalMemory,TotalVisibleMemorySize"))

    print("===== Disk Usage =====")
    print(execute_ssh_command(client, "wmic logicaldisk get size,freespace,caption"))

    print("===== Network Statistics =====")
    print(execute_ssh_command(client, "netstat -e"))

def monitor_disk_space(client):
    """Monitor disk space and alert if usage exceeds threshold."""
    print("===== Disk Space Monitoring =====")
    threshold = 80  # Set threshold percentage
    output = execute_ssh_command(client, "df -h --output=pcent,target | grep -v 'Use%' | sed 's/%//'")
    
    if output:
        for line in output.splitlines():
            usage, mount_point = line.split()
            if int(usage) > threshold:
                print(f"Warning: Disk usage on {mount_point} is at {usage}%")
                log_message(logging.WARNING, f"Disk usage on {mount_point} is at {usage}%")

def execute_custom_command(client):
    """Execute a custom command on the server."""
    custom_command = input("Enter the command to execute on the server: ")
    print("Executing command:", custom_command)
    print(execute_ssh_command(client, custom_command))

def main():
    """Main function to run the SSH Intruder Tool."""
    import argparse

    parser = argparse.ArgumentParser(description="SSH Intruder Tool for Monitoring Servers")
    parser.add_argument('-i', '--ip', help='Server IP address', required=True)
    parser.add_argument('-u', '--username', help='Username', required=True)
    parser.add_argument('-p', '--password', help='Password (prompted if not provided)', default=None)
    args = parser.parse_args()

    # Prompt for password if not provided
    if not args.password:
        args.password = getpass.getpass("Enter the Password: ")

    # Validate IP address format
    if not is_valid_ip(args.ip):
        print("Invalid IP address format. Please try again.")
        exit(1)

    # Create SSH client
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(args.ip, username=args.username, password=args.password)
        print("Login successful.")
        log_message(logging.INFO, "Login successful.")

        # Configurable sleep interval
        monitor_interval = input("Enter monitoring interval in seconds (default: 10): ")
        monitor_interval = int(monitor_interval) if monitor_interval.isdigit() else 10  # Default to 10 seconds

        # Infinite loop for monitoring resources
        while True:
            os.system('clear' if os.name == 'posix' else 'cls')  # Clear the terminal
            monitor_resources(client)
            monitor_disk_space(client)
            print("=============================")
            time.sleep(monitor_interval)  # Use user-defined interval

    except paramiko.AuthenticationException:
        print("Login failed. Exiting.")
        log_message(logging.ERROR, "Login failed.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        log_message(logging.ERROR, f"An error occurred: {str(e)}")
    finally:
        client.close()

if __name__ == "__main__":
    main()
