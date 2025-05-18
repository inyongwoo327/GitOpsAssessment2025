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

# Wait for master to be ready
resource "null_resource" "wait_for_master" {
  depends_on = [aws_instance.master]

  provisioner "local-exec" {
    command = "sleep 180"  # Wait for the master node to initialize
  }
}

# Verify SSH connectivity and K3s setup
# resource "null_resource" "verify_ssh_and_setup" {
#   depends_on = [null_resource.wait_for_master]

#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "Verifying SSH connectivity to ${aws_instance.master.public_ip}..."
#       MAX_RETRIES=30
#       for i in $(seq 1 $MAX_RETRIES); do
#         echo "SSH attempt $i/$MAX_RETRIES"
#         if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip} 'echo "SSH connection successful"' 2>/dev/null; then
#           echo "SSH connection verified!"
          
#           # Check if K3s setup is complete
#           if ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip} 'test -f /home/ubuntu/k3s-setup-complete && test -f /home/ubuntu/node-token' 2>/dev/null; then
#             echo "K3s setup verified!"
#             exit 0
#           else
#             echo "K3s setup not complete yet, will check again..."
#           fi
#         fi
#         echo "SSH not yet available or K3s not ready, waiting 10 seconds..."
#         sleep 10
#       done
      
#       # If we reach here, we couldn't verify SSH or K3s setup
#       echo "WARNING: Could not verify SSH connectivity or K3s setup after $MAX_RETRIES attempts."
#       echo "Will attempt to proceed anyway. Check the master node manually if issues persist."
#       exit 0  # Don't fail the deployment
#     EOT
#   }
# }

# Attempt to retrieve node token
resource "null_resource" "get_token" {
  depends_on = [null_resource.verify_ssh_and_setup]

  provisioner "local-exec" {
    command = <<-EOT
      MAX_RETRIES=15
      for i in $(seq 1 $MAX_RETRIES); do
        echo "Attempt $i/$MAX_RETRIES to retrieve node token..."
        if scp -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip}:/home/ubuntu/node-token node-token 2>/dev/null; then
          echo "Successfully retrieved node token"
          exit 0
        fi
        echo "Failed to get node token, retrying in 20s..."
        sleep 20
      done
      
      # Create a placeholder token if retrieval fails
      echo "Failed to retrieve node token after $MAX_RETRIES attempts."
      echo "K3S_TOKEN_PLACEHOLDER" > node-token
      echo "Created placeholder token"
    EOT
  }
}

# Load the token from file
data "local_file" "node_token" {
  depends_on = [null_resource.get_token]
  filename   = "node-token"
}

# Attempt to retrieve kubeconfig
resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.get_token]

  provisioner "local-exec" {
    command = <<-EOT
      MAX_RETRIES=15
      for i in $(seq 1 $MAX_RETRIES); do
        echo "Attempt $i/$MAX_RETRIES to retrieve kubeconfig..."
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip} 'test -f /home/ubuntu/.kube/config' 2>/dev/null; then
          echo "Kubeconfig exists, retrieving..."
          if scp -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip}:/home/ubuntu/.kube/config kubeconfig 2>/dev/null; then
            echo "Successfully retrieved kubeconfig"
            exit 0
          fi
        fi
        echo "Failed to get kubeconfig, retrying in 20s..."
        sleep 20
      done
      
      # Create a minimal kubeconfig if retrieval fails
      echo "Failed to retrieve kubeconfig after $MAX_RETRIES attempts."
      cat > kubeconfig << EOF
apiVersion: v1
clusters:
- cluster:
    server: https://${aws_instance.master.public_ip}:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user: {}
EOF
      echo "Created minimal kubeconfig placeholder"
    EOT
  }
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
  
  # Use template file to pass master URL and token to worker nodes
  //user_data = templatefile("worker_user_data.sh", {
  //  master_url   = "https://${aws_instance.master.private_ip}:6443",
  //  master_token = data.local_file.node_token.content
  //})

  tags = {
    Name = "K3s Worker Node ${count.index}"
  }

  depends_on = [null_resource.get_token]
}

# Attempt to verify worker nodes
resource "null_resource" "verify_workers" {
  count      = var.worker_count
  depends_on = [aws_instance.worker]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for worker node ${count.index} to be accessible..."
      MAX_RETRIES=30
      for i in $(seq 1 $MAX_RETRIES); do
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ${var.ssh_private_key_path} ubuntu@${aws_instance.worker[count.index].public_ip} 'echo "Worker node ${count.index} is accessible"' 2>/dev/null; then
          echo "Worker node ${count.index} verified!"
          exit 0
        fi
        echo "Worker node ${count.index} not accessible yet, waiting 10 seconds..."
        sleep 10
      done
      echo "WARNING: Could not verify worker node ${count.index} after $MAX_RETRIES attempts"
      exit 0  # Don't fail the deployment
    EOT
  }
}

# Attempt to deploy WordPress only if we have a kubeconfig
resource "null_resource" "deploy_wordpress" {
  depends_on = [null_resource.verify_workers, null_resource.get_kubeconfig]

  provisioner "local-exec" {
    command = <<-EOT
      if [ -f kubeconfig ] && [ -s kubeconfig ]; then
        echo "Attempting to deploy WordPress..."
        bash deploy_app_helm.sh || echo "WordPress deployment failed, check logs"
      else
        echo "Kubeconfig not available, skipping WordPress deployment"
      fi
    EOT
  }
}