variable "aws_region" {
  default = "eu-west-1"
}

variable "master_instance_type" {
  description = "EC2 instance type for K3s master node"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for K3s worker nodes"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Number of K3s worker nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  type        = string
  default = "test"
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key file on local machine"
  type        = string
  default     = "~/.ssh/test.pem"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "local_ip" {
  description = "Local CIDR"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "eu-west-1a"
}