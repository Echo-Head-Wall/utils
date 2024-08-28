#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run a command safely and capture its output
run_command() {
    if command_exists "$1"; then
        echo "$($2)"
    else
        echo "N/A"
    fi
}

# Start TOML output
echo "[system]"
echo "hostname = \"$(hostname)\""
echo "os = \"$(run_command "cat" "cat /etc/os-release | grep '^NAME=' | cut -d'\"' -f2")\""
echo "os_version = \"$(run_command "cat" "cat /etc/os-release | grep '^VERSION_ID=' | cut -d'\"' -f2")\""
echo "kernel = \"$(uname -r)\""

echo -e "\n[cpu]"
echo "model = \"$(run_command "lscpu" "lscpu | grep 'Model name' | cut -d':' -f2 | xargs")\""
echo "cores = $(run_command "lscpu" "lscpu | grep '^CPU(s):' | awk '{print $2}'")"
echo "threads = $(run_command "lscpu" "lscpu | grep '^Thread(s) per core:' | awk '{print $4}'")"

echo -e "\n[memory]"
total_mem=$(run_command "free" "free -b | awk '/^Mem:/{print $2}'")
echo "total_bytes = $total_mem"
echo "total_gb = $(awk "BEGIN {printf \"%.2f\", $total_mem/1024/1024/1024}")"

echo -e "\n[disk]"
echo "partitions = ["
run_command "df" "df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs" | tail -n +2 | while read line; do
    source=$(echo $line | awk '{print $1}')
    size=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    avail=$(echo $line | awk '{print $4}')
    pcent=$(echo $line | awk '{print $5}')
    target=$(echo $line | awk '{print $6}')
    echo "  { source = \"$source\", size = \"$size\", used = \"$used\", available = \"$avail\", used_percent = \"$pcent\", mount_point = \"$target\" },"
done
echo "]"

echo -e "\n[network]"
echo "interfaces = ["
run_command "ip" "ip -o addr show | grep 'inet ' | awk '{print \$2, \$4}'" | while read -r interface ip; do
    echo "  { name = \"$interface\", ip = \"${ip%/*}\" },"
done
echo "]"
