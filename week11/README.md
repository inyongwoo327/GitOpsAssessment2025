# K3s High-Availability Cluster on AWS

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s-326CE5?logo=kubernetes)](https://k3s.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

Production-ready, highly-available Kubernetes cluster using K3s on AWS with complete observability stack.

## Features

- ✅ **High Availability**: 2 master nodes with automatic failover (no single point of failure)
- ✅ **Complete Monitoring**: Prometheus, Grafana, and AlertManager pre-configured
- ✅ **Modular Design**: Reusable Terraform modules for easy customization
- ✅ **Production Ready**: Organized structure, documented code, best practices
- ✅ **Cost Effective**: ~$90-100/month for full HA setup

## Architecture
┌─────────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.0.0/16)                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         HA Control Plane (2 Masters)                 │  │
│  │                                                       │  │
│  │   ┌──────────────┐         ┌──────────────┐         │  │
│  │   │  Master 1    │◄───────►│  Master 2    │         │  │
│  │   │  (Primary)   │  etcd   │ (Secondary)  │         │  │
│  │   │  t3.medium   │  sync   │  t3.medium   │         │  │
│  │   └──────┬───────┘         └──────┬───────┘         │  │
│  │          │                         │                  │  │
│  └──────────┼─────────────────────────┼──────────────────┘  │
│             │                         │                     │
│             └────────────┬────────────┘                     │
│                          │                                  │
│  ┌───────────────────────┴────────────────────────────┐    │
│  │              Worker Nodes (2)                      │    │
│  │                                                     │    │
│  │   ┌──────────────┐         ┌──────────────┐       │    │
│  │   │  Worker 1    │         │  Worker 2    │       │    │
│  │   │  t3.small    │         │  t3.small    │       │    │
│  │   └──────────────┘         └──────────────┘       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  📊 Monitoring: Prometheus, Grafana, AlertManager          │
│  🌐 Applications: WordPress                                 │
└─────────────────────────────────────────────────────────────┘

## Prerequisites

- **AWS Account** with appropriate permissions
- **Terraform** >= 1.5.0
- **AWS CLI** configured with credentials
- **SSH Key Pair** created in AWS EC2
- **kubectl** (optional, for cluster management)

## Quick Start

1. Bootstrap Backend (First Time Only)

cd bootstrap
terraform init
terraform apply
cd ..

2. Configure Variables

cd terraform
cp terraform.tfvars.example terraform.tfvars

Edit terraform.tfvars with your values
Required variables:

terraformaws_region            = "eu-west-1"
local_ip              = "YOUR_IP/32"        # Get with: curl ifconfig.me
key_name              = "your-key-name"
ssh_private_key_path  = "~/.ssh/your-key.pem"
master_instance_type  = "t3.medium"
worker_instance_type  = "t3.small"
worker_count          = 2

3. Deploy Infrastructure
bashterraform init
terraform plan
terraform apply
⏱️ Deployment time: ~15-20 minutes

4. Access Your Cluster
bash# Export kubeconfig
export KUBECONFIG=$(pwd)/modules/k3s-ha-cluster/kubeconfig

kubectl get nodes

kubectl get pods -A
Access Information
After deployment, access your services:
Monitoring Stack

Prometheus: http://<MASTER_IP>:30090
Grafana: http://<MASTER_IP>:30300

Username: admin
Password: admin123


AlertManager: http://<MASTER_IP>:30093

WordPress Application

URL: http://<MASTER_IP>:30080
Username: admin
Password: SSH to master and run cat ~/wordpress-password.txt

SSH Access
bash# Primary Master
ssh -i ~/.ssh/test.pem ubuntu@<PRIMARY_MASTER_IP>

Check Secondary Master.

ssh -i ~/.ssh/test.pem ubuntu@<SECONDARY_MASTER_IP>
Project Structure
week11/
├── terraform/              # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── network/       # VPC, Subnets, Security Groups
│       ├── k3s-ha-cluster/ # K3s HA setup
│       └── monitoring/    # Prometheus stack
├── scripts/
│   └── deployment/        # Deployment scripts
├── bootstrap/             # Backend infrastructure
└── README.md
Monitoring
Access Grafana at http://<MASTER_IP>:30300 with credentials admin/admin123.
Pre-configured Dashboards:

Kubernetes Cluster Overview
Node Exporter Full
Kubernetes Pods
Persistent Volumes

Prometheus Targets:

API Servers (both masters)
kubelets (all nodes)
Node Exporters
kube-state-metrics

Troubleshooting
Check Cluster Status
bashexport KUBECONFIG=terraform/modules/k3s-ha-cluster/kubeconfig
kubectl get nodes
kubectl get pods -A
Check Master Logs
bashssh -i ~/.ssh/test.pem ubuntu@<MASTER_IP> 'sudo journalctl -u k3s -n 50'
Check Worker Logs
bashssh -i ~/.ssh/test.pem ubuntu@<WORKER_IP> 'sudo journalctl -u k3s-agent -n 50'
Common Issues
Issue: SSH connection timeout

Solution: Update local_ip in terraform.tfvars with your current IP

Issue: Pods stuck in Pending

Solution: Check node resources: kubectl describe nodes

Issue: Image pull errors

Solution: Check internet connectivity from nodes

Cleanup
To destroy all infrastructure:
bashcd terraform
terraform destroy
To also remove the backend infrastructure:
bashcd bootstrap
terraform destroy

Cost Breakdown
Estimated monthly AWS costs (eu-west-1):
ResourceTypeQuantityCost/MonthMaster Nodest3.medium2~$60Worker Nodest3.small2~$30Data Transfer--~$5-10Total~$90-100
Requirements Met
This infrastructure satisfies the following requirements:
✅ High-availability control plane (2 master nodes)
✅ Better organized folder structure (modular design)
✅ kube-prometheus-stack deployed via Helm
Architecture Highlights

No Single Point of Failure: 2 masters with synchronized etcd
Automatic Failover: Workers connect to available master
Complete Observability: Full metrics, logs, and dashboards
Scalable Design: Easy to add more workers or masters
Production Ready: Security groups, proper networking, monitoring

Useful Commands
bash# Get cluster info
kubectl cluster-info

View all resources

kubectl get all -A

Check monitoring stack

kubectl get pods -n monitoring

Check WordPress

kubectl get pods -n wordpress

Get service endpoints

kubectl get svc -A

View Grafana password

kubectl get secret -n monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

## License
MIT