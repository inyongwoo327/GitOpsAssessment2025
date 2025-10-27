output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_initial_password" {
  description = "ArgoCD initial admin password"
  value       = data.kubernetes_secret.argocd_initial_password.data["password"]
  sensitive   = true
}

output "argocd_server_deployed" {
  description = "Indicator that ArgoCD server is deployed"
  value       = helm_release.argocd.status == "deployed"
}