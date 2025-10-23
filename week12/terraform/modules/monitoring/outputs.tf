output "prometheus_url" {
  description = "Prometheus UI URL"
  value       = "http://${var.master_ip}:30090"
}

output "grafana_url" {
  description = "Grafana UI URL"
  value       = "http://${var.master_ip}:30300"
}

output "grafana_credentials" {
  description = "Grafana login credentials"
  value = {
    username = "admin"
    password = "admin123"
  }
  sensitive = true
}

output "alertmanager_url" {
  description = "AlertManager UI URL"
  value       = "http://${var.master_ip}:30093"
}