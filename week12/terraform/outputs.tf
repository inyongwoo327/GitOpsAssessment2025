output "master_primary_ip" {
  description = "Primary master public IP"
  value       = module.k3s_cluster.master_primary_public_ip
}

output "master_secondary_ip" {
  description = "Secondary master public IP"
  value       = module.k3s_cluster.master_secondary_public_ip
}

output "worker_ips" {
  description = "Worker node public IPs"
  value       = module.k3s_cluster.worker_public_ips
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = module.k3s_cluster.kubeconfig_path
}

output "argocd_url" {
  description = "ArgoCD web UI URL"
  value       = "http://${module.k3s_cluster.master_primary_public_ip}:30080"
}

output "argocd_admin_password" {
  description = "ArgoCD initial admin password"
  value       = module.argocd.argocd_initial_password
  sensitive   = true
}

output "wordpress_url" {
  description = "WordPress URL (deployed via ArgoCD)"
  value       = "http://${module.k3s_cluster.master_primary_public_ip}:30081"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${module.k3s_cluster.master_primary_public_ip}:30090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${module.k3s_cluster.master_primary_public_ip}:30300"
}

output "alertmanager_url" {
  description = "AlertManager URL"
  value       = "http://${module.k3s_cluster.master_primary_public_ip}:30093"
}

output "access_instructions" {
  description = "How to access services"
  value = <<-EOT
    
    ========================================
    K3s HA Cluster with GitOps - Access Info
    ========================================
    
    Kubeconfig:
      export KUBECONFIG=${module.k3s_cluster.kubeconfig_path}
    
    ArgoCD:
      URL: http://${module.k3s_cluster.master_primary_public_ip}:30080
      Username: admin
      Password: Run 'terraform output -raw argocd_admin_password'
    
    WordPress (deployed via ArgoCD):
      URL: http://${module.k3s_cluster.master_primary_public_ip}:30081
      Get password: kubectl get secret -n wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d
    
    Monitoring Stack:
      Prometheus: http://${module.k3s_cluster.master_primary_public_ip}:30090
      Grafana: http://${module.k3s_cluster.master_primary_public_ip}:30300
        Username: admin
        Password: admin123
      AlertManager: http://${module.k3s_cluster.master_primary_public_ip}:30093
    
    Verify Deployment:
      kubectl get nodes
      kubectl get applications -n argocd
      kubectl get pods -n wordpress
    
    SSH Access:
      ssh -i ~/.ssh/test.pem ubuntu@${module.k3s_cluster.master_primary_public_ip}
    
    ========================================
  EOT
}