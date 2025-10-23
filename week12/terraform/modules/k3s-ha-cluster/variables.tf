variable "cluster_name" {
  description = "Name of the K3s cluster"
  type        = string
}

variable "master_instance_type" {
  description = "EC2 instance type for master nodes"
  type        = string
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for cluster nodes"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for cluster nodes"
  type        = string
}