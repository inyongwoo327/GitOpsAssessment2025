#!/bin/bash
set -e

# Get parameters from command line
SSH_KEY_PATH=$1
MASTER_IP=$2

# Check if parameters are provided
if [ -z "$MASTER_IP" ] || [ -z "$SSH_KEY_PATH" ]; then
  echo "Usage: $0 <ssh_key_path> <master_ip>"
  exit 1
fi

echo "Retrieving kubeconfig from master node..."

MAX_RETRIES=5
for i in $(seq 1 $MAX_RETRIES); do
  if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ${SSH_KEY_PATH} ubuntu@${MASTER_IP} 'sudo cat /etc/rancher/k3s/k3s.yaml' > kubeconfig 2>/dev/null; then
    echo "Successfully retrieved kubeconfig"
    
    # Get private IP to properly update kubeconfig
    PRIVATE_IP=$(ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${MASTER_IP} 'hostname -I | awk "{print \$1}"')
    
    # Handle both macOS and Linux sed syntax
    # Try macOS syntax first, fall back to Linux syntax
    sed -i '' "s/127.0.0.1/${MASTER_IP}/g" kubeconfig 2>/dev/null || \
    sed -i "s/127.0.0.1/${MASTER_IP}/g" kubeconfig
    
    # Also replace the server address if it has the private IP
    if [ ! -z "$PRIVATE_IP" ]; then
      sed -i '' "s/$PRIVATE_IP/${MASTER_IP}/g" kubeconfig 2>/dev/null || \
      sed -i "s/$PRIVATE_IP/${MASTER_IP}/g" kubeconfig
    fi
    
    chmod 600 kubeconfig
    echo "Kubeconfig setup complete and saved to ./kubeconfig"
    exit 0
  fi
  echo "Attempt $i/$MAX_RETRIES: Failed to get kubeconfig, retrying in 20s..."
  sleep 20
done

echo "Failed to retrieve kubeconfig after $MAX_RETRIES attempts."
echo "Creating minimal kubeconfig placeholder"
cat > kubeconfig << EOF
apiVersion: v1
clusters:
- cluster:
    server: https://${MASTER_IP}:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user: {}
EOF

echo "Created placeholder kubeconfig"