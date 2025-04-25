output "master_public_ip" {
  description = "Public IP address of the K3s master node"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the K3s master node"
  value       = aws_instance.master.private_ip
}

output "worker_public_ips" {
  description = "Public IP addresses of the K3s worker nodes"
  value       = aws_instance.worker[*].public_ip
}

output "kubernetes_api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://${aws_instance.master.public_ip}:6443"
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value = "http://${aws_instance.master.public_ip}/wordpress"
}