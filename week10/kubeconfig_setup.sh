#!/bin/bash
set -e

# This script fetches the kubeconfig from the K3s master node
# and modifies it to use the public IP for external access

# Parameters
MASTER_IP=$1
SSH_KEY_PATH=$2

# Check if parameters are provided
if [ -z "$MASTER_IP" ] || [ -z "$SSH_KEY_PATH" ]; then
  echo "Usage: $0 <master_ip> <ssh_key_path>"
  exit 1
fi

echo "Setting up kubeconfig for K3s cluster..."

# Waiting for SSH to be available with retries
echo "Waiting for SSH to be available on master node..."
MAX_RETRIES=20
for i in $(seq 1 $MAX_RETRIES); do
  if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i $SSH_KEY_PATH ubuntu@$MASTER_IP 'exit' 2>/dev/null; then
    echo "SSH connection successful!"
    break
  fi
  echo "SSH not yet available, retry $i/$MAX_RETRIES..."
  if [ $i -eq $MAX_RETRIES ]; then
    echo "Failed to connect to the master node after $MAX_RETRIES attempts."
    exit 1
  fi
  sleep 10
done

# Wait for the setup completion marker
echo "Waiting for K3s setup to complete..."
MAX_RETRIES=20
for i in $(seq 1 $MAX_RETRIES); do
  if ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ubuntu@$MASTER_IP 'test -f /home/ubuntu/k3s-setup-complete' 2>/dev/null; then
    echo "K3s setup is complete!"
    break
  fi
  echo "K3s setup not complete, retry $i/$MAX_RETRIES..."
  if [ $i -eq $MAX_RETRIES ]; then
    echo "K3s setup not complete after $MAX_RETRIES attempts."
    exit 1
  fi
  sleep 15
done

# Fetch the pre-modified kubeconfig file
echo "Fetching kubeconfig from master node..."
scp -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ubuntu@$MASTER_IP:/home/ubuntu/.kube/config kubeconfig

echo "Kubeconfig setup complete. To use it:"
echo "export KUBECONFIG=$PWD/kubeconfig"

# Test the kubeconfig
export KUBECONFIG=$PWD/kubeconfig
echo "Testing kubeconfig..."
if kubectl cluster-info; then
  echo "Kubeconfig is working correctly!"
else
  echo "Kubeconfig test failed. There might be a problem with the K3s setup."
  exit 1
fi