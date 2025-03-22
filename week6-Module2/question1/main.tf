provider "aws" {
  region = "eu-west-1"
}

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

resource "aws_vpc" "test-env" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_ec2" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.test-env.id}"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_instance" "sample" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_ec2_instance_type
  key_name = "test"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id = aws_subnet.subnet_ec2.id

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install nginx -y
                sudo systemctl start nginx
                sudo systemctl enable nginx
              EOF

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "Security Group for EC2"
  description = "Allow SSH inbound traffic"
  vpc_id = aws_vpc.test-env.id
  //subnet_id = aws_subnet.subnet_ec2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet_ec2.cidr_block]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}