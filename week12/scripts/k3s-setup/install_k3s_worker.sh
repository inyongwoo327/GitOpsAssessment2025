#!/bin/bash
set -e

# Script: install_k3s_worker.sh
# Purpose: Install K3s agent on worker node and join the cluster
# Usage: ./install_k3s_worker.sh <WORKER_INDEX> <PRIMARY_PRIVATE_IP> <K3S_TOKEN>

WORKER_INDEX=$1
PRIMARY_PRIVATE_IP=$2
K3S_TOKEN=$3

# Validate parameters
if [ -z "$WORKER_INDEX" ] || [ -z "$PRIMARY_PRIVATE_IP" ] || [ -z "$K3S_TOKEN" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <WORKER_INDEX> <PRIMARY_PRIVATE_IP> <K3S_TOKEN>"
    exit 1
fi

echo "=== Installing K3s Worker ${WORKER_INDEX} ==="
echo "Primary Master IP: ${PRIMARY_PRIVATE_IP}"

# Update system packages
sudo apt-get update -qq
sudo apt-get install -y -qq curl

# Install K3s agent (worker node)
echo "Joining cluster as worker node..."
curl -sfL https://get.k3s.io | \
    K3S_URL="https://${PRIMARY_PRIVATE_IP}:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    sh -

# Wait for K3s agent to be ready
echo "Waiting for K3s agent to be ready..."
sleep 20

# Check if K3s agent service is active
for i in {1..20}; do 
    if sudo systemctl is-active --quiet k3s-agent; then
        echo "K3s agent is active"
        break
    fi
    echo "Waiting for K3s agent... attempt $i/20"
    sleep 10
done

# Verify K3s agent is running
if sudo systemctl is-active --quiet k3s-agent; then
    echo "=== K3s Worker ${WORKER_INDEX} Ready ==="
    echo "Worker node successfully joined the cluster"
else
    echo "Error: K3s agent failed to start"
    sudo systemctl status k3s-agent
    exit 1
fi