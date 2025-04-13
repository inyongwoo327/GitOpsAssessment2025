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

resource "template_file" "web-userdata" {
    filename = ""
}

resource "aws_instance" "controller" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]

  user_data = "${file("controller_user_data.sh")}"
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

  user_data = "${file("worker_user_data.sh")}"
  tags = {
    Name = "Worker Node Instance"
  }
}