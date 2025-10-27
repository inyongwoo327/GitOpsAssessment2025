# ArgoCD Module - Declarative Installation
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
      configuration_aliases = [kubernetes]
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
      configuration_aliases = [helm]
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "server.service.type"
    value = "NodePort"
  }

  set {
    name  = "server.service.nodePortHttp"
    value = "30080"
  }

  set {
    name  = "server.service.nodePortHttps"
    value = "30443"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "repoServer.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "repoServer.resources.limits.memory"
    value = "256Mi"
  }

  timeout = 600
  wait    = true

  depends_on = [kubernetes_namespace.argocd]
}

# Wait for ArgoCD to be ready
resource "time_sleep" "wait_for_argocd" {
  depends_on      = [helm_release.argocd]
  create_duration = "30s"
}

# Get ArgoCD initial admin password
data "kubernetes_secret" "argocd_initial_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [time_sleep.wait_for_argocd]
}

# Apply ArgoCD Applications via kubectl command
resource "null_resource" "apply_argocd_apps" {
  depends_on = [helm_release.argocd, time_sleep.wait_for_argocd]

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubeconfig_path}
      echo "Waiting for cluster to be fully ready..."
      sleep 20
      echo "Applying ArgoCD applications..."
      kubectl apply -f ${path.root}/../k8s-manifests/argocd-apps/wordpress-app.yaml || true
      kubectl apply -f ${path.root}/../k8s-manifests/argocd-apps/prometheus-app.yaml || true
      echo "ArgoCD applications applied"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}