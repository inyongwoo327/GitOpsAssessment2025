# K3s High-Availability Cluster on AWS

Production-ready Kubernetes (K3s) cluster with HA control plane and complete observability.

## Features

- ✅ **High Availability**: 2 master nodes (no single point of failure)
- ✅ **Complete Monitoring**: Prometheus, Grafana, AlertManager
- ✅ **Modular Design**: Organized Terraform modules
- ✅ **Cost Effective**: ~$90-100/month

## Architecture
```
AWS VPC (10.0.0.0/16)
├── Control Plane (HA)
│   ├── Master 1 (Primary)   - t3.medium
│   └── Master 2 (Secondary) - t3.medium
├── Worker Nodes
│   ├── Worker 1 - t3.small
│   └── Worker 2 - t3.small
├── Monitoring Stack
│   ├── Prometheus  :30090
│   ├── Grafana     :30300
│   └── AlertManager :30093
└── Applications
    └── WordPress   :30080
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
- URL: `http://<MASTER_IP>:30080`
- Username: `admin`
- Password: `ssh -i ~/.ssh/test.pem ubuntu@<MASTER_IP> 'cat ~/wordpress-password.txt'`

**SSH:**
```bash
ssh -i ~/.ssh/test.pem ubuntu@
```

## Project Structure
```
week11/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── network/           # VPC, Subnets, Security Groups
│       ├── k3s-ha-cluster/    # 2 Masters + 2 Workers
│       └── monitoring/        # Prometheus Stack
├── scripts/
│   └── deployment/
│       └── wordpress_deployment.sh
└── bootstrap/                 # S3 + DynamoDB backend
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

## Cost

Monthly AWS costs (eu-west-1):
- 2x t3.medium (masters): ~$60
- 2x t3.small (workers): ~$30
- Data transfer: ~$5-10
- **Total: ~$90-100/month**

## Requirements Met

✅ High-availability control plane (2 masters)  
✅ Organized folder structure (modular)  
✅ kube-prometheus-stack deployed  

## Support

For issues:
1. Check troubleshooting section
2. Review Terraform/kubectl logs
3. Open an issue