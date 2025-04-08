<!-- BEGIN_TF_DOCS -->

# Objective:
Create a fully functional Docker Swarm cluster on AWS using Terraform, and deploy a WordPress website with a MySQL backend on top of the cluster.
This challenge will assess your ability to provision infrastructure as code, configure a container orchestration platform (Docker Swarm), and deploy containerized applications in a secure and reproducible way.

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

# STEP 2: Create vpc, subnet, security group, ec2 with user data, route table, etc.
- After creating s3 for remote state, create vpc, subnet, security group, ec2 with user data, route table, etc.

<details>
  <summary>Show the `terraform apply --auto-approve`</summary>

```
week9 git:(main) ✗ terraform apply --auto-approve           
Acquiring state lock. This may take a few moments...
data.aws_ami.ubuntu: Reading...
data.aws_ami.ubuntu: Read complete after 2s [id=ami-05718e63cb39fcdb1]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.controller will be created
  + resource "aws_instance" "controller" {
      + ami                                  = "ami-05718e63cb39fcdb1"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
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
      + instance_type                        = "t2.micro"
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
          + "Name" = "Controller Node Instance"
        }
      + tags_all                             = {
          + "Name" = "Controller Node Instance"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "d4b5059c8dc7ae3ed01423cf3f60e4720a67997c"
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
      + ami                                  = "ami-05718e63cb39fcdb1"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
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
      + instance_type                        = "t2.micro"
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
          + "Name" = "Worker Node Instance"
        }
      + tags_all                             = {
          + "Name" = "Worker Node Instance"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "18f1b49331e8ac6b9ed2ec0c8923c289df2f47e4"
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
      + ami                                  = "ami-05718e63cb39fcdb1"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
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
      + instance_type                        = "t2.micro"
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
          + "Name" = "Worker Node Instance"
        }
      + tags_all                             = {
          + "Name" = "Worker Node Instance"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "18f1b49331e8ac6b9ed2ec0c8923c289df2f47e4"
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
                  + "10.0.1.0/24",
                ]
              + from_port        = 2377
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 2377
                # (1 unchanged attribute hidden)
            },
          + {
              + cidr_blocks      = [
                  + "10.0.1.0/24",
                ]
              + from_port        = 4789
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 4789
                # (1 unchanged attribute hidden)
            },
          + {
              + cidr_blocks      = [
                  + "10.0.1.0/24",
                ]
              + description      = "Swarm node discovery (TCP)"
              + from_port        = 7946
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 7946
            },
          + {
              + cidr_blocks      = [
                  + "10.0.1.0/24",
                ]
              + description      = "Swarm node discovery (UDP)"
              + from_port        = 7946
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "udp"
              + security_groups  = []
              + self             = false
              + to_port          = 7946
            },
          + {
              + cidr_blocks      = [
                  + "88.217.180.87/32",
                ]
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
                # (1 unchanged attribute hidden)
            },
          + {
              + cidr_blocks      = [
                  + "88.217.180.87/32",
                ]
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
                # (1 unchanged attribute hidden)
            },
          + {
              + cidr_blocks      = [
                  + "88.217.180.87/32",
                ]
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
                # (1 unchanged attribute hidden)
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
      + enable_dns_hostnames                 = (known after apply)
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

Plan: 9 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + manager_public_ip = (known after apply)
  + worker_public_ips = [
      + [
          + (known after apply),
          + (known after apply),
        ],
    ]
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 1s [id=vpc-027e27f4d0de1ce79]
aws_internet_gateway.gw: Creating...
aws_subnet.public_subnet: Creating...
aws_internet_gateway.gw: Creation complete after 1s [id=igw-078f17f3c0b84b96a]
aws_route_table.rt_table: Creating...
aws_route_table.rt_table: Creation complete after 1s [id=rtb-09d906383fbdaec86]
aws_subnet.public_subnet: Still creating... [10s elapsed]
aws_subnet.public_subnet: Creation complete after 11s [id=subnet-0c52a9ae841761492]
aws_route_table_association.rt_table_association: Creating...
aws_security_group.security_group_ec2: Creating...
aws_route_table_association.rt_table_association: Creation complete after 1s [id=rtbassoc-0b8336ab6eb45b87f]
aws_security_group.security_group_ec2: Creation complete after 3s [id=sg-0292576b98e2bfbf8]
aws_instance.worker[0]: Creating...
aws_instance.controller: Creating...
aws_instance.worker[1]: Creating...
aws_instance.controller: Still creating... [10s elapsed]
aws_instance.worker[1]: Still creating... [10s elapsed]
aws_instance.worker[0]: Still creating... [10s elapsed]
aws_instance.worker[0]: Creation complete after 13s [id=i-0201baba09b5f7c2d]
aws_instance.worker[1]: Creation complete after 13s [id=i-062a86a700d03e023]
aws_instance.controller: Creation complete after 13s [id=i-033ae43f4b4eb447d]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

manager_public_ip = "34.245.36.46"
worker_public_ips = [
  [
    "34.247.176.136",
    "3.252.35.48",
  ],
]
```
</details>

## STEP 3: Access to Controller (Manager) node (ec2) then add other worker nodes to the swarm.
- The controller (manager) node already initiated docker swarm during the provision through terraform (user_data). 

<details>
  <summary>Add other worker nodes to the swarm through 'docker swarm join-token'</summary>

```
ubuntu@ip-10-0-1-59:~$ sudo docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join --token zxxxxxxx 10.0.1.59:2377
```
</details>

## STEP 4: Access to other worker nodes then the nodes have to join to the swarm.
- Use the command 'docker swarm join --token' to make each worker node join the swarm

<details>
  <summary>Use the command 'docker swarm join --token' to make each worker node join the swarm</summary>

```
ubuntu@ip-10-0-1-112:~$ docker --version
Docker version 28.0.4, build b8034c0
ubuntu@ip-10-0-1-112:~$ sudo docker swarm join --token zxxxxxxxxxx 10.0.1.59:2377
This node joined a swarm as a worker.

ubuntu@ip-10-0-1-21:~$ docker --version
Docker version 28.0.4, build b8034c0
ubuntu@ip-10-0-1-21:~$ sudo docker swarm join --token zxxxxxxxxx 10.0.1.59:2377
This node joined a swarm as a worker.
```
</details>

## STEP 5: Create docker for both frontend and backend in the controller (manager) node (ec2).
- Create docker networks for frontend and backend

<details>
  <summary>Use the command 'docker network create' with overlay driver to create frontend and backend networks</summary>

```
ubuntu@ip-10-0-1-59:~$ sudo docker network create -d overlay frontend-ntwk

ubuntu@ip-10-0-1-59:~$ sudo docker network create -d overlay backend-ntwk
```
</details>

## STEP 6: Copy the docker compose file from local machine then create docker stack from the file.
- Use docker compose file to create the docker stack called wordpress. 
- The stack will create the two services, wordpress_mysql and wordpress_wordpress.
- Verify services in every node (controller and worker nodes)

<details>
  <summary>Use scp command to copy the docker compose file from local machine then create docker stack with the file.</summary>

```
ubuntu@ip-10-0-1-59:~$ sudo docker stack deploy -c docker-compose.yml wordpress
Since --detach=false was not specified, tasks will be created in the background.
In a future release, --detach=false will become the default.
Creating service wordpress_mysql
Creating service wordpress_wordpress
ubuntu@ip-10-0-1-59:~$ sudo docker node ls
ID                            HOSTNAME        STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
xxxxxxxxxxxxxx    ip-10-0-1-21    Ready     Active                          28.0.4
kkkkkkkkkkkkkk *   ip-10-0-1-59    Ready     Active         Leader           28.0.4
aaaaaaaaaaaaaa     ip-10-0-1-112   Ready     Active                          28.0.4
ubuntu@ip-10-0-1-59:~$ sudo docker node ps
ID             NAME                    IMAGE             NODE           DESIRED STATE   CURRENT STATE            ERROR     PORTS
0xw7zz0tgtsl   wordpress_wordpress.1   wordpress:6.7.2   ip-10-0-1-59   Running         Running 10 seconds ago
ubuntu@ip-10-0-1-59:~$ sudo docker node ps ip-10-0-1-21
ID             NAME                    IMAGE             NODE           DESIRED STATE   CURRENT STATE            ERROR     PORTS
ke057x88myqr   wordpress_mysql.1       mysql:8.0.41      ip-10-0-1-21   Running         Running 27 seconds ago
17g2kj00ydga   wordpress_wordpress.2   wordpress:6.7.2   ip-10-0-1-21   Running         Running 43 seconds ago
ubuntu@ip-10-0-1-59:~$ sudo docker node ps ip-10-0-1-112
ID             NAME                    IMAGE             NODE            DESIRED STATE   CURRENT STATE               ERROR     PORTS
f6wpitai3fzd   wordpress_wordpress.3   wordpress:6.7.2   ip-10-0-1-112   Running         Running about an hour ago
ubuntu@ip-10-0-1-59:~$ sudo docker node ps ip-10-0-1-59
ID             NAME                    IMAGE             NODE           DESIRED STATE   CURRENT STATE               ERROR     PORTS
0xw7zz0tgtsl   wordpress_wordpress.1   wordpress:6.7.2   ip-10-0-1-59   Running         Running about an hour ago
```
</details>

# Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |

# Modules

No modules.

# Resources

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

# Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone | `string` | `"eu-west-1a"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | n/a | `string` | `"test"` | no |
| <a name="input_local_ip"></a> [local\_ip](#input\_local\_ip) | Local CIDR | `string` | `"88.217.180.87/32"` | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | Public Subnet CIDR | `string` | `"10.0.1.0/24"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR | `string` | `"10.0.0.0/16"` | no |

# Outputs

| Name | Description |
|------|-------------|
| <a name="output_manager_public_ip"></a> [manager\_public\_ip](#output\_manager\_public\_ip) | n/a |
| <a name="output_worker_public_ips"></a> [worker\_public\_ips](#output\_worker\_public\_ips) | n/a |

<!-- END_TF_DOCS -->