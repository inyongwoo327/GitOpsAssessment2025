# ArgoCD Module - Uses null_resource for all operations
terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}

# Install ArgoCD via kubectl (more reliable than Helm provider)
resource "null_resource" "install_argocd" {
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubeconfig_path}
      
      # Wait for cluster to be ready
      echo "Waiting for cluster..."
      sleep 30
      kubectl wait --for=condition=Ready nodes --all --timeout=300s || true
      
      # Create namespace
      kubectl create namespace argocd || true
      
      # Install ArgoCD
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
      
      # Wait for ArgoCD to be ready
      kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd || true
      
      # Patch service to NodePort
      kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30080,"name":"http"},{"port":443,"nodePort":30443,"name":"https"}]}}'
      
      # Get password
      kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d > ${path.root}/argocd-password.txt 2>/dev/null || echo "Password not ready"
      
      echo "ArgoCD installed successfully"
    EOT
  }

  triggers = {
    cluster_ready = var.cluster_ready_trigger
  }
}

# Wait for ArgoCD
resource "time_sleep" "wait_for_argocd" {
  depends_on      = [null_resource.install_argocd]
  create_duration = "30s"
}

# Apply ArgoCD Applications
resource "null_resource" "apply_argocd_apps" {
  depends_on = [time_sleep.wait_for_argocd]

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubeconfig_path}
      echo "Applying ArgoCD applications..."
      kubectl apply -f ${path.root}/../k8s-manifests/argocd-apps/wordpress-app.yaml || true
      kubectl apply -f ${path.root}/../k8s-manifests/argocd-apps/prometheus-app.yaml || true
      echo "Applications applied"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}