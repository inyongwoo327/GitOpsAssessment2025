#!/bin/bash
set -e

echo "Starting WordPress deployment on K3s cluster..."

# Create namespace for WordPress
echo "Creating WordPress namespace..."
sudo kubectl create namespace wordpress || true

# Install Helm if not already installed
if ! command -v helm &> /dev/null; then
  echo "Installing Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "Helm is already installed"
fi

# Add Bitnami Helm repository
echo "Adding Bitnami repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update

# Install WordPress with MySQL
echo "Installing WordPress with MariaDB..."
helm upgrade --install wordpress bitnami/wordpress \
  --namespace wordpress \
  --set service.type=NodePort \
  --set service.nodePorts.http=30080 \
  --set persistence.enabled=true \
  --set persistence.storageClass="local-path" \
  --set mariadb.primary.persistence.enabled=true \
  --set mariadb.primary.persistence.storageClass="local-path" \
  --version 24.2.2 \
  --wait --timeout=15m

# Wait for deployment to be ready
echo "Waiting for WordPress deployment to be ready..."
sudo kubectl wait --for=condition=available --timeout=600s deployment/wordpress -n wordpress || true

# Get WordPress credentials
echo "WordPress deployment completed!"
echo "WordPress admin username: user"
PASS=$(sudo kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
echo "WordPress admin password: $PASS"
echo "$PASS" > ~/wordpress-password.txt

# Display pod status
echo "WordPress pod status:"
sudo kubectl get pods -n wordpress

# Display service status
echo "WordPress service status:"
sudo kubectl get svc -n wordpress

echo "WordPress deployment script completed successfully!"