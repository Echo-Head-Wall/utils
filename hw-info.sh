#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run a command safely
run_command() {
    if command_exists "$1"; then
        eval "$2"
    else
        echo "Warning: $1 is not available on this system."
    fi
}

echo "System Information:"
echo "=================="

# Hostname
echo "Hostname: $(hostname)"
# CPU Information
echo -e "\nCPU Information:"
run_command "lscpu" "lscpu | grep -E 'Model name|Socket|Core|Thread|CPU MHz'"
# Memory Information
echo -e "\nMemory Information:"
run_command "free" "free -h"
# Disk Information
echo -e "\nDisk Information:"
run_command "df" "df -h"
# System Manufacturer and Model (requires root privileges)
echo -e "\nSystem Manufacturer and Model:"
if [ "$(id -u)" -eq 0 ]; then
    run_command "dmidecode" "dmidecode -t system | grep -E 'Manufacturer|Product Name'"
else
    echo "Root privileges required to display system manufacturer and model."
fi
# GPU Information
echo -e "\nGPU Information:"
run_command "lspci" "lspci | grep -i vga"
