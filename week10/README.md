<!-- BEGIN_TF_DOCS -->
# Objective:
Create a fully functional Docker Swarm cluster on AWS using Terraform, and deploy a WordPress website with a MySQL backend on top of the cluster.
This challenge will assess your ability to provision infrastructure as code, configure a container orchestration platform (Docker Swarm), and deploy containerized applications in a secure and reproducible way.

## Documentation creation command
terraform-docs markdown table --output-file README.md --output-mode inject .  

## STEP 1: Create s3 backend (remote state) bucket first.

<details>
  <summary>Create and show s3 backend for remote state</summary>

```
bootstrap git:(main) ✗ terraform plan                                                              
aws_dynamodb_table.terraform_locks: Refreshing state... [id=module_practice_db]
aws_s3_bucket.terraform_state: Refreshing state... [id=dockerswarm-practice-bucket]
aws_s3_bucket_versioning.versioning: Refreshing state... [id=dockerswarm-practice-bucket]
aws_s3_bucket_server_side_encryption_configuration.encryption: Refreshing state... [id=dockerswarm-practice-bucket]

Your infrastructure matches the configuration.
```
</details>

## STEP 2: Create vpc, subnet, security group, ec2 with master node and worker nodes and their user data, get_token command, and route table, etc.
- After creating s3 for remote state, create vpc, subnet, security group, ec2 with user data, route table, etc.

<details>
  <summary>Show the `terraform apply --auto-approve`</summary>

```
week10 git:(patch0428) ✗ terraform apply --auto-approve
data.aws_ami.ubuntu: Reading...
data.aws_ami.ubuntu: Read complete after 0s [id=ami-0286d0aea4d6c7a34]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.local_file.node_token will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "local_file" "node_token" {
      + content              = (known after apply)
      + content_base64       = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + filename             = "./node-token"
      + id                   = (known after apply)
    }

  # aws_instance.master will be created
  + resource "aws_instance" "master" {
      + ami                                  = "ami-0286d0aea4d6c7a34"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.medium"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "test"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "K3s Master Node"
        }
      + tags_all                             = {
          + "Name" = "K3s Master Node"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "358081222966652c883ee800c1dd3bcad1955066"
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_instance.worker[0] will be created
  + resource "aws_instance" "worker" {
      + ami                                  = "ami-0286d0aea4d6c7a34"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.small"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "test"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "K3s Worker Node 0"
        }
      + tags_all                             = {
          + "Name" = "K3s Worker Node 0"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_instance.worker[1] will be created
  + resource "aws_instance" "worker" {
      + ami                                  = "ami-0286d0aea4d6c7a34"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.small"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "test"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "K3s Worker Node 1"
        }
      + tags_all                             = {
          + "Name" = "K3s Worker Node 1"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_internet_gateway.gw will be created
  + resource "aws_internet_gateway" "gw" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "main"
        }
      + tags_all = {
          + "Name" = "main"
        }
      + vpc_id   = (known after apply)
    }

  # aws_route_table.rt_table will be created
  + resource "aws_route_table" "rt_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Name" = "main-route-table"
        }
      + tags_all         = {
          + "Name" = "main-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.rt_table_association will be created
  + resource "aws_route_table_association" "rt_table_association" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.security_group_ec2 will be created
  + resource "aws_security_group" "security_group_ec2" {
      + arn                    = (known after apply)
      + description            = "Allow ssh inbound traffic and all outbound traffic"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTP access"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTPS access"
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Kubernetes API"
              + from_port        = 6443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 6443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "NodePort range"
              + from_port        = 30000
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 32767
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH access"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "10.0.0.0/16",
                ]
              + description      = "Internal VPC traffic"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + name                   = "security_group_ec2"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.public_subnet will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "Public Subnet"
        }
      + tags_all                                       = {
          + "Name" = "Public Subnet"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "main"
        }
      + tags_all                             = {
          + "Name" = "main"
        }
    }

  # local_file.worker_user_data will be created
  + resource "local_file" "worker_user_data" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./generated_worker_user_data.sh"
      + id                   = (known after apply)
    }

  # null_resource.deploy_wordpress will be created
  + resource "null_resource" "deploy_wordpress" {
      + id = (known after apply)
    }

  # null_resource.get_kubeconfig will be created
  + resource "null_resource" "get_kubeconfig" {
      + id = (known after apply)
    }

  # null_resource.get_master_token will be created
  + resource "null_resource" "get_master_token" {
      + id = (known after apply)
    }

Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + debug_instructions          = (known after apply)
  + kubernetes_api_endpoint     = (known after apply)
  + master_private_ip           = (known after apply)
  + master_public_ip            = (known after apply)
  + wordpress_admin_credentials = (known after apply)
  + worker_public_ips           = [
      + (known after apply),
      + (known after apply),
    ]
aws_vpc.main: Creating...
aws_vpc.main: Still creating... [10s elapsed]
aws_vpc.main: Creation complete after 12s [id=vpc-0d507ea02db11317d]
aws_internet_gateway.gw: Creating...
aws_subnet.public_subnet: Creating...
aws_security_group.security_group_ec2: Creating...
aws_internet_gateway.gw: Creation complete after 0s [id=igw-0aac936462306c6e4]
aws_route_table.rt_table: Creating...
aws_route_table.rt_table: Creation complete after 1s [id=rtb-05b8fe220595c74bb]
aws_security_group.security_group_ec2: Creation complete after 2s [id=sg-0bbd1f0b9faced607]
aws_subnet.public_subnet: Still creating... [10s elapsed]
aws_subnet.public_subnet: Creation complete after 11s [id=subnet-067c743f6b3845f1f]
aws_route_table_association.rt_table_association: Creating...
aws_instance.master: Creating...
aws_route_table_association.rt_table_association: Creation complete after 0s [id=rtbassoc-023b30d2418677c30]
aws_instance.master: Still creating... [10s elapsed]
aws_instance.master: Provisioning with 'local-exec'...
aws_instance.master (local-exec): Executing: ["/bin/sh" "-c" "sleep 60"]
aws_instance.master: Still creating... [20s elapsed]
aws_instance.master: Still creating... [30s elapsed]
aws_instance.master: Still creating... [40s elapsed]
aws_instance.master: Still creating... [50s elapsed]
aws_instance.master: Still creating... [1m0s elapsed]
aws_instance.master: Still creating... [1m10s elapsed]
aws_instance.master: Creation complete after 1m13s [id=i-002507373cc3a2594]
null_resource.get_master_token: Creating...
null_resource.get_master_token: Provisioning with 'local-exec'...
null_resource.get_master_token (local-exec): Executing: ["/bin/sh" "-c" "echo \"Waiting for master node to be ready and collecting token...\"\nMAX_RETRIES=5\nfor i in $(seq 1 $MAX_RETRIES); do\n  echo \"Attempt $i/$MAX_RETRIES\"\n  # First check SSH connectivity\n  if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ~/.ssh/test.pem ubuntu@34.240.75.142 'echo \"SSH connection successful\"' 2>/dev/null; then\n    echo \"SSH connection verified!\"\n          \n    # Check if K3s is running and get the token\n    if ssh -o StrictHostKeyChecking=no -i ~/.ssh/test.pem ubuntu@34.240.75.142 'sudo systemctl is-active --quiet k3s && sudo cat /var/lib/rancher/k3s/server/node-token' > node-token 2>/dev/null; then\n      echo \"Successfully retrieved K3s token\"\n      # Make the token file readable\n      chmod 644 node-token\n      exit 0\n    else\n      echo \"K3s not ready or token not available yet...\"\n    fi\n  fi\n  echo \"Waiting 10 seconds before next attempt...\"\n  sleep 10\ndone\n      \necho \"WARNING: Could not retrieve K3s token after $MAX_RETRIES attempts.\"\necho \"Will attempt to proceed anyway. Check manually if issues persist.\"\necho \"K3S_TOKEN_PLACEHOLDER\" > node-token  # Create placeholder token\nexit 0  # Don't fail the deployment\n"]
null_resource.get_master_token (local-exec): Waiting for master node to be ready and collecting token...
null_resource.get_master_token (local-exec): Attempt 1/5
null_resource.get_master_token (local-exec): SSH connection successful
null_resource.get_master_token (local-exec): SSH connection verified!
null_resource.get_master_token (local-exec): Successfully retrieved K3s token
null_resource.get_master_token: Creation complete after 3s [id=2160779480608680938]
null_resource.get_kubeconfig: Creating...
data.local_file.node_token: Reading...
data.local_file.node_token: Read complete after 0s [id=da0564a25ab8f9fd710494945a05ed00667a92e4]
null_resource.get_kubeconfig: Provisioning with 'local-exec'...
null_resource.get_kubeconfig (local-exec): Executing: ["/bin/sh" "-c" "      echo \"Retrieving kubeconfig from master node...\"\n      MAX_RETRIES=15\n      for i in $(seq 1 $MAX_RETRIES); do\n        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i ~/.ssh/test.pem ubuntu@34.240.75.142 'sudo cat /etc/rancher/k3s/k3s.yaml' > kubeconfig 2>/dev/null; then\n          echo \"Successfully retrieved kubeconfig\"\n          \n          # Get private IP to properly update kubeconfig\n          PRIVATE_IP=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/test.pem ubuntu@34.240.75.142 'hostname -I | awk \"{print \\$1}\"')\n          \n          # On macOS, sed requires an empty string parameter for in-place editing\n          sed -i '' \"s/127.0.0.1/34.240.75.142/g\" kubeconfig 2>/dev/null || \\\n          sed -i \"s/127.0.0.1/34.240.75.142/g\" kubeconfig\n          \n          # Also replace the server address if it has the private IP\n          if [ ! -z \"$PRIVATE_IP\" ]; then\n            sed -i '' \"s/$PRIVATE_IP/34.240.75.142/g\" kubeconfig 2>/dev/null || \\\n            sed -i \"s/$PRIVATE_IP/34.240.75.142/g\" kubeconfig\n          fi\n          \n          chmod 600 kubeconfig\n          exit 0\n        fi\n        echo \"Attempt $i/$MAX_RETRIES: Failed to get kubeconfig, retrying in 20s...\"\n        sleep 20\n      done\n      \n      echo \"Failed to retrieve kubeconfig after $MAX_RETRIES attempts.\"\n      echo \"Creating minimal kubeconfig placeholder\"\n      cat > kubeconfig << EOF\napiVersion: v1\nclusters:\n- cluster:\n    server: https://34.240.75.142:6443\n  name: default\ncontexts:\n- context:\n    cluster: default\n    user: default\n  name: default\ncurrent-context: default\nkind: Config\npreferences: {}\nusers:\n- name: default\n  user: {}\nEOF\n"]
null_resource.get_kubeconfig (local-exec): Retrieving kubeconfig from master node...
local_file.worker_user_data: Creating...
local_file.worker_user_data: Creation complete after 0s [id=a6ce94f8671ab890b58737d5f87eeeb742e71bd4]
aws_instance.worker[1]: Creating...
aws_instance.worker[0]: Creating...
null_resource.get_kubeconfig (local-exec): Successfully retrieved kubeconfig
null_resource.get_kubeconfig: Creation complete after 1s [id=7203611751304288849]
aws_instance.worker[1]: Still creating... [10s elapsed]
aws_instance.worker[0]: Still creating... [10s elapsed]
aws_instance.worker[0]: Creation complete after 13s [id=i-058cb0d0d4c71c00f]
aws_instance.worker[1]: Creation complete after 13s [id=i-0f86680f5801f99bc]
null_resource.deploy_wordpress: Creating...
null_resource.deploy_wordpress: Provisioning with 'local-exec'...
null_resource.deploy_wordpress (local-exec): Executing: ["/bin/sh" "-c" "echo \"Deploying WordPress using Helm (via SSH)...\"\n      \nssh -o StrictHostKeyChecking=no -i ~/.ssh/test.pem ubuntu@34.240.75.142 '\n  # Create namespace for WordPress\n  sudo kubectl create namespace wordpress\n        \n  # Install Helm if not already installed\n  if ! command -v helm &> /dev/null; then\n    echo \"Installing Helm...\"\n    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash\n  fi\n        \n  # Add Bitnami Helm repository\n  helm repo add bitnami https://charts.bitnami.com/bitnami\n  helm repo update\n        \n  # Install WordPress with MySQL\n  helm upgrade --install wordpress bitnami/wordpress \\\n    --namespace wordpress \\\n    --set service.type=NodePort \\\n    --set service.nodePorts.http=30080 \\\n    --set persistence.enabled=true \\\n    --set persistence.storageClass=\"local-path\" \\\n    --set mariadb.primary.persistence.enabled=true \\\n    --set mariadb.primary.persistence.storageClass=\"local-path\" \\\n    --version 24.2.2\n          \n  # Get WordPress credentials\n  echo \"WordPress deployment initiated! It may take several minutes to complete.\"\n  echo \"WordPress admin username: user\"\n  PASS=$(sudo kubectl get secret --namespace wordpress wordpress -o jsonpath=\"{.data.wordpress-password}\" | base64 --decode)\n  echo \"WordPress admin password: $PASS\"\n  echo \"$PASS\" > ~/wordpress-password.txt\n'\n      \necho \"WordPress URL: http://34.240.75.142:30080\"\necho \"WordPress admin password is saved in wordpress-password.txt\"\n"]
null_resource.deploy_wordpress (local-exec): Deploying WordPress using Helm (via SSH)...
null_resource.deploy_wordpress (local-exec): namespace/wordpress created
null_resource.deploy_wordpress (local-exec): Installing Helm...
null_resource.deploy_wordpress (local-exec):   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
null_resource.deploy_wordpress (local-exec):                                  Dload  Upload   Total   Spent    Left  Speed
null_resource.deploy_wordpress (local-exec):   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
null_resource.deploy_wordpress (local-exec): 100 11913  100 11913    0     0  83772      0 --:--:-- --:--:-- --:--:-- 83894
null_resource.deploy_wordpress (local-exec): Downloading https://get.helm.sh/helm-v3.18.0-linux-amd64.tar.gz
null_resource.deploy_wordpress (local-exec): Verifying checksum... Done.
null_resource.deploy_wordpress (local-exec): Preparing to install helm into /usr/local/bin
null_resource.deploy_wordpress (local-exec): helm installed into /usr/local/bin/helm
null_resource.deploy_wordpress (local-exec): "bitnami" has been added to your repositories
null_resource.deploy_wordpress (local-exec): Hang tight while we grab the latest from your chart repositories...
null_resource.deploy_wordpress (local-exec): ...Successfully got an update from the "bitnami" chart repository
null_resource.deploy_wordpress (local-exec): Update Complete. ⎈Happy Helming!⎈
null_resource.deploy_wordpress (local-exec): Release "wordpress" does not exist. Installing it now.
null_resource.deploy_wordpress: Still creating... [10s elapsed]
null_resource.deploy_wordpress (local-exec): NAME: wordpress
null_resource.deploy_wordpress (local-exec): LAST DEPLOYED: Wed May 21 18:12:40 2025
null_resource.deploy_wordpress (local-exec): NAMESPACE: wordpress
null_resource.deploy_wordpress (local-exec): STATUS: deployed
null_resource.deploy_wordpress (local-exec): REVISION: 1
null_resource.deploy_wordpress (local-exec): TEST SUITE: None
null_resource.deploy_wordpress (local-exec): NOTES:
null_resource.deploy_wordpress (local-exec): CHART NAME: wordpress
null_resource.deploy_wordpress (local-exec): CHART VERSION: 24.2.2
null_resource.deploy_wordpress (local-exec): APP VERSION: 6.7.2

null_resource.deploy_wordpress (local-exec): Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami for more information.

null_resource.deploy_wordpress (local-exec): ** Please be patient while the chart is being deployed **

null_resource.deploy_wordpress (local-exec): Your WordPress site can be accessed through the following DNS name from within your cluster:

null_resource.deploy_wordpress (local-exec):     wordpress.wordpress.svc.cluster.local (port 80)

null_resource.deploy_wordpress (local-exec): To access your WordPress site from outside the cluster follow the steps below:

null_resource.deploy_wordpress (local-exec): 1. Get the WordPress URL by running these commands:

null_resource.deploy_wordpress (local-exec):    export NODE_PORT=$(kubectl get --namespace wordpress -o jsonpath="{.spec.ports[0].nodePort}" services wordpress)
null_resource.deploy_wordpress (local-exec):    export NODE_IP=$(kubectl get nodes --namespace wordpress -o jsonpath="{.items[0].status.addresses[0].address}")
null_resource.deploy_wordpress (local-exec):    echo "WordPress URL: http://$NODE_IP:$NODE_PORT/"
null_resource.deploy_wordpress (local-exec):    echo "WordPress Admin URL: http://$NODE_IP:$NODE_PORT/admin"

null_resource.deploy_wordpress (local-exec): 2. Open a browser and access WordPress using the obtained URL.

null_resource.deploy_wordpress (local-exec): 3. Login with the following credentials below to see your blog:

null_resource.deploy_wordpress (local-exec):   echo Username: user
null_resource.deploy_wordpress (local-exec):   echo Password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)

null_resource.deploy_wordpress (local-exec): WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
null_resource.deploy_wordpress (local-exec):   - resources
null_resource.deploy_wordpress (local-exec): +info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
null_resource.deploy_wordpress (local-exec): WordPress deployment initiated! It may take several minutes to complete.
null_resource.deploy_wordpress (local-exec): WordPress admin username: user
null_resource.deploy_wordpress (local-exec): WordPress admin password: yx3H3CX3lP
null_resource.deploy_wordpress (local-exec): WordPress URL: http://34.240.75.142:30080
null_resource.deploy_wordpress (local-exec): WordPress admin password is saved in wordpress-password.txt
null_resource.deploy_wordpress: Creation complete after 15s [id=342604733919121780]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

debug_instructions = <<EOT
# SSH into master node:
ssh -i ~/.ssh/test.pem ubuntu@34.240.75.142
    
# View K3s status:
sudo systemctl status k3s
    
# View K3s logs:
sudo journalctl -u k3s
    
# Check if node token exists:
ls -la /home/ubuntu/node-token
    
# Check if kubeconfig exists:
ls -la /home/ubuntu/.kube/config

EOT
kubernetes_api_endpoint = "https://34.240.75.142:6443"
master_private_ip = "10.0.1.223"
master_public_ip = "34.240.75.142"
wordpress_admin_credentials = <<EOT
Username: user
Password: Use 'cat wordpress-password.txt' to view the password in Master Node
URL: http://34.240.75.142:30080

EOT
worker_public_ips = [
  "3.249.233.141",
  "3.254.198.86",
]
```
</details>

## STEP 3: Acess to EC2 instance with the k3s control plane
- Access to Control Plane node and check whether k3s is installed properly and joins two other worker nodes.

<details>
  <summary>The controller (manager) node already had installed k3s and joined two other worker nodes through terraform (user_data). </summary>

```
ubuntu@ip-10-0-1-223:~$ kubectl get nodes
NAME            STATUS   ROLES                  AGE   VERSION
ip-10-0-1-144   Ready    <none>                 19m   v1.32.4+k3s1
ip-10-0-1-223   Ready    control-plane,master   20m   v1.32.4+k3s1
ip-10-0-1-82    Ready    <none>                 19m   v1.32.4+k3s1
ubuntu@ip-10-0-1-223:~$ systemctl status k3s
● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-05-21 18:11:52 UTC; 21min ago
       Docs: https://k3s.io
    Process: 1649 ExecStartPre=/bin/sh -xc ! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service 2>/dev/null (code=exited, >
    Process: 1651 ExecStartPre=/sbin/modprobe br_netfilter (code=exited, status=0/SUCCESS)
    Process: 1654 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 1656 (k3s-server)
      Tasks: 118
     Memory: 2.4G (peak: 2.9G)
        CPU: 2min 22.853s
     CGroup: /system.slice/k3s.service
             ├─1656 "/usr/local/bin/k3s server"
             ├─1683 "containerd "
             ├─2428 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>
             ├─2438 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>
             ├─2486 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>
             ├─3721 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>
             ├─3813 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>
             ├─5246 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>
             └─5322 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>

May 21 18:23:50 ip-10-0-1-223 k3s[1656]: I0521 18:23:50.190262    1656 range_allocator.go:247] "Successfully synced" key="ip-10-0-1->
May 21 18:26:44 ip-10-0-1-223 k3s[1656]: time="2025-05-21T18:26:44Z" level=info msg="COMPACT compactRev=214 targetCompactRev=366 cur>
May 21 18:26:44 ip-10-0-1-223 k3s[1656]: time="2025-05-21T18:26:44Z" level=info msg="COMPACT deleted 30 rows from 152 revisions in 1>
May 21 18:26:44 ip-10-0-1-223 k3s[1656]: time="2025-05-21T18:26:44Z" level=info msg="COMPACT compacted from 214 to 366 in 1 transact>
May 21 18:28:45 ip-10-0-1-223 k3s[1656]: I0521 18:28:45.463365    1656 range_allocator.go:247] "Successfully synced" key="ip-10-0-1->
May 21 18:28:53 ip-10-0-1-223 k3s[1656]: I0521 18:28:53.624224    1656 range_allocator.go:247] "Successfully synced" key="ip-10-0-1->
May 21 18:28:56 ip-10-0-1-223 k3s[1656]: I0521 18:28:56.155377    1656 range_allocator.go:247] "Successfully synced" key="ip-10-0-1->
May 21 18:31:44 ip-10-0-1-223 k3s[1656]: time="2025-05-21T18:31:44Z" level=info msg="COMPACT compactRev=366 targetCompactRev=516 cur>
May 21 18:31:44 ip-10-0-1-223 k3s[1656]: time="2025-05-21T18:31:44Z" level=info msg="COMPACT deleted 72 rows from 150 revisions in 4>
May 21 18:31:44 ip-10-0-1-223 k3s[1656]: time="2025-05-21T18:31:44Z" level=info msg="COMPACT compacted from 366 to 516 in 1 transa
```
</details>

## STEP 4: Access to other two ec2 instances with worker nodes.
- Access to worker nodes and check whether k3s is installed properly.

<details>
  <summary>The worker nodes already had installed k3s-agent. </summary>

```
ubuntu@ip-10-0-1-144:~$ systemctl status k3s-agent
● k3s-agent.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s-agent.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-05-21 18:13:10 UTC; 22min ago
       Docs: https://k3s.io
    Process: 1642 ExecStartPre=/bin/sh -xc ! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service 2>/dev/null (code=exited, >
    Process: 1644 ExecStartPre=/sbin/modprobe br_netfilter (code=exited, status=0/SUCCESS)
    Process: 1647 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 1648 (k3s-agent)
      Tasks: 36
     Memory: 331.8M (peak: 332.8M)
        CPU: 24.173s
     CGroup: /system.slice/k3s-agent.service
             ├─1648 "/usr/local/bin/k3s agent"
             ├─1671 "containerd "
             └─2130 /var/lib/rancher/k3s/data/e1730ceee3d97d63f58b7ccd96fe08638e972abfd3b1ebdf497b52572f85b316/bin/containerd-shim-r>

May 21 18:13:09 ip-10-0-1-144 k3s[1648]: I0521 18:13:09.353301    1648 iptables.go:372] bootstrap done
May 21 18:13:09 ip-10-0-1-144 k3s[1648]: I0521 18:13:09.362280    1648 iptables.go:372] bootstrap done
May 21 18:13:10 ip-10-0-1-144 k3s[1648]: time="2025-05-21T18:13:10Z" level=info msg="Starting network policy controller version v2.2>
May 21 18:13:10 ip-10-0-1-144 k3s[1648]: time="2025-05-21T18:13:10Z" level=info msg="k3s agent is up and running"
May 21 18:13:10 ip-10-0-1-144 k3s[1648]: I0521 18:13:10.351393    1648 network_policy_controller.go:164] Starting network policy con>
May 21 18:13:10 ip-10-0-1-144 systemd[1]: Started k3s-agent.service - Lightweight Kubernetes.
May 21 18:13:10 ip-10-0-1-144 k3s[1648]: I0521 18:13:10.421282    1648 network_policy_controller.go:176] Starting network policy con>
May 21 18:13:18 ip-10-0-1-144 k3s[1648]: I0521 18:13:18.164672    1648 kuberuntime_manager.go:1702] "Updating runtime config through>
May 21 18:13:18 ip-10-0-1-144 k3s[1648]: I0521 18:13:18.165348    1648 kubelet_network.go:61] "Updating Pod CIDR" originalPodCIDR="">
May 21 18:13:25 ip-10-0-1-144 k3s[1648]: I0521 18:13:25.910051    1648 pod_startup_latency_tracker.go:104] "Observed pod startup d
```
</details>

## STEP 5: Check whether helm repo was added and wordpress was deployed properly.
- Check helm repo and analyze logs from wordpress pods.

<details>
  <summary>Use the command 'helm repo list' then kubectl logs pod commands</summary>

```
ubuntu@ip-10-0-1-223:~$ helm repo list
NAME   	URL
bitnami	https://charts.bitnami.com/bitnami

ubuntu@ip-10-0-1-223:~$ kubectl logs wordpress-mariadb-0 -n wordpress
Defaulted container "mariadb" out of: mariadb, preserve-logs-symlinks (init)
mariadb 18:13:02.27 INFO  ==>
mariadb 18:13:02.27 INFO  ==> Welcome to the Bitnami mariadb container
mariadb 18:13:02.27 INFO  ==> Subscribe to project updates by watching https://github.com/bitnami/containers
mariadb 18:13:02.28 INFO  ==> Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami/ for more information.
mariadb 18:13:02.28 INFO  ==>
mariadb 18:13:02.29 INFO  ==> ** Starting MariaDB setup **
mariadb 18:13:02.38 INFO  ==> Validating settings in MYSQL_*/MARIADB_* env vars
mariadb 18:13:02.52 INFO  ==> Initializing mariadb database
mariadb 18:13:02.64 WARN  ==> The mariadb configuration file '/opt/bitnami/mariadb/conf/my.cnf' is not writable. Configurations based on environment variables will not be applied for this file.
mariadb 18:13:02.65 INFO  ==> Installing database
/opt/bitnami/mariadb/bin/mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
mariadb 18:13:06.27 INFO  ==> Starting mariadb in background
2025-05-21 18:13:06 0 [Note] Starting MariaDB 11.4.5-MariaDB source revision 0771110266ff5c04216af4bf1243c65f8c67ccf4 server_uid bvlOAruHV/BtOq05bI5NR8Y3EW0= as process 89
2025-05-21 18:13:06 0 [Note] InnoDB: Compressed tables use zlib 1.2.13
2025-05-21 18:13:06 0 [Note] InnoDB: Number of transaction pools: 1
2025-05-21 18:13:06 0 [Note] InnoDB: Using crc32 + pclmulqdq instructions
2025-05-21 18:13:06 0 [Note] InnoDB: Using Linux native AIO
2025-05-21 18:13:06 0 [Note] InnoDB: Initializing buffer pool, total size = 128.000MiB, chunk size = 2.000MiB
2025-05-21 18:13:06 0 [Note] InnoDB: Completed initialization of buffer pool
2025-05-21 18:13:06 0 [Note] InnoDB: File system buffers for log disabled (block size=512 bytes)
2025-05-21 18:13:06 0 [Note] InnoDB: End of log at LSN=47763
2025-05-21 18:13:07 0 [Note] InnoDB: Opened 3 undo tablespaces
2025-05-21 18:13:07 0 [Note] InnoDB: 128 rollback segments in 3 undo tablespaces are active.
2025-05-21 18:13:07 0 [Note] InnoDB: Setting file './ibtmp1' size to 12.000MiB. Physically writing the file full; Please wait ...
2025-05-21 18:13:07 0 [Note] InnoDB: File './ibtmp1' size is now 12.000MiB.
2025-05-21 18:13:07 0 [Note] InnoDB: log sequence number 47763; transaction id 14
2025-05-21 18:13:07 0 [Note] Plugin 'FEEDBACK' is disabled.
2025-05-21 18:13:07 0 [Note] Plugin 'wsrep-provider' is disabled.
2025-05-21 18:13:07 0 [Note] InnoDB: Loading buffer pool(s) from /bitnami/mariadb/data/ib_buffer_pool
2025-05-21 18:13:07 0 [Note] InnoDB: Buffer pool(s) load completed at 250521 18:13:07
2025-05-21 18:13:09 0 [Warning] 'user' entry 'root@wordpress-mariadb-0' ignored in --skip-name-resolve mode.
2025-05-21 18:13:09 0 [Warning] 'user' entry '@wordpress-mariadb-0' ignored in --skip-name-resolve mode.
2025-05-21 18:13:09 0 [Warning] 'proxies_priv' entry '@% root@wordpress-mariadb-0' ignored in --skip-name-resolve mode.
2025-05-21 18:13:09 0 [Note] mysqld: Event Scheduler: Loaded 0 events
2025-05-21 18:13:09 0 [Note] /opt/bitnami/mariadb/sbin/mysqld: ready for connections.
Version: '11.4.5-MariaDB'  socket: '/opt/bitnami/mariadb/tmp/mysql.sock'  port: 0  Source distribution
mariadb 18:13:10.64 INFO  ==> Configuring authentication
2025-05-21 18:13:11 5 [Warning] 'proxies_priv' entry '@% root@wordpress-mariadb-0' ignored in --skip-name-resolve mode.
/opt/bitnami/mariadb/bin/mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
/opt/bitnami/mariadb/bin/mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
/opt/bitnami/mariadb/bin/mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
/opt/bitnami/mariadb/bin/mysql: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/bin/mariadb' instead
mariadb 18:13:13.07 INFO  ==> Running mysql_upgrade
find: '/docker-entrypoint-startdb.d/': No such file or directory
mariadb 18:13:13.57 INFO  ==> Stopping mariadb
2025-05-21 18:13:13 0 [Note] /opt/bitnami/mariadb/sbin/mysqld (initiated by: unknown): Normal shutdown
2025-05-21 18:13:13 0 [Note] InnoDB: FTS optimize thread exiting.
2025-05-21 18:13:13 0 [Note] InnoDB: Starting shutdown...
2025-05-21 18:13:13 0 [Note] InnoDB: Dumping buffer pool(s) to /bitnami/mariadb/data/ib_buffer_pool
2025-05-21 18:13:13 0 [Note] InnoDB: Buffer pool(s) dump completed at 250521 18:13:13
2025-05-21 18:13:13 0 [Note] InnoDB: Removed temporary tablespace data file: "./ibtmp1"
2025-05-21 18:13:13 0 [Note] InnoDB: Shutdown completed; log sequence number 47763; transaction id 15
2025-05-21 18:13:13 0 [Note] /opt/bitnami/mariadb/sbin/mysqld: Shutdown complete

mariadb 18:13:14.63 INFO  ==> ** MariaDB setup finished! **
mariadb 18:13:14.67 INFO  ==> ** Starting MariaDB **
/opt/bitnami/mariadb/sbin/mysqld: Deprecated program name. It will be removed in a future release, use '/opt/bitnami/mariadb/sbin/mariadbd' instead
2025-05-21 18:13:14 0 [Note] Starting MariaDB 11.4.5-MariaDB source revision 0771110266ff5c04216af4bf1243c65f8c67ccf4 server_uid n6S8S4t0v3vBCm5eTG0KasXtfdY= as process 1
2025-05-21 18:13:15 0 [Note] InnoDB: Compressed tables use zlib 1.2.13
2025-05-21 18:13:15 0 [Note] InnoDB: Number of transaction pools: 1
2025-05-21 18:13:15 0 [Note] InnoDB: Using crc32 + pclmulqdq instructions
2025-05-21 18:13:15 0 [Note] InnoDB: Using Linux native AIO
2025-05-21 18:13:15 0 [Note] InnoDB: Initializing buffer pool, total size = 128.000MiB, chunk size = 2.000MiB
2025-05-21 18:13:15 0 [Note] InnoDB: Completed initialization of buffer pool
2025-05-21 18:13:15 0 [Note] InnoDB: File system buffers for log disabled (block size=512 bytes)
2025-05-21 18:13:15 0 [Note] InnoDB: End of log at LSN=47763
2025-05-21 18:13:15 0 [Note] InnoDB: Opened 3 undo tablespaces
2025-05-21 18:13:15 0 [Note] InnoDB: 128 rollback segments in 3 undo tablespaces are active.
2025-05-21 18:13:15 0 [Note] InnoDB: Setting file './ibtmp1' size to 12.000MiB. Physically writing the file full; Please wait ...
2025-05-21 18:13:15 0 [Note] InnoDB: File './ibtmp1' size is now 12.000MiB.
2025-05-21 18:13:15 0 [Note] InnoDB: log sequence number 47763; transaction id 14
2025-05-21 18:13:15 0 [Note] Plugin 'FEEDBACK' is disabled.
2025-05-21 18:13:15 0 [Note] Plugin 'wsrep-provider' is disabled.
2025-05-21 18:13:15 0 [Note] InnoDB: Loading buffer pool(s) from /bitnami/mariadb/data/ib_buffer_pool
2025-05-21 18:13:15 0 [Note] InnoDB: Buffer pool(s) load completed at 250521 18:13:15
2025-05-21 18:13:22 0 [Note] Server socket created on IP: '0.0.0.0'.
2025-05-21 18:13:22 0 [Note] Server socket created on IP: '::'.
2025-05-21 18:13:22 0 [Warning] 'proxies_priv' entry '@% root@wordpress-mariadb-0' ignored in --skip-name-resolve mode.
2025-05-21 18:13:22 0 [Note] mysqld: Event Scheduler: Loaded 0 events
2025-05-21 18:13:22 0 [Note] /opt/bitnami/mariadb/sbin/mysqld: ready for connections.
Version: '11.4.5-MariaDB'  socket: '/opt/bitnami/mariadb/tmp/mysql.sock'  port: 3306  Source distribution
ubuntu@ip-10-0-1-223:~$ kubectl logs wordpress-857545576f-mmwpx -n wordpress
Defaulted container "wordpress" out of: wordpress, prepare-base-dir (init)
wordpress 18:13:05.21 INFO  ==>
wordpress 18:13:05.21 INFO  ==> Welcome to the Bitnami wordpress container
wordpress 18:13:05.22 INFO  ==> Subscribe to project updates by watching https://github.com/bitnami/containers
wordpress 18:13:05.22 INFO  ==> Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami/ for more information.
wordpress 18:13:05.23 INFO  ==>
wordpress 18:13:05.24 INFO  ==> ** Starting WordPress setup **
wordpress 18:13:05.30 WARN  ==> The Apache configuration file '/opt/bitnami/apache/conf/httpd.conf' is not writable. Configurations based on environment variables will not be applied.
wordpress 18:13:05.36 INFO  ==> Generating sample certificates
Certificate request self-signature ok
subject=CN = example.com
realpath: /bitnami/apache/conf: No such file or directory
wordpress 18:13:10.65 INFO  ==> Configuring the HTTP port
wordpress 18:13:10.70 INFO  ==> Configuring the HTTPS port
wordpress 18:13:10.71 INFO  ==> Configuring Apache ServerTokens directive
wordpress 18:13:10.73 INFO  ==> Configuring PHP options
wordpress 18:13:10.79 INFO  ==> Setting PHP expose_php option
wordpress 18:13:10.85 INFO  ==> Setting PHP output_buffering option
wordpress 18:13:10.86 INFO  ==> Validating settings in MYSQL_CLIENT_* env vars
wordpress 18:13:11.03 WARN  ==> You set the environment variable ALLOW_EMPTY_PASSWORD=yes. For safety reasons, do not use this flag in a production environment.
wordpress 18:13:11.30 INFO  ==> Ensuring WordPress directories exist
wordpress 18:13:11.31 INFO  ==> Trying to connect to the database server
wordpress 18:13:37.00 INFO  ==> Configuring WordPress with settings provided via environment variables
wordpress 18:13:40.59 INFO  ==> Installing WordPress
wordpress 18:13:47.99 INFO  ==> Persisting WordPress installation
wordpress 18:13:49.58 INFO  ==> ** WordPress setup finished! **

wordpress 18:13:49.59 INFO  ==> ** Starting Apache **
[Wed May 21 18:13:49.890384 2025] [mpm_prefork:notice] [pid 1:tid 1] AH00163: Apache/2.4.63 (Unix) OpenSSL/3.0.15 configured -- resuming normal operations
[Wed May 21 18:13:49.890475 2025] [core:notice] [pid 1:tid 1] AH00094: Command line: '/opt/bitnami/apache/bin/httpd -f /opt/bitnami/apache/conf/httpd.conf -D FOREGROUND'
10.42.0.1 - - [21/May/2025:18:13:58 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:14:08 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:14:18 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:14:28 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:14:38 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.11 - - [21/May/2025:18:14:48 +0000] "POST /wp-cron.php?doing_wp_cron=1747851288.2157399654388427734375 HTTP/1.1" 200 -
10.42.0.1 - - [21/May/2025:18:14:48 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:14:58 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:15:08 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:15:18 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:15:28 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:15:38 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:15:48 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:15:58 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:16:08 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:16:18 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:16:28 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
10.42.0.1 - - [21/May/2025:18:16:38 +0000] "GET /wp-login.php HTTP/1.1" 200 4441
```
</details>

## STEP 6: Enter the wordpress url, check website, and log-in.
- Type the url (Ex. http://34.240.75.142:30080) to check the wordpress deployment
- Find out the username and password (inside wordpress-password.txt).
- Type the url (http://34.240.75.142:30080/wp-login) to log-in. 

<details>
  <summary>Below one is the example output with IP addresses, username after terraform apply. Please check own proper outputs after terraform apply.</summary>

```
EOT
kubernetes_api_endpoint = "https://34.240.75.142:6443"
master_private_ip = "10.0.1.223"
master_public_ip = "34.240.75.142"
wordpress_admin_credentials = <<EOT
Username: user
Password: Use 'cat wordpress-password.txt' to view the password in Master Node
URL: http://34.240.75.142:30080

EOT
worker_public_ips = [
  "3.249.233.141",
  "3.254.198.86",
]
```
</details>

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.rt_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.rt_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.security_group_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone | `string` | `"eu-west-1a"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | n/a | `string` | `"test"` | no |
| <a name="input_local_ip"></a> [local\_ip](#input\_local\_ip) | Local CIDR | `string` | n/a | yes |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | Public Subnet CIDR | `string` | `"10.0.1.0/24"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_manager_public_ip"></a> [manager\_public\_ip](#output\_manager\_public\_ip) | n/a |
| <a name="output_worker_public_ips"></a> [worker\_public\_ips](#output\_worker\_public\_ips) | n/a |

<!-- END_TF_DOCS -->