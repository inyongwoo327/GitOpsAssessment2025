#!/bin/bash
set -e

echo "Starting WordPress deployment on K3s HA cluster..."

# Create namespace
echo "Creating WordPress namespace..."
sudo kubectl create namespace wordpress || true

# Helm should already be installed
echo "Adding Bitnami repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update

# Install WordPress - USE LATEST VERSION
echo "Installing WordPress with MariaDB..."
helm upgrade --install wordpress bitnami/wordpress \
  --namespace wordpress \
  --set service.type=NodePort \
  --set service.nodePorts.http=30080 \
  --set persistence.enabled=false \
  --set mariadb.primary.persistence.enabled=false \
  --set wordpressUsername=admin \
  --set resources.limits.cpu=300m \
  --set resources.limits.memory=256Mi \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=128Mi \
  --wait --timeout=10m

# Wait for deployment
echo "Waiting for WordPress deployment to be ready..."
sudo kubectl wait --for=condition=available --timeout=300s deployment/wordpress -n wordpress || true

# Get credentials
echo "WordPress deployment completed!"
echo "WordPress admin username: admin"
PASS=$(sudo kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
echo "WordPress admin password: $PASS"
echo "$PASS" > ~/wordpress-password.txt

# Display status
echo ""
echo "========================================="
echo "WordPress Deployment Status"
echo "========================================="
sudo kubectl get pods -n wordpress
echo ""
sudo kubectl get svc -n wordpress
echo "========================================="