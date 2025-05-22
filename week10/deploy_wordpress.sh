#!/bin/bash
set -e  # Exit on any error

# Get parameters from command line
SSH_KEY_PATH=$1
MASTER_IP=$2

echo "Deploying WordPress using Helm (via SSH)..."

# Deploy WordPress on master node via SSH
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${MASTER_IP} '
  # Create namespace for WordPress
  sudo kubectl create namespace wordpress || true
  
  # Install Helm if not already installed
  if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  fi
  
  # Add Bitnami Helm repository
  helm repo add bitnami https://charts.bitnami.com/bitnami || true
  helm repo update
  
  # Install WordPress with MySQL
  helm upgrade --install wordpress bitnami/wordpress \
    --namespace wordpress \
    --set service.type=NodePort \
    --set service.nodePorts.http=30080 \
    --set persistence.enabled=true \
    --set persistence.storageClass="local-path" \
    --set mariadb.primary.persistence.enabled=true \
    --set mariadb.primary.persistence.storageClass="local-path" \
    --version 24.2.2
    
  # Get WordPress credentials
  echo "WordPress deployment initiated! It may take several minutes to complete."
  echo "WordPress admin username: user"
  PASS=$(sudo kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
  echo "WordPress admin password: $PASS"
  echo "$PASS" > ~/wordpress-password.txt
'

echo "WordPress URL: http://${MASTER_IP}:30080"
echo "WordPress admin password is saved in wordpress-password.txt"