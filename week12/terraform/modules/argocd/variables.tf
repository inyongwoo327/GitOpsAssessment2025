variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "cluster_ready_trigger" {
  description = "Trigger to ensure cluster is ready"
  type        = any
}