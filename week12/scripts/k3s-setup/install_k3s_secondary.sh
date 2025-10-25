#!/bin/bash
set -e

# Script: install_k3s_secondary.sh
# Purpose: Install K3s on secondary master node and join the cluster
# Usage: ./install_k3s_secondary.sh <PRIMARY_PRIVATE_IP> <K3S_TOKEN>

PRIMARY_PRIVATE_IP=$1
K3S_TOKEN=$2

# Validate parameters
if [ -z "$PRIMARY_PRIVATE_IP" ] || [ -z "$K3S_TOKEN" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <PRIMARY_PRIVATE_IP> <K3S_TOKEN>"
    exit 1
fi

echo "=== Installing K3s Secondary Master ==="
echo "Primary Master IP: ${PRIMARY_PRIVATE_IP}"

# Update system packages
sudo apt-get update -qq
sudo apt-get install -y -qq curl

# Install K3s server joining the existing cluster
echo "Joining cluster as secondary master..."
curl -sfL https://get.k3s.io | \
    K3S_URL="https://${PRIMARY_PRIVATE_IP}:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    sh -s - server

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
sleep 30

# Check if K3s service is active
for i in {1..30}; do 
    if sudo systemctl is-active --quiet k3s; then
        echo "K3s is active"
        break
    fi
    echo "Waiting for K3s... attempt $i/30"
    sleep 10
done

# Verify K3s is running
if sudo systemctl is-active --quiet k3s; then
    echo "=== K3s Secondary Master Ready ==="
    echo "Node successfully joined the cluster"
else
    echo "Error: K3s failed to start"
    sudo systemctl status k3s
    exit 1
fi