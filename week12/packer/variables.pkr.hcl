# Packer Variables Configuration
# These variables can be overridden via command line or environment variables

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region where the AMI will be created"
}

variable "ami_name_prefix" {
  type        = string
  default     = "k3s-ha-node"
  description = "Prefix for the AMI name (timestamp will be appended)"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type to use for building the AMI"
}

variable "k3s_version" {
  type        = string
  default     = "v1.28.5+k3s1"
  description = "K3s version to prepare for installation"
}

variable "source_ami_owner" {
  type        = string
  default     = "099720109477"
  description = "AWS account ID for Canonical (Ubuntu official images)"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username for connecting to the instance"
}

variable "subnet_id" {
  type        = string
  default     = "subnet-022e85f69a01a4d68"
  description = "Subnet for building AMI"
}