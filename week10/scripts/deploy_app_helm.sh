#!/bin/bash
set -e

# This script deploys WordPress using the Bitnami Helm Chart.

echo "Starting WordPress deployment with Helm..."

# Load environment variables from .env file
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  set -a  # automatically export all variables
  source .env
  set +a
else
  echo "No .env file found. Using default values."
fi

# Use local kubeconfig
export KUBECONFIG=$PWD/kubeconfig

# Verify cluster connectivity with retries
echo "Verifying connection to the k3s cluster..."
MAX_RETRIES=10
for i in $(seq 1 $MAX_RETRIES); do
  if kubectl cluster-info; then
    echo "Successfully connected to K3s cluster!"
    break
  fi
  echo "Connection attempt $i/$MAX_RETRIES failed. Retrying in 10 seconds..."
  sleep 10
  if [ $i -eq $MAX_RETRIES ]; then
    echo "Failed to connect to K3s cluster after multiple attempts."
    exit 1
  fi
done

# Wait for nodes to be ready
echo "Waiting for all nodes to be ready..."
MAX_RETRIES=10
for i in $(seq 1 $MAX_RETRIES); do
  if kubectl wait --for=condition=Ready nodes --all --timeout=30s; then
    echo "All nodes are ready!"
    break
  fi
  echo "Not all nodes are ready, retry $i/$MAX_RETRIES..."
  sleep 30
  if [ $i -eq $MAX_RETRIES ]; then
    echo "Not all nodes are ready after $MAX_RETRIES attempts."
    exit 1
  fi
done

# Add Bitnami Helm repository
echo "Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create namespace for WordPress
echo "Creating namespace for WordPress..."
kubectl create namespace wordpress --dry-run=client -o yaml | kubectl apply -f -

cat > wordpress-values.yaml <<EOF
wordpressUsername: "${WORDPRESS_DB_USER}"
wordpressPassword: "${WORDPRESS_DB_PASSWORD}"
wordpressEmail: "${WORDPRESS_EMAIL:-inyongwoo327@gmail.com}"
mariadb:
  auth:
    rootPassword: "${MYSQL_ROOT_PASSWORD}"
    password: "${MYSQL_PASSWORD}"
    database: "${MYSQL_DATABASE}"
service:
  type: NodePort
persistence:
  size: 10Gi
mariadb:
  primary:
    persistence:
      size: 8Gi
EOF

# Deploy WordPress with Helm
echo "Deploying WordPress with Helm..."
helm install wordpress bitnami/wordpress \
  --version 24.2.2 \
  --namespace wordpress \
  --values wordpress-values.yaml

rm wordpress-values.yaml

echo "Waiting for WordPress deployment to be ready..."
kubectl -n wordpress wait --for=condition=available --timeout=300s deployment/wordpress

# Set up NodePort for access
echo "Setting up NodePort service for accessing WordPress..."
cat > wordpress-nodeport.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: wordpress
  labels:
    app.kubernetes.io/name: wordpress
  spec:
    type: NodePort
    ports:
    - port: 80
      targetPort: http
      protocol: TCP
      nodePort: 30080
      name: http
    selector:
      app.kubernetes.io/name: wordpress
EOF

kubectl apply -f wordpress-nodeport.yaml
rm wordpress-nodeport.yaml

# Get master node IP
MASTER_IP=$(terraform output -raw master_public_ip 2>/dev/null || echo "YOUR_MASTER_IP")

echo "WordPress deployment completed!"
echo "To access WordPress, visit http://${MASTER_IP}:30080"

# Test connection to WordPress
echo "Testing connection to WordPress..."
sleep 10
curl -s -o /dev/null -w "WordPress HTTP status: %{http_code}\n" http://${MASTER_IP}:30080