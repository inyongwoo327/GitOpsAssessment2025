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

  owners = ["099720109477"] # Canonical
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# Create Route Table
resource "aws_route_table" "rt_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "rt_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt_table.id
}

# Create Security Group
resource "aws_security_group" "security_group_ec2" {
  name        = "security_group_ec2"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # SSH access from anywhere (for testing, restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access for WordPress
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # NodePort access
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort range"
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API"
  }

  # Allow all internal traffic within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Internal VPC traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# K3s master instance
resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.master_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.security_group_ec2.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  user_data                   = file("master_user_data.sh")

  tags = {
    Name = "K3s Master Node"
  }

  # Simple initial wait to avoid immediate SSH attempts
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# Wait for master to be ready and retrieve node token
resource "null_resource" "get_master_token" {
  depends_on = [aws_instance.master]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for master node to be ready and collecting token..."
      MAX_RETRIES=5
      for i in $(seq 1 $MAX_RETRIES); do
        echo "Attempt $i/$MAX_RETRIES"
        # First check SSH connectivity
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip} 'echo "SSH connection successful"' 2>/dev/null; then
          echo "SSH connection verified!"
          
          # Check if K3s is running and get the token
          if ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip} 'sudo systemctl is-active --quiet k3s && sudo cat /var/lib/rancher/k3s/server/node-token' > node-token 2>/dev/null; then
            echo "Successfully retrieved K3s token"
            # Make the token file readable
            chmod 644 node-token
            exit 0
          else
            echo "K3s not ready or token not available yet..."
          fi
        fi
        echo "Waiting 10 seconds before next attempt..."
        sleep 10
      done
      
      echo "WARNING: Could not retrieve K3s token after $MAX_RETRIES attempts."
      echo "Will attempt to proceed anyway. Check manually if issues persist."
      echo "K3S_TOKEN_PLACEHOLDER" > node-token  # Create placeholder token
      exit 0  # Don't fail the deployment
    EOT
  }
}

# Read the token file after it's been created
data "local_file" "node_token" {
  depends_on = [null_resource.get_master_token]
  filename   = "${path.module}/node-token"
}

# Generate a local copy of the worker user data (optional, for reference)
resource "local_file" "worker_user_data" {
  depends_on = [data.local_file.node_token]
  filename   = "${path.module}/generated_worker_user_data.sh"
  content    = templatefile("worker_user_data.sh", {
    MASTER_IP    = aws_instance.master.private_ip,
    master_token = trimspace(data.local_file.node_token.content),
    K3S_TOKEN    = trimspace(data.local_file.node_token.content)
  })
}

# K3s worker instances
resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.worker_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.security_group_ec2.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  
  # Use the template directly instead of referencing a file that doesn't exist yet
  user_data = templatefile("worker_user_data.sh", {
    MASTER_IP    = aws_instance.master.private_ip,
    master_token = trimspace(data.local_file.node_token.content),
    K3S_TOKEN    = trimspace(data.local_file.node_token.content)
  })

  tags = {
    Name = "K3s Worker Node ${count.index}"
  }

  depends_on = [null_resource.get_master_token]
}

# Retrieve kubeconfig from master
resource "null_resource" "get_kubeconfig" {
  depends_on = [aws_instance.master, null_resource.get_master_token]

  provisioner "local-exec" {
    command = "${path.module}/get_kubeconfig.sh ${var.ssh_private_key_path} ${aws_instance.master.public_ip}"
  }
}

# Deploy wordpress using helm inside the master node
resource "null_resource" "deploy_wordpress" {
  depends_on = [null_resource.get_kubeconfig, aws_instance.worker]

  provisioner "local-exec" {
    command = "${path.module}/upload_and_deploy.sh ${var.ssh_private_key_path} ${aws_instance.master.public_ip}"
  }
}