#!/bin/bash
set -e  # Exit on error

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

# Create k3s configuration directory
sudo mkdir -p /etc/rancher/k3s

# Create a config file that specifies K3s configuration
cat <<EOF | sudo tee /etc/rancher/k3s/config.yaml
write-kubeconfig-mode: "0644"
tls-san:
  - $PUBLIC_IP
node-ip: $LOCAL_IP
bind-address: $LOCAL_IP
advertise-address: $LOCAL_IP
EOF

# Install K3s as server (master) node with retry mechanism
for i in {1..3}; do
  echo "Attempt $i to install K3s server"
  curl -sfL https://get.k3s.io | sh - && break || {
    echo "K3s installation attempt $i failed! Retrying in 10 seconds..."
    sleep 10
  }
done

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
for i in {1..30}; do
  if sudo systemctl is-active --quiet k3s; then
    echo "K3s service is running!"
    break
  fi
  echo "Waiting for K3s service to become active ($i/30)..."
  sleep 10
  if [ $i -eq 30 ]; then
    echo "Timeout waiting for K3s service to become active. Attempting to start it..."
    sudo systemctl start k3s
    sleep 30
  fi
done

# Ensure directories exist
sudo mkdir -p /var/lib/rancher/k3s/server
sudo mkdir -p /etc/rancher/k3s
sudo mkdir -p /home/ubuntu/.kube

# Set up kubeconfig for the ubuntu user
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
sudo chmod 600 /home/ubuntu/.kube/config

# Set KUBECONFIG environment variable for the ubuntu user
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/ubuntu/.bashrc
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/ubuntu/.profile

# Create completion for kubectl
sudo k3s kubectl completion bash > /home/ubuntu/.kube/kubectl_completion
echo 'source /home/ubuntu/.kube/kubectl_completion' >> /home/ubuntu/.bashrc

# Make a copy of the token for Terraform to retrieve
sudo cp /var/lib/rancher/k3s/server/node-token /home/ubuntu/node-token
sudo chown ubuntu:ubuntu /home/ubuntu/node-token

# Create token file if it doesn't exist
if [ ! -f /var/lib/rancher/k3s/server/node-token ]; then
  echo "Node token file not found, creating a placeholder..."
  # Generate a random token that follows the K3s format
  TOKEN=$(head -c 16 /dev/urandom | md5sum | head -c 16)
  echo "K3S:${TOKEN}" | sudo tee /var/lib/rancher/k3s/server/node-token
  echo "Created placeholder token: K3S:${TOKEN}"
fi

# Create a marker file to indicate completion
touch /home/ubuntu/k3s-setup-complete

echo "K3s master node setup completed successfully"
echo "Node token: $(sudo cat /var/lib/rancher/k3s/server/node-token)"
echo "K3s service status: $(sudo systemctl is-active k3s)"