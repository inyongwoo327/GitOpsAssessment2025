variable "master_ip" {
  description = "Master node public IP"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}

variable "cluster_ready_trigger" {
  description = "Dependency trigger to ensure cluster is ready"
  type        = any
}