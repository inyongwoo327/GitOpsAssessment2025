#!/bin/bash
set -e  # Exit on error
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log output

echo "Starting K3s worker node user-data script"

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

# Get local IP for configuration
LOCAL_IP=$(hostname -I | awk '{print $1}')
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Worker Local IP: $LOCAL_IP, Public IP: $PUBLIC_IP"

# The master IP and token will be replaced by Terraform template
MASTER_IP="${MASTER_IP}"
K3S_TOKEN="${master_token}"

echo "Using Master IP: $MASTER_IP and token from Terraform"

# Create k3s configuration directory
sudo mkdir -p /etc/rancher/k3s

# Install K3s as agent (worker) node with retry logic
for i in {1..5}; do
    echo "Attempt $i to install K3s agent"
    curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="${K3S_TOKEN}" sh - && {
        echo "K3s agent installation successful!"
        break
    } || {
        echo "K3s agent installation attempt $i failed! Retrying in 30 seconds..."
        sleep 30
        
        # If this is the last attempt, try with a different approach
        if [ $i -eq 5 ]; then
            echo "Trying alternative installation method..."
            curl -sfL https://get.k3s.io > /tmp/install-k3s.sh
            chmod +x /tmp/install-k3s.sh
            K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="${K3S_TOKEN}" /tmp/install-k3s.sh
        fi
    }
done

# Verify K3s agent is running
for i in {1..10}; do
    if sudo systemctl is-active --quiet k3s-agent; then
        echo "K3s agent is running!"
        break
    fi
    echo "Waiting for K3s agent to start ($i/10)..."
    sleep 15
    
    if [ $i -eq 10 ]; then
        echo "K3s agent did not start properly. Attempting to restart..."
        sudo systemctl restart k3s-agent
    fi
done

# Create a marker file to indicate completion
touch /home/ubuntu/k3s-worker-setup-complete

echo "K3s worker node setup completed successfully"
echo "K3s agent status: $(sudo systemctl is-active k3s-agent)"