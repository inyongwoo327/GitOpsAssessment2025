#!/bin/bash
set -e

SSH_KEY_PATH=$1
MASTER_IP=$2

if [ -z "$MASTER_IP" ] || [ -z "$SSH_KEY_PATH" ]; then
  echo "Usage: $0 <ssh_key_path> <master_ip>"
  exit 1
fi

echo "Uploading deployment scripts to primary master node..."

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Upload scripts
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${SCRIPT_DIR}/deploy_wordpress.sh ubuntu@${MASTER_IP}:~/
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${SCRIPT_DIR}/wordpress_deployment_remote.sh ubuntu@${MASTER_IP}:~/

# Execute deployment
echo "Executing WordPress deployment on primary master..."
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${MASTER_IP} '
  chmod +x ~/deploy_wordpress.sh
  chmod +x ~/wordpress_deployment_remote.sh
  ~/deploy_wordpress.sh
'

echo ""
echo "========================================="
echo "Deployment completed successfully!"
echo "========================================="
echo "WordPress URL: http://${MASTER_IP}:30080"
echo "WordPress credentials stored in: ~/wordpress-password.txt on master node"
echo "========================================="