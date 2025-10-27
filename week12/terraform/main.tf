module "network" {
  source = "./modules/network"

  project_name       = "k3s-ha-cluster"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  allowed_ssh_cidr   = var.local_ip
}

module "k3s_cluster" {
  source = "./modules/k3s-ha-cluster"

  cluster_name          = "k3s-ha-production"
  master_instance_type  = var.master_instance_type
  worker_instance_type  = var.worker_instance_type
  worker_count          = var.worker_count
  key_name              = var.key_name
  ssh_private_key_path  = var.ssh_private_key_path
  security_group_id     = module.network.security_group_id
  subnet_id             = module.network.public_subnet_id

  depends_on = [module.network]
}

# Deploy ArgoCD - no depends_on here
module "argocd" {
  source = "./modules/argocd"

  kubeconfig_path       = module.k3s_cluster.kubeconfig_path
  cluster_ready_trigger = module.k3s_cluster.kubeconfig_path

  # Remove depends_on - the kubeconfig_path dependency handles this
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}