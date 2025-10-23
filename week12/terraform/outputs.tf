output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "master_primary_public_ip" {
  description = "Primary master node public IP"
  value       = module.k3s_cluster.master_primary_public_ip
}

output "master_secondary_public_ip" {
  description = "Secondary master node public IP"
  value       = module.k3s_cluster.master_secondary_public_ip
}

output "worker_public_ips" {
  description = "Worker nodes public IPs"
  value       = module.k3s_cluster.worker_public_ips
}

output "kubernetes_api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://${module.k3s_cluster.master_primary_public_ip}:6443"
}

output "prometheus_url" {
  description = "Prometheus UI URL"
  value       = module.monitoring.prometheus_url
}

output "grafana_url" {
  description = "Grafana UI URL"
  value       = module.monitoring.grafana_url
}

output "grafana_credentials" {
  description = "Grafana login credentials"
  value       = module.monitoring.grafana_credentials
  sensitive   = true
}

output "alertmanager_url" {
  description = "AlertManager UI URL"
  value       = module.monitoring.alertmanager_url
}

output "wordpress_url" {
  description = "WordPress access URL"
  value       = "http://${module.k3s_cluster.master_primary_public_ip}:30080"
}

output "cluster_info" {
  description = "Complete cluster information"
  value = <<-EOT
    ========================================
    K3s HA Cluster Information
    ========================================
    
    CONTROL PLANE (HA):
    - Primary Master:   ${module.k3s_cluster.master_primary_public_ip}
    - Secondary Master: ${module.k3s_cluster.master_secondary_public_ip}
    
    WORKER NODES:
    ${join("\n    ", [for idx, ip in module.k3s_cluster.worker_public_ips : "- Worker ${idx + 1}: ${ip}"])}
    
    MONITORING STACK:
    - Prometheus:    ${module.monitoring.prometheus_url}
    - Grafana:       ${module.monitoring.grafana_url}
      Username: admin
      Password: admin123
    - AlertManager:  ${module.monitoring.alertmanager_url}
    
    APPLICATIONS:
    - WordPress:     ${module.k3s_cluster.master_primary_public_ip}:30080
    
    SSH ACCESS:
    ssh -i ${var.ssh_private_key_path} ubuntu@${module.k3s_cluster.master_primary_public_ip}
    
    KUBECONFIG:
    export KUBECONFIG=${abspath(path.root)}/modules/k3s-ha-cluster/kubeconfig
    kubectl get nodes
    ========================================
  EOT
}

output "debug_commands" {
  description = "Debug commands for troubleshooting"
  value = <<-EOT
    # SSH to primary master:
    ssh -i ${var.ssh_private_key_path} ubuntu@${module.k3s_cluster.master_primary_public_ip}
    
    # SSH to secondary master:
    ssh -i ${var.ssh_private_key_path} ubuntu@${module.k3s_cluster.master_secondary_public_ip}
    
    # Check cluster status:
    ssh -i ${var.ssh_private_key_path} ubuntu@${module.k3s_cluster.master_primary_public_ip} 'sudo kubectl get nodes -o wide'
    
    # Check monitoring pods:
    ssh -i ${var.ssh_private_key_path} ubuntu@${module.k3s_cluster.master_primary_public_ip} 'sudo kubectl get pods -n monitoring'
    
    # Check K3s logs on masters:
    ssh -i ${var.ssh_private_key_path} ubuntu@${module.k3s_cluster.master_primary_public_ip} 'sudo journalctl -u k3s -n 50'
  EOT
}