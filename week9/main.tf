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
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.local_ip]
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
    from_port        = 4789
    to_port          = 4789
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public_subnet.cidr_block]
  }
  
  ingress {
    from_port        = 7946
    to_port          = 7946
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public_subnet.cidr_block]
    description      = "Swarm node discovery (TCP)"
  }

  ingress {
    from_port        = 7946
    to_port          = 7946
    protocol         = "udp"
    cidr_blocks      = [aws_subnet.public_subnet.cidr_block]
    description      = "Swarm node discovery (UDP)"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "controller" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e  # Exit on error
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log output

              echo "Starting user-data script"

              # Update package list
              sudo apt update -y
              if [ $? -ne 0 ]; then
                echo "Failed to update package list"
                exit 1
              fi

              # Install prerequisites
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              if [ $? -ne 0 ]; then
                echo "Failed to install prerequisites"
                exit 1
              fi

              # Set up Docker's APT repository
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Update package list again
              sudo apt update -y
              if [ $? -ne 0 ]; then
                echo "Failed to update package list after adding Docker repo"
                exit 1
              fi
              
              # Install Docker
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              if [ $? -ne 0 ]; then
                echo "Failed to install Docker"
                exit 1
              fi

              # Start and enable Docker
              sudo systemctl start docker
              sudo systemctl enable docker.service

              # Add ubuntu user to docker group
              sudo usermod -a -G docker ubuntu

              # Initialize Docker Swarm
              sudo docker swarm init
              if [ $? -ne 0 ]; then
                echo "Failed to initialize Docker Swarm"
                exit 1
              fi

              echo "user-data script completed successfully"
              EOF
  tags = {
    Name = "Controller Node Instance"
  }
}

resource "aws_instance" "worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name = var.key_name
  count = 2
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e  # Exit on error
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log output

              echo "Starting user-data script"

              # Update package list
              sudo apt update -y
              if [ $? -ne 0 ]; then
                echo "Failed to update package list"
                exit 1
              fi

              # Install prerequisites
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              if [ $? -ne 0 ]; then
                echo "Failed to install prerequisites"
                exit 1
              fi

              # Set up Docker's APT repository
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Update package list again
              sudo apt update -y
              if [ $? -ne 0 ]; then
                echo "Failed to update package list after adding Docker repo"
                exit 1
              fi
              
              # Install Docker
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              if [ $? -ne 0 ]; then
                echo "Failed to install Docker"
                exit 1
              fi

              # Start and enable Docker
              sudo systemctl start docker
              sudo systemctl enable docker.service

              # Add ubuntu user to docker group
              sudo usermod -a -G docker ubuntu

              echo "user-data script completed successfully"
              EOF
  tags = {
    Name = "Worker Node Instance"
  }
}