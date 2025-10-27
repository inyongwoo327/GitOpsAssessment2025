# ArgoCD Module - Install via remote-exec on master node
terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}

# Install ArgoCD by running commands on the master node
resource "null_resource" "install_argocd" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = var.master_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo '=== Installing ArgoCD ==='",
      
      # Wait for cluster to be fully ready
      "sleep 30",
      "sudo kubectl wait --for=condition=Ready nodes --all --timeout=300s || true",
      
      # Create ArgoCD namespace
      "sudo kubectl create namespace argocd || true",
      
      # Install ArgoCD
      "sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml",
      
      # Wait for ArgoCD to be ready
      "echo 'Waiting for ArgoCD pods...'",
      "sleep 60",
      "sudo kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd || true",
      
      # Patch service to NodePort
      "echo 'Patching ArgoCD service to NodePort...'",
      "sudo kubectl patch svc argocd-server -n argocd -p '{\"spec\":{\"type\":\"NodePort\",\"ports\":[{\"name\":\"http\",\"port\":80,\"nodePort\":30080,\"protocol\":\"TCP\",\"targetPort\":8080},{\"name\":\"https\",\"port\":443,\"nodePort\":30443,\"protocol\":\"TCP\",\"targetPort\":8080}]}}'",
      
      # Get initial password
      "echo 'Getting ArgoCD password...'",
      "sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d > ~/argocd-password.txt",
      
      "echo '=== ArgoCD Installation Complete ==='",
      "sudo kubectl get pods -n argocd"
    ]
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

# Apply ArgoCD Applications via remote-exec
resource "null_resource" "apply_argocd_apps" {
  depends_on = [time_sleep.wait_for_argocd]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = var.master_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.root}/../k8s-manifests/argocd-apps/wordpress-app.yaml"
    destination = "/tmp/wordpress-app.yaml"
  }

  provisioner "file" {
    source      = "${path.root}/../k8s-manifests/argocd-apps/prometheus-app.yaml"
    destination = "/tmp/prometheus-app.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Applying ArgoCD applications...'",
      "sudo kubectl apply -f /tmp/wordpress-app.yaml",
      "sudo kubectl apply -f /tmp/prometheus-app.yaml",
      "echo 'ArgoCD applications applied successfully'",
      "sudo kubectl get applications -n argocd"
    ]
  }

  triggers = {
    always_run = timestamp()
  }
}

# Download ArgoCD password to local machine
resource "null_resource" "get_argocd_password" {
  depends_on = [null_resource.install_argocd]

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${var.master_ip}:~/argocd-password.txt ${path.root}/argocd-password.txt"
  }

  triggers = {
    always_run = timestamp()
  }
}