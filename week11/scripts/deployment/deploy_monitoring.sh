#!/bin/bash
set -e

SSH_KEY_PATH=$1
MASTER_IP=$2

if [ -z "$MASTER_IP" ] || [ -z "$SSH_KEY_PATH" ]; then
  echo "Usage: $0 <ssh_key_path> <master_ip>"
  exit 1
fi

echo "Deploying kube-prometheus-stack to cluster..."

ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${MASTER_IP} << 'ENDSSH'
  set -e
  
  # Install Helm if not present
  if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  fi
  
  # Add prometheus-community repo
  echo "Adding prometheus-community Helm repo..."
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  
  # Create monitoring namespace
  sudo kubectl create namespace monitoring || true
  
  # Deploy kube-prometheus-stack
  echo "Installing kube-prometheus-stack..."
  helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set prometheus.service.type=NodePort \
    --set prometheus.service.nodePort=30090 \
    --set grafana.service.type=NodePort \
    --set grafana.service.nodePort=30300 \
    --set grafana.adminPassword=admin123 \
    --set alertmanager.service.type=NodePort \
    --set alertmanager.service.nodePort=30093 \
    --set prometheus.prometheusSpec.retention=7d \
    --set prometheus.prometheusSpec.resources.requests.cpu=200m \
    --set prometheus.prometheusSpec.resources.requests.memory=512Mi \
    --wait --timeout=10m
  
  echo "Monitoring stack deployed successfully!"
  
  # Show status
  echo ""
  echo "========================================="
  echo "Monitoring Stack Status"
  echo "========================================="
  sudo kubectl get pods -n monitoring
  echo ""
  sudo kubectl get svc -n monitoring
  echo "========================================="
  
  # Save credentials
  echo "admin123" > ~/grafana-password.txt
ENDSSH

echo ""
echo "========================================="
echo "Monitoring Access Information"
echo "========================================="
echo "Prometheus: http://${MASTER_IP}:30090"
echo "Grafana:    http://${MASTER_IP}:30300"
echo "  Username: admin"
echo "  Password: admin123"
echo "AlertManager: http://${MASTER_IP}:30093"
echo "========================================="