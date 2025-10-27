variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "cluster_ready_trigger" {
  description = "Trigger to ensure cluster is ready"
  type        = any
}

variable "master_ip" {
  description = "Master node public IP for SSH connection"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}