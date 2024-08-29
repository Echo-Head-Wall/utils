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

# OS Information
echo -e "\nOS Information:"
run_command "cat" "cat /etc/os-release | grep -E '^(NAME|VERSION)='"

# Kernel Version
echo -e "\nKernel Version:"
uname -r

# CPU Information
echo -e "\nCPU Information:"
run_command "lscpu" "lscpu | grep -E 'Model name|Socket|Core|Thread|CPU MHz'"

# Memory Information
echo -e "\nMemory Information:"
run_command "free" "free -h"

# Disk Information
echo -e "\nDisk Information:"
run_command "df" "df -h"

# Network Information
echo -e "\nNetwork Information:"
run_command "ip" "ip addr | grep -E 'inet |ether'"

# System Manufacturer and Model (requires root privileges)
echo -e "\nSystem Manufacturer and Model:"
if [ "$(id -u)" -eq 0 ]; then
    run_command "dmidecode" "dmidecode -t system | grep -E 'Manufacturer|Product Name'"
else
    echo "Root privileges required to display system manufacturer and model."
fi

# BIOS Information (requires root privileges)
echo -e "\nBIOS Information:"
if [ "$(id -u)" -eq 0 ]; then
    run_command "dmidecode" "dmidecode -t bios | grep -E 'Vendor|Version|Release Date'"
else
    echo "Root privileges required to display BIOS information."
fi

# GPU Information
echo -e "\nGPU Information:"
run_command "lspci" "lspci | grep -i vga"

# USB Devices
echo -e "\nUSB Devices:"
run_command "lsusb" "lsusb"

# NUMA Information
echo -e "\nNUMA Information:"
run_command "lscpu" "lscpu | grep -i numa"

echo -e "\nNote: This script displays system information. Be cautious about sharing this output as it may contain sensitive data."
