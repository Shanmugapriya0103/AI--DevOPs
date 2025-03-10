#!/bin/bash

# Function to get CPU utilization
get_cpu_utilization() {
    top -bn1 | grep "Cpu(s)" | \
    sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
    awk '{print 100 - $1}'
}

# Function to get Memory utilization
get_memory_utilization() {
    free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get Disk utilization
get_disk_utilization() {
    df / | grep / | awk '{print $5}' | sed 's/%//g'
}

# Get the utilization values
cpu_util=$(get_cpu_utilization)
mem_util=$(get_memory_utilization)
disk_util=$(get_disk_utilization)

# Print utilization values
echo "CPU Utilization: $cpu_util%"
echo "Memory Utilization: $mem_util%"
echo "Disk Utilization: $disk_util%"

# Check VM health
if (( $(echo "$cpu_util < 60" | bc -l) )) && (( $(echo "$mem_util < 60" | bc -l) )) && (( $(echo "$disk_util < 60" | bc -l) )); then
    vm_health="Healthy"
else
    vm_health="Not Healthy"
fi

# Print health status
echo "The state of the VM is: $vm_health"

if [[ $1 == "Explain" ]]; then
    echo "Explanation for VM health status:"
    if (( $(echo "$cpu_util >= 60" | bc -l) )); then
        echo "CPU Utilization is above 60%: $cpu_util%"
    fi
    if (( $(echo "$mem_util >= 60" | bc -l) )); then
        echo "Memory Utilization is above 60%: $mem_util%"
    fi
    if (( $(echo "$disk_util >= 60" | bc -l) )); then
        echo "Disk Utilization is above 60%: $disk_util%"
    fi
    if (( $(echo "$cpu_util < 60" | bc -l) )) && (( $(echo "$mem_util < 60" | bc -l) )) && (( $(echo "$disk_util < 60" | bc -l) )); then
        echo "All parameters are below 60% utilization."
    fi
fi