variable "ami_name_prefix" {
  type        = string
  default     = "k3s-ha-node"
  description = "Prefix for the AMI name"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for building the AMI"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for building the AMI"
}

variable "k3s_version" {
  type        = string
  default     = "v1.28.5+k3s1"
  description = "K3s version to install"
}

variable "source_ami_owner" {
  type        = string
  default     = "099720109477"  # Back to Canonical Ubuntu
  description = "Owner ID for source AMI"
}

variable "subnet_id" {
  type        = string
  default     = "subnet-022e85f69a01a4d68"
  description = "Subnet for building AMI"
}