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

# Upload K3s installation script
resource "null_resource" "upload_k3s_scripts" {
  depends_on = [aws_instance.master_primary]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.master_primary.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.root}/../scripts/k3s-setup/install_k3s_primary.sh"
    destination = "/home/ubuntu/install_k3s_primary.sh"
  }
}

# Install K3s on primary master
resource "null_resource" "install_k3s_primary" {
  depends_on = [null_resource.upload_k3s_scripts]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.master_primary.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install_k3s_primary.sh",
      "/home/ubuntu/install_k3s_primary.sh ${aws_instance.master_primary.public_ip} ${aws_instance.master_primary.private_ip}"
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

# Upload secondary script
resource "null_resource" "upload_k3s_secondary_script" {
  depends_on = [aws_instance.master_secondary]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.master_secondary.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.root}/../scripts/k3s-setup/install_k3s_secondary.sh"
    destination = "/home/ubuntu/install_k3s_secondary.sh"
  }
}

# Install K3s on secondary master
resource "null_resource" "install_k3s_secondary" {
  depends_on = [
    null_resource.upload_k3s_secondary_script,
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
      "chmod +x /home/ubuntu/install_k3s_secondary.sh",
      "/home/ubuntu/install_k3s_secondary.sh ${aws_instance.master_primary.private_ip} '${data.external.k3s_token.result.token}'"
    ]
  }
}

# Worker Nodes
resource "aws_instance" "worker" {
  count      = var.worker_count
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

# Upload worker scripts
resource "null_resource" "upload_k3s_worker_scripts" {
  count      = var.worker_count
  depends_on = [aws_instance.worker]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = aws_instance.worker[count.index].public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.root}/../scripts/k3s-setup/install_k3s_worker.sh"
    destination = "/home/ubuntu/install_k3s_worker.sh"
  }
}

# Install K3s on workers
resource "null_resource" "install_k3s_workers" {
  count = var.worker_count
  depends_on = [
    null_resource.upload_k3s_worker_scripts,
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
      "chmod +x /home/ubuntu/install_k3s_worker.sh",
      "/home/ubuntu/install_k3s_worker.sh ${count.index + 1} ${aws_instance.master_primary.private_ip} '${data.external.k3s_token.result.token}'"
    ]
  }
}

# Get kubeconfig using script
resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.install_k3s_workers]

  provisioner "local-exec" {
    command = "${path.root}/../scripts/k3s-setup/get_kubeconfig.sh ${var.ssh_private_key_path} ${aws_instance.master_primary.public_ip} ${path.module}/kubeconfig"
  }
}

# Wait for kubeconfig to be available
resource "time_sleep" "wait_for_kubeconfig" {
  depends_on = [null_resource.get_kubeconfig]
  create_duration = "10s"
}