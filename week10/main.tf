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

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

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

resource "aws_route_table_association" "rt_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt_table.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_security_group" "security_group_ec2" {
  name        = "security_group_ec2"
  description = "Allow required K3s traffic and management access"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
    description      = "SSH access"
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
    description      = "HTTPS access"
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
    description      = "HTTP access"
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
  }

  ingress {
    from_port        = 2377
    to_port          = 2377
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public_subnet.cidr_block]
  }
  
  ingress {
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip, aws_subnet.public_subnet.cidr_block]
    description      = "Kubernetes API server"
  }

  # Allow all traffic within the subnet for K3s nodes
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_subnet.public_subnet.cidr_block]
    description      = "All internal traffic between K3s nodes"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "k3s-security-group"
  }
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.master_instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]

  user_data = "${file("master_user_data.sh")}"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "K3s-Master-Node"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

data "external" "k3s_token" {
  program = ["bash", "-c", "sleep 120 && ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip} 'cat /home/ubuntu/node-token' | tr -d '\n' | jq -R '{token: .}'"]
  depends_on = [aws_instance.master]
}

resource "aws_instance" "worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name = var.key_name
  count = 2
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]

  user_data = templatefile("worker_user_data.sh", {
    master_url   = "https://${aws_instance.master.private_ip}:6443",
    master_token = data.external.k3s_token.result.token
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "K3s-Worker-Node-${count.index + 1}"
  }

  depends_on = [aws_instance.master, data.external.k3s_token]
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "bash kubeconfig_setup.sh ${aws_instance.master.public_ip} ${var.ssh_private_key_path}"
  }

  depends_on = [aws_instance.master]
}

resource "null_resource" "deploy_wordpress" {
  provisioner "local-exec" {
    command = "sh scripts/deploy_wordpress.sh"
  }

  depends_on = [ 
    null_resource.kubeconfig,
    aws_instance.worker
  ]
}