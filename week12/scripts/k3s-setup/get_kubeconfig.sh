#!/bin/bash
set -e

# Script: get_kubeconfig.sh
# Purpose: Fetch kubeconfig from master node and configure for local use
# Usage: ./get_kubeconfig.sh <SSH_KEY_PATH> <MASTER_IP> <OUTPUT_PATH>

SSH_KEY=$1
MASTER_IP=$2
OUTPUT_PATH=$3

# Validate parameters
if [ -z "$SSH_KEY" ] || [ -z "$MASTER_IP" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <SSH_KEY_PATH> <MASTER_IP> <OUTPUT_PATH>"
    exit 1
fi

echo "=== Fetching kubeconfig from K3s master ==="
echo "Master IP: ${MASTER_IP}"
echo "Output path: ${OUTPUT_PATH}"

# Create directory if it doesn't exist
OUTPUT_DIR=$(dirname "${OUTPUT_PATH}")
mkdir -p "${OUTPUT_DIR}"

# Fetch kubeconfig from master node via SCP
echo "Downloading kubeconfig..."
scp -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -i "${SSH_KEY}" \
    ubuntu@${MASTER_IP}:/home/ubuntu/.kube/config \
    "${OUTPUT_PATH}"

if [ ! -f "${OUTPUT_PATH}" ]; then
    echo "Error: Failed to download kubeconfig"
    exit 1
fi

echo "Kubeconfig downloaded successfully"

# Replace localhost with master public IP for external access
echo "Configuring kubeconfig for external access..."

# Detect OS for sed compatibility
if command -v sed > /dev/null 2>&1; then
    if sed --version 2>&1 | grep -q GNU; then
        # GNU sed (Linux)
        echo "Using GNU sed"
        sed -i "s|https://127.0.0.1:6443|https://${MASTER_IP}:6443|g" "${OUTPUT_PATH}"
    else
        # BSD sed (macOS)
        echo "Using BSD sed"
        sed -i '' "s|https://127.0.0.1:6443|https://${MASTER_IP}:6443|g" "${OUTPUT_PATH}"
    fi
else
    echo "Warning: sed not found. Manual configuration may be needed."
fi

# Set proper permissions
chmod 600 "${OUTPUT_PATH}"

echo "=== Kubeconfig Configuration Complete ==="
echo "Kubeconfig saved to: ${OUTPUT_PATH}"
echo ""
echo "To use this kubeconfig, run:"
echo "  export KUBECONFIG=${OUTPUT_PATH}"
echo "  kubectl get nodes"