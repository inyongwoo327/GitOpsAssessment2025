data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Primary Master
resource "aws_instance" "master_primary" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.master_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "${var.cluster_name}-master-primary"
    Role = "k3s-master-primary"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # Wait for instance to be ready
  provisioner "remote-exec" {
    inline = ["echo 'Instance ready'"]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}

# Install K3s on primary master
resource "null_resource" "install_k3s_primary" {
  depends_on = [aws_instance.master_primary]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.master_primary.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo '=== Installing K3s Primary Master ==='",
      "sudo apt-get update -qq",
      "sudo apt-get install -y -qq apt-transport-https ca-certificates curl",
      
      # Create K3s config
      "sudo mkdir -p /etc/rancher/k3s",
      "cat <<EOF | sudo tee /etc/rancher/k3s/config.yaml",
      "write-kubeconfig-mode: '0644'",
      "cluster-init: true",
      "tls-san:",
      "  - ${aws_instance.master_primary.public_ip}",
      "  - ${aws_instance.master_primary.private_ip}",
      "node-ip: ${aws_instance.master_primary.private_ip}",
      "disable:",
      "  - traefik",
      "EOF",
      
      # Install K3s
      "echo 'Installing K3s...'",
      "curl -sfL https://get.k3s.io | sh -s - server",
      
      # Wait for K3s
      "echo 'Waiting for K3s to be ready...'",
      "sleep 30",
      "for i in {1..30}; do sudo systemctl is-active --quiet k3s && break || sleep 10; done",
      
      # Setup kubeconfig
      "mkdir -p $HOME/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "chmod 600 $HOME/.kube/config",
      
      # Save token
      "sudo cp /var/lib/rancher/k3s/server/node-token $HOME/node-token",
      "sudo chown ubuntu:ubuntu $HOME/node-token",
      
      "echo '=== K3s Primary Master Ready ==='",
      "sudo kubectl get nodes"
    ]
  }
}

# Get token from primary
data "external" "k3s_token" {
  depends_on = [null_resource.install_k3s_primary]
  
  program = ["bash", "-c", <<-EOT
    TOKEN=$(ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master_primary.public_ip} 'cat /home/ubuntu/node-token' 2>/dev/null)
    if [ -z "$TOKEN" ]; then
      echo '{"error": "Failed to get token"}' >&2
      exit 1
    fi
    echo "{\"token\": \"$TOKEN\"}"
  EOT
  ]
}

# Secondary Master
resource "aws_instance" "master_secondary" {
  depends_on = [null_resource.install_k3s_primary]
  
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.master_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "${var.cluster_name}-master-secondary"
    Role = "k3s-master-secondary"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Instance ready'"]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}

# Install K3s on secondary master
resource "null_resource" "install_k3s_secondary" {
  depends_on = [
    aws_instance.master_secondary,
    data.external.k3s_token
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.master_secondary.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo '=== Installing K3s Secondary Master ==='",
      "sudo apt-get update -qq",
      "sudo apt-get install -y -qq curl",
      
      # Install K3s joining the cluster
      "echo 'Joining cluster...'",
      "curl -sfL https://get.k3s.io | K3S_URL='https://${aws_instance.master_primary.private_ip}:6443' K3S_TOKEN='${data.external.k3s_token.result.token}' sh -s - server",
      
      # Wait
      "sleep 30",
      "for i in {1..30}; do sudo systemctl is-active --quiet k3s && break || sleep 10; done",
      
      "echo '=== K3s Secondary Master Ready ==='"
    ]
  }
}

# Worker Nodes
resource "aws_instance" "worker" {
  count = var.worker_count
  depends_on = [null_resource.install_k3s_secondary]

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.worker_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "${var.cluster_name}-worker-${count.index + 1}"
    Role = "k3s-worker"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Instance ready'"]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}

# Install K3s on workers
resource "null_resource" "install_k3s_workers" {
  count = var.worker_count
  depends_on = [
    aws_instance.worker,
    data.external.k3s_token
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.worker[count.index].public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo '=== Installing K3s Worker ${count.index + 1} ==='",
      "sudo apt-get update -qq",
      "sudo apt-get install -y -qq curl",
      
      # Install K3s agent
      "curl -sfL https://get.k3s.io | K3S_URL='https://${aws_instance.master_primary.private_ip}:6443' K3S_TOKEN='${data.external.k3s_token.result.token}' sh -",
      
      # Wait
      "sleep 20",
      "for i in {1..20}; do sudo systemctl is-active --quiet k3s-agent && break || sleep 10; done",
      
      "echo '=== K3s Worker ${count.index + 1} Ready ==='"
    ]
  }
}

# Get kubeconfig
resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.install_k3s_workers]

  provisioner "local-exec" {
    command = <<-EOT
      scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} \
        ubuntu@${aws_instance.master_primary.public_ip}:/home/ubuntu/.kube/config \
        ${path.module}/kubeconfig
      
      if command -v sed > /dev/null 2>&1; then
        if sed --version 2>&1 | grep -q GNU; then
          sed -i "s|https://127.0.0.1:6443|https://${aws_instance.master_primary.public_ip}:6443|g" ${path.module}/kubeconfig
        else
          sed -i '' "s|https://127.0.0.1:6443|https://${aws_instance.master_primary.public_ip}:6443|g" ${path.module}/kubeconfig
        fi
      fi
      
      chmod 600 ${path.module}/kubeconfig
      echo "Kubeconfig saved to ${path.module}/kubeconfig"
    EOT
  }
}