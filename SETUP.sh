#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create a virtual environment and install dependencies
setup_virtualenv() {
    echo "Setting up virtual environment..."

    # Check if virtualenv is installed
    if ! command_exists virtualenv; then
        echo "Installing virtualenv..."
        pip install virtualenv
    fi

    # Create a virtual environment
    virtualenv venv
    source venv/bin/activate

    # Install dependencies
    pip install paramiko

    echo "Dependencies installed successfully."
    echo "Virtual environment set up. Remember to activate it using 'source venv/bin/activate'."
}

# Check for Python
if ! command_exists python3; then
    echo "Python 3 is not installed. Please install Python 3 to proceed."
    exit 1
fi

# Check for pip
if ! command_exists pip; then
    echo "pip is not installed. Please install pip to proceed."
    exit 1
fi

# Run the setup
setup_virtualenv

# Provide instructions
echo "Setup completed."
echo "To run the SSH Intruder Tool, activate the virtual environment and execute the main script:"
echo "source venv/bin/activate"
echo "python ssh_intruders.py -i <server_ip> -u <username> [-p <password>]"
