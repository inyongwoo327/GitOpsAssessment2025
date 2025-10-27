output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = "argocd"
}

output "argocd_initial_password" {
  description = "ArgoCD initial admin password file location"
  value       = "Check argocd-password.txt in terraform directory"
  sensitive   = false
}

output "argocd_installed" {
  description = "Indicator that ArgoCD is installed"
  value       = null_resource.install_argocd.id != "" ? true : false
}