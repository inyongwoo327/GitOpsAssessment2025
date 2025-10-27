# K3s High-Availability Cluster on AWS

Production-ready Kubernetes (K3s) cluster with HA control plane and GitOps (ArgoCD).

## Features

- ✅ **High Availability**: 2 master nodes (no single point of failure)
- ✅ **Modular Design**: Organized Terraform modules
- ✅ **GitOps**: ArgoCD

## Architecture
```
AWS VPC (10.0.0.0/16)
├── Control Plane (HA)
│   ├── Master 1 (Primary)   - t3.medium
│   └── Master 2 (Secondary) - t3.medium
├── Worker Nodes
│   ├── Worker 1 - t3.small
│   └── Worker 2 - t3.small
├── GitOps
│   ├── Prometheus  :30090
│   ├── Grafana     :30300
│   └── AlertManager :30093
|   └── ArgoCD      :30080
└── Applications
    └── WordPress   :30081
```

```
Terraform (One Command: terraform apply)
├── Infrastructure Layer
│   ├── VPC, Subnets, Security Groups (Declarative ✅)
│   └── EC2 Instances (Declarative ✅)
│
├── K3s Installation (Imperative ⚠️)
│   ├── null_resource + file provisioner (uploads scripts)
│   └── null_resource + remote-exec (runs scripts)
│
├── ArgoCD Installation (Mixed 🔀)
│   ├── helm_release resource (Declarative ✅)
│   └── null_resource + kubectl (Imperative ⚠️)
│
└── ArgoCD Applications (Imperative ⚠️)
    └── null_resource + kubectl apply (Imperative)
```

## Prerequisites

- AWS Account with credentials configured
- Terraform >= 1.5.0
- SSH key pair in AWS
- kubectl (optional)

## Quick Start

### 1. Bootstrap Backend (First Time Only)
```bash
cd bootstrap
terraform init
terraform apply
cd ..
```

### 2. Configure Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
```

Required variables:
```terraform
aws_region           = "eu-west-1"
local_ip             = "YOUR_IP/32"        # Get: curl ifconfig.me
key_name             = "your-key-name"
ssh_private_key_path = "~/.ssh/your-key.pem"
```

### 3. Deploy
```bash
terraform init
terraform plan
terraform apply
```

⏱️ Deployment time: ~15-20 minutes

### 4. Access Cluster
```bash
export KUBECONFIG=$(pwd)/modules/k3s-ha-cluster/kubeconfig
kubectl get nodes
```

## Access Information

After deployment:

**Monitoring:**
- Prometheus: `http://<MASTER_IP>:30090`
- Grafana: `http://<MASTER_IP>:30300` (admin/admin123)
- AlertManager: `http://<MASTER_IP>:30093`

**WordPress:**
- URL: `http://<MASTER_IP>:30081`
- Username: `admin`
- Password: `ssh -i ~/.ssh/test.pem ubuntu@<MASTER_IP> 'cat ~/wordpress-password.txt'`

**ArgoCD:**
- URL: `http://<MASTER_IP>:30080`
- Username: `admin`
- Password: Run 'terraform output -raw argocd_admin_password'

**SSH:**
```bash
ssh -i ~/.ssh/test.pem ubuntu@
```

## Project Structure
```
week12
├── bootstrap
│   ├── bootstrap.tf
│   ├── destroy.sh
│   ├── README.md
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf
├── k8s-manifests
│   └── argocd-apps
│       ├── prometheus-app.yaml
│       └── wordpress-app.yaml
├── README.md
├── scripts
│   └── k3s-setup
│       ├── get_kubeconfig.sh
│       ├── install_k3s_primary.sh
│       ├── install_k3s_secondary.sh
│       └── install_k3s_worker.sh
└── terraform
    ├── argocd-password.txt
    ├── backend.tf
    ├── main.tf
    ├── modules
    │   ├── argocd
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── k3s-ha-cluster
    │   │   ├── kubeconfig
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── network
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars
    ├── terraform.tfvars.example
    └── variables.tf
```

## Useful Commands
```bash
# Check cluster
kubectl get nodes
kubectl get pods -A

# Check monitoring
kubectl get pods -n monitoring

# Check WordPress
kubectl get pods -n wordpress

# View logs
kubectl logs -n monitoring 
```

## Troubleshooting

**SSH timeout:**
- Update `local_ip` in terraform.tfvars with current IP

**Pods pending:**
```bash
kubectl describe nodes
kubectl describe pod  -n 
```

**Check logs:**
```bash
ssh -i ~/.ssh/test.pem ubuntu@
sudo journalctl -u k3s -n 50
```

## Cleanup
```bash
cd terraform
terraform destroy
```

To also remove backend:
```bash
cd bootstrap
terraform destroy
```

## Requirements Met

✅ High-availability control plane (2 masters)  
✅ Organized folder structure (modular)  
✅ ArgoCD deployed

## Support

For issues:
1. Check troubleshooting section
2. Review Terraform/kubectl logs
3. Open an issue