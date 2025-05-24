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

echo "Uploading deployment scripts to master node..."

# Upload both scripts to the master node
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} deploy_wordpress.sh ubuntu@${MASTER_IP}:~/
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} wordpress_deployment_remote.sh ubuntu@${MASTER_IP}:~/

# Execute the main deployment script on the master node
echo "Executing deployment scripts on master node..."
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${MASTER_IP} '
  chmod +x ~/deploy_wordpress.sh
  chmod +x ~/wordpress_deployment_remote.sh
  ~/deploy_wordpress.sh
'

echo "WordPress URL: http://${MASTER_IP}:30080"
echo "WordPress admin password is saved in wordpress-password.txt in master node"
echo "Deployment completed successfully!"