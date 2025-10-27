terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Kubernetes and Helm providers
# These will only work after the kubeconfig is created by the k3s_cluster module
# Terraform handles the dependency through the module references
provider "kubernetes" {
  config_path = "~/.kube/config"  # Placeholder, will be overridden by actual kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Placeholder, will be overridden by actual kubeconfig
  }
}