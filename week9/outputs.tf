output "manager_public_ip" {
    value = aws_instance.controller.public_ip
}

output "worker_public_ips" {
  value = [aws_instance.worker[*].public_ip]
}