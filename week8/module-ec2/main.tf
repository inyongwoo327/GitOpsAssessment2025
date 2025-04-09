variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = null
}

data "aws_ami" "ubuntu" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "sample" {
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
            EOF

  tags = {
    Name = "${var.instance_name_prefix}-${var.instance_index}"
  }
}

resource "aws_security_group" "security_group_ec2" {
  name        = "security_group_ec2-${var.instance_index}"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "sample_launch_template" {
  name_prefix   = "launch-template-${var.instance_index}-"
  image_id      = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu[0].id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.security_group_ec2.id]
  }
}

resource "aws_autoscaling_group" "autoscale" {
  name                = "autoscale-${var.instance_index}"
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.sample_launch_template.id
      }
      override {
        instance_type     = var.instance_type
        weighted_capacity = "2"
      }
      override {
        instance_type     = var.instance_type_another
        weighted_capacity = "1"
      }
    }
  }
}