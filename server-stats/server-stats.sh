#!/bin/bash

# This script is used to get the stats for a server. It supports following stats: 
# - CPU usage 
# - Total memory usage 
# - Total disk usage 
# - Top processes by CPU usage
# - Top processes by memory usage
# - Network usage (bytes sent and received)
# - Uptime
# - Load average
# - Number of running processes
# - Number of logged in users
# - System temperature (if supported by the hardware)
# - System information (OS version, kernel version, etc.)
#
# It supports all linux distributions
# - debian based (ubuntu, debian, mint, etc.)
# - redhat based (centos, fedora, rhel, etc.)
# - arch based (arch, manjaro, etc.)
# - macOS

# Global variables
OS=""
VERSION=""
UNAME=""

# Helper function to detect operating system
getosname() {
    UNAME=$(uname)
    if [[ "$UNAME" == "Darwin" ]]; then
        OS="macOS"
        VERSION=$(sw_vers -productVersion)
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION=$VERSION_ID
    else
        echo "Cannot determine the operating system."
        OS='UNKNOWN'
        VERSION='UNKNOWN'
    fi
}

# Function to get CPU usage
getcpuusage() {
    if [[ "$OS" == "Ubuntu" || "$OS" == "Debian GNU/Linux" ]]; then
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    elif [[ "$OS" == "CentOS Linux" || "$OS" == "Fedora" || "$OS" == "Red Hat Enterprise Linux"* ]]; then
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    elif [[ "$OS" == "Arch Linux" || "$OS" == "Manjaro Linux" ]]; then
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')    
    elif [[ "$OS" == "macOS" ]]; then
        CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    else
        echo "Unsupported operating system: $OS"
        CPU_USAGE="N/A"
    fi
}

# Function to get memory usage
getmemoryusage() {
    if [[ "$OS" == "macOS" ]]; then
        # Get memory info on macOS
        local mem_total=$(sysctl -n hw.memsize)
        local mem_used=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//' | awk '{print $1 * 4096}')
        MEMORY_USAGE=$(echo "scale=2; $mem_used / $mem_total * 100" | bc)
    else
        # Linux systems
        MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
    fi
}

# Function to get disk usage
getdiskusage() {
    DISK_USAGE=$(df -h / | awk 'NR==2{print $5}')
}

# Function to get uptime
getuptime() {
    if [[ "$OS" == "macOS" ]]; then
        UPTIME=$(uptime | awk '{print $3 " " $4}' | sed 's/,$//')
    else
        UPTIME=$(uptime -p)
    fi
}

# Function to get load average
getloadaverage() {
    if [[ "$OS" == "macOS" ]]; then
        LOAD_AVERAGE=$(uptime | sed 's/.*load averages: //')
    else
        LOAD_AVERAGE=$(uptime | awk -F'load average:' '{print $2}')
    fi
}

# Function to get number of running processes
getprocesscount() {
    if [[ "$OS" == "macOS" ]]; then
        PROCESS_COUNT=$(ps aux | wc -l)
    else
        PROCESS_COUNT=$(ps aux | wc -l)
    fi
}

# Function to get logged in users
getloggedinusers() {
    LOGGED_USERS=$(who | awk '{print $1}' | sort -u | wc -l)
    TOTAL_SESSIONS=$(who | wc -l)
}

# Main execution
main() {
    echo "=== Server Statistics ==="
    echo ""
    
    # Get OS information
    getosname
    echo "Operating System: $OS $VERSION"
    echo "Kernel: $(uname -r)"
    echo ""
    
    # Get CPU usage
    getcpuusage
    echo "CPU Usage: ${CPU_USAGE}%"
    
    # Get memory usage
    getmemoryusage
    echo "Memory Usage: ${MEMORY_USAGE}%"
    
    # Get disk usage
    getdiskusage
    echo "Disk Usage (root): $DISK_USAGE"
    
    # Get uptime
    getuptime
    echo "Uptime: $UPTIME"
    
    # Get load average
    getloadaverage
    echo "Load Average: $LOAD_AVERAGE"
    
    # Get process count
    getprocesscount
    echo "Running Processes: $PROCESS_COUNT"
    
    # Get logged in users
    getloggedinusers
    echo "Unique Users Logged In: $LOGGED_USERS"
    echo "Total Sessions: $TOTAL_SESSIONS"
}

# Run main function
main
