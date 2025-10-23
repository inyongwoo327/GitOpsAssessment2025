output "master_primary_public_ip" {
  description = "Public IP of primary master"
  value       = aws_instance.master_primary.public_ip
}

output "master_primary_private_ip" {
  description = "Private IP of primary master"
  value       = aws_instance.master_primary.private_ip
}

output "master_secondary_public_ip" {
  description = "Public IP of secondary master"
  value       = aws_instance.master_secondary.public_ip
}

output "master_secondary_private_ip" {
  description = "Private IP of secondary master"
  value       = aws_instance.master_secondary.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of worker nodes"
  value       = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = aws_instance.worker[*].private_ip
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = "${path.module}/kubeconfig"
  depends_on  = [null_resource.get_kubeconfig]
}

output "cluster_token" {
  description = "K3s cluster token"
  value       = data.external.k3s_token.result.token
  sensitive   = true
}