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

output "debug_instructions" {
  description = "Instructions for manual debugging"
  value = <<-EOT
    # SSH into master node:
    ssh -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip}
    
    # View K3s status:
    sudo systemctl status k3s
    
    # View K3s logs:
    sudo journalctl -u k3s
    
    # Check if node token exists:
    ls -la /home/ubuntu/node-token
    
    # Check if kubeconfig exists:
    ls -la /home/ubuntu/.kube/config
  EOT
}

output "wordpress_admin_credentials" {
  description = "WordPress admin credentials"
  value = <<-EOT
    Username: user
    Password: Use 'cat wordpress-password.txt' to view the password in Master Node
    URL: http://${aws_instance.master.public_ip}:30080
  EOT

  depends_on = [null_resource.deploy_wordpress]
}