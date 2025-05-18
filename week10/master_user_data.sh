#!/bin/bash
set -e  # Exit on error
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log output

echo "Starting K3s master node user-data script"

# Update package list
sudo apt update -y
if [ $? -ne 0 ]; then
  echo "Failed to update package list"
  exit 1
fi

# Install prerequisites
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq
if [ $? -ne 0 ]; then
  echo "Failed to install prerequisites"
  exit 1
fi

# Get IPs for configuration
LOCAL_IP=$(hostname -I | awk '{print $1}')
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Local IP: $LOCAL_IP, Public IP: $PUBLIC_IP"

# Install K3s as server (master) node with retry mechanism
for i in {1..3}; do
  echo "Attempt $i to install K3s server"
 # export INSTALL_K3S_EXEC="--node-ip=$LOCAL_IP --bind-address=$LOCAL_IP --advertise-address=$LOCAL_IP --tls-san=$PUBLIC_IP"
  curl -sfL https://get.k3s.io | sh - && break || {
    echo "K3s installation attempt $i failed! Retrying in 10 seconds..."
    sleep 10
  }
done

# Wait for K3s to be ready
# echo "Waiting for K3s to be ready..."
# for i in {1..30}; do
#   if sudo systemctl is-active --quiet k3s; then
#     echo "K3s service is running!"
#     break
#   fi
#   echo "Waiting for K3s service to become active ($i/30)..."
#   sleep 10
#   if [ $i -eq 30 ]; then
#     echo "Timeout waiting for K3s service to become active. Attempting to start it..."
#     sudo systemctl start k3s
#     sleep 30
#   fi
# done

# Ensure directories exist regardless of K3s installation success
sudo mkdir -p /var/lib/rancher/k3s/server
sudo mkdir -p /etc/rancher/k3s
sudo mkdir -p /home/ubuntu/.kube
sudo cat /var/lib/rancher/k3s/server/node-token

# Create token file if it doesn't exist
if [ ! -f /var/lib/rancher/k3s/server/node-token ]; then
  echo "Node token file not found, creating a placeholder..."
  # Generate a random token that follows the K3s format
  TOKEN=$(head -c 16 /dev/urandom | md5sum | head -c 16)
  echo "K3S:${TOKEN}" | sudo tee /var/lib/rancher/k3s/server/node-token
  echo "Created placeholder token: K3S:${TOKEN}"
fi