resource "null_resource" "deploy_monitoring" {
  depends_on = [var.cluster_ready_trigger]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Deploying kube-prometheus-stack..."
      
      # Wait a bit for cluster to stabilize
      sleep 30
      
      # Deploy monitoring using kubectl
      ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${var.master_ip} << 'ENDSSH'
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
          --wait --timeout=10m
        
        echo "Monitoring stack deployed successfully!"
        
        # Show status
        sudo kubectl get pods -n monitoring
        sudo kubectl get svc -n monitoring
        
        # Save Grafana credentials
        echo "Grafana admin password: admin123" > ~/grafana-password.txt
ENDSSH
    EOT
  }
}

resource "null_resource" "monitoring_info" {
  depends_on = [null_resource.deploy_monitoring]

  provisioner "local-exec" {
    command = <<-EOT
      echo "==================================="
      echo "Monitoring Stack Access Information"
      echo "==================================="
      echo "Prometheus: http://${var.master_ip}:30090"
      echo "Grafana: http://${var.master_ip}:30300"
      echo "  Username: admin"
      echo "  Password: admin123"
      echo "AlertManager: http://${var.master_ip}:30093"
      echo "==================================="
    EOT
  }
}