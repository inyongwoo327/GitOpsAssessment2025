#!/bin/bash
set -e

# Script: install_k3s_primary.sh
# Purpose: Install K3s on primary master node with cluster initialization
# Usage: ./install_k3s_primary.sh <PRIMARY_PUBLIC_IP> <PRIMARY_PRIVATE_IP>

PRIMARY_PUBLIC_IP=$1
PRIMARY_PRIVATE_IP=$2

# Validate parameters
if [ -z "$PRIMARY_PUBLIC_IP" ] || [ -z "$PRIMARY_PRIVATE_IP" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <PRIMARY_PUBLIC_IP> <PRIMARY_PRIVATE_IP>"
    exit 1
fi

echo "=== Installing K3s Primary Master ==="
echo "Public IP: ${PRIMARY_PUBLIC_IP}"
echo "Private IP: ${PRIMARY_PRIVATE_IP}"

# Update system packages
sudo apt-get update -qq
sudo apt-get install -y -qq apt-transport-https ca-certificates curl git

# Create K3s configuration directory
sudo mkdir -p /etc/rancher/k3s

# Create K3s configuration file
echo "Creating K3s configuration..."
cat <<EOF | sudo tee /etc/rancher/k3s/config.yaml
write-kubeconfig-mode: '0644'
cluster-init: true
tls-san:
  - ${PRIMARY_PUBLIC_IP}
  - ${PRIMARY_PRIVATE_IP}
node-ip: ${PRIMARY_PRIVATE_IP}
disable:
  - traefik
EOF

# Install K3s server
echo "Installing K3s..."
curl -sfL https://get.k3s.io | sh -s - server

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

# Setup kubeconfig for ubuntu user
echo "Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod 600 $HOME/.kube/config

# Save cluster token for other nodes to join
echo "Saving cluster token..."
sudo cp /var/lib/rancher/k3s/server/node-token $HOME/node-token
sudo chown ubuntu:ubuntu $HOME/node-token

# Verify installation
echo "=== K3s Primary Master Ready ==="
echo "Cluster initialized successfully"
echo ""
echo "Cluster status:"
sudo kubectl get nodes

# Display token location
echo ""
echo "Cluster token saved to: $HOME/node-token"
echo "Use this token for secondary master and worker nodes to join the cluster"