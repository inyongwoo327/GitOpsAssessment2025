# ArgoCD Module - Declarative Installation
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

# Configure providers to use the kubeconfig passed from parent
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install ArgoCD via Helm (declarative!)
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"  # Latest stable
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

  # Resource limits for efficiency
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

# Get ArgoCD initial admin password (using data source - more declarative)
data "kubernetes_secret" "argocd_initial_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [time_sleep.wait_for_argocd]
}

# Apply ArgoCD Applications (declarative!)
resource "kubernetes_manifest" "wordpress_app" {
  manifest = yamldecode(file("${path.root}/../k8s-manifests/argocd-apps/wordpress-app.yaml"))

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "prometheus_app" {
  manifest = yamldecode(file("${path.root}/../k8s-manifests/argocd-apps/prometheus-app.yaml"))

  depends_on = [helm_release.argocd]
}