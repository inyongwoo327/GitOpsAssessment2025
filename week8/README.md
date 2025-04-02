<!-- BEGIN_TF_DOCS -->
# Exercise:
Create a Terraform module that allows you to create an EC2 instance, with security groups and autoscaling. The configuration of VPC, Subnets, AMI, and a few other common settings is managed by parameters. Generate docs using https://github.com/terraform-docs/terraform-docs. 

# STEP 1: Create s3 backend (remote state) bucket first.

<details>
  <summary>Show s3 backend after `terraform apply --auto-approve`</summary>

```
bootstrap git:(main) ✗ terraform state list
aws_dynamodb_table.terraform_locks
aws_s3_bucket.terraform_state
aws_s3_bucket_server_side_encryption_configuration.encryption
aws_s3_bucket_versioning.versioning
```
</details>

# STEP 2: Create 2 modules with vpc, subnet, security group, ec2, autoscaling group, and so on.
- module-ec2 includes vpc, internet gateway, ec2 instance, two public subnets, one private subnet, security group, autoscaling group, etc.
- module-alb includes application load balancer, security group, and so on. 

<details>
  <summary>Show the `terraform apply --auto-approve`</summary>

```
week8 git:(main) ✗ terraform apply --auto-approve  
module.ec2_instance.data.aws_ami.ubuntu: Reading...
module.ec2_instance.data.aws_ami.ubuntu: Read complete after 0s [id=ami-05718e63cb39fcdb1]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # module.alb.aws_autoscaling_attachment.asg_attachment will be created
  + resource "aws_autoscaling_attachment" "asg_attachment" {
      + autoscaling_group_name = "autoscale"
      + id                     = (known after apply)
      + lb_target_group_arn    = (known after apply)
    }

  # module.alb.aws_lb.alb will be created
  + resource "aws_lb" "alb" {
      + arn                                                          = (known after apply)
      + arn_suffix                                                   = (known after apply)
      + client_keep_alive                                            = 3600
      + desync_mitigation_mode                                       = "defensive"
      + dns_name                                                     = (known after apply)
      + drop_invalid_header_fields                                   = false
      + enable_deletion_protection                                   = false
      + enable_http2                                                 = true
      + enable_tls_version_and_cipher_suite_headers                  = false
      + enable_waf_fail_open                                         = false
      + enable_xff_client_port                                       = false
      + enable_zonal_shift                                           = false
      + enforce_security_group_inbound_rules_on_private_link_traffic = (known after apply)
      + id                                                           = (known after apply)
      + idle_timeout                                                 = 60
      + internal                                                     = false
      + ip_address_type                                              = (known after apply)
      + load_balancer_type                                           = "application"
      + name                                                         = "app-load-balancer"
      + name_prefix                                                  = (known after apply)
      + preserve_host_header                                         = false
      + security_groups                                              = (known after apply)
      + subnets                                                      = (known after apply)
      + tags                                                         = {
          + "Environment" = "dev"
        }
      + tags_all                                                     = {
          + "Environment" = "dev"
        }
      + vpc_id                                                       = (known after apply)
      + xff_header_processing_mode                                   = "append"
      + zone_id                                                      = (known after apply)

      + subnet_mapping (known after apply)
    }

  # module.alb.aws_lb_listener.http will be created
  + resource "aws_lb_listener" "http" {
      + arn                                                                   = (known after apply)
      + id                                                                    = (known after apply)
      + load_balancer_arn                                                     = (known after apply)
      + port                                                                  = 80
      + protocol                                                              = "HTTP"
      + routing_http_request_x_amzn_mtls_clientcert_header_name               = (known after apply)
      + routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = (known after apply)
      + routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = (known after apply)
      + routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = (known after apply)
      + routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = (known after apply)
      + routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = (known after apply)
      + routing_http_request_x_amzn_tls_cipher_suite_header_name              = (known after apply)
      + routing_http_request_x_amzn_tls_version_header_name                   = (known after apply)
      + routing_http_response_access_control_allow_credentials_header_value   = (known after apply)
      + routing_http_response_access_control_allow_headers_header_value       = (known after apply)
      + routing_http_response_access_control_allow_methods_header_value       = (known after apply)
      + routing_http_response_access_control_allow_origin_header_value        = (known after apply)
      + routing_http_response_access_control_expose_headers_header_value      = (known after apply)
      + routing_http_response_access_control_max_age_header_value             = (known after apply)
      + routing_http_response_content_security_policy_header_value            = (known after apply)
      + routing_http_response_server_enabled                                  = (known after apply)
      + routing_http_response_strict_transport_security_header_value          = (known after apply)
      + routing_http_response_x_content_type_options_header_value             = (known after apply)
      + routing_http_response_x_frame_options_header_value                    = (known after apply)
      + ssl_policy                                                            = (known after apply)
      + tags_all                                                              = (known after apply)
      + tcp_idle_timeout_seconds                                              = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + mutual_authentication (known after apply)
    }

  # module.alb.aws_lb_target_group.tg will be created
  + resource "aws_lb_target_group" "tg" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = (known after apply)
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancer_arns                 = (known after apply)
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_anomaly_mitigation  = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "alb-target-group"
      + name_prefix                        = (known after apply)
      + port                               = 80
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = true
          + healthy_threshold   = 2
          + interval            = 30
          + matcher             = "200"
          + path                = "/"
          + port                = "traffic-port"
          + protocol            = "HTTP"
          + timeout             = 5
          + unhealthy_threshold = 2
        }

      + stickiness (known after apply)

      + target_failover (known after apply)

      + target_group_health (known after apply)

      + target_health_state (known after apply)
    }

  # module.alb.aws_security_group.alb_sg will be created
  + resource "aws_security_group" "alb_sg" {
      + arn                    = (known after apply)
      + description            = "Security group for ALB"
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
      + name                   = "alb-security-group"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # module.ec2_instance.aws_autoscaling_group.autoscale will be created
  + resource "aws_autoscaling_group" "autoscale" {
      + arn                              = (known after apply)
      + availability_zones               = (known after apply)
      + default_cooldown                 = (known after apply)
      + desired_capacity                 = 1
      + force_delete                     = false
      + force_delete_warm_pool           = false
      + health_check_grace_period        = 300
      + health_check_type                = (known after apply)
      + id                               = (known after apply)
      + ignore_failed_scaling_activities = false
      + load_balancers                   = (known after apply)
      + max_size                         = 2
      + metrics_granularity              = "1Minute"
      + min_size                         = 1
      + name                             = "autoscale"
      + name_prefix                      = (known after apply)
      + predicted_capacity               = (known after apply)
      + protect_from_scale_in            = false
      + service_linked_role_arn          = (known after apply)
      + target_group_arns                = (known after apply)
      + vpc_zone_identifier              = (known after apply)
      + wait_for_capacity_timeout        = "10m"
      + warm_pool_size                   = (known after apply)

      + availability_zone_distribution (known after apply)

      + launch_template (known after apply)

      + mixed_instances_policy {
          + launch_template {
              + launch_template_specification {
                  + launch_template_id   = (known after apply)
                  + launch_template_name = (known after apply)
                  + version              = (known after apply)
                }
              + override {
                  + instance_type     = "t2.micro"
                  + weighted_capacity = "2"
                }
              + override {
                  + instance_type     = "t3.micro"
                  + weighted_capacity = "1"
                }
            }
        }

      + traffic_source (known after apply)
    }

  # module.ec2_instance.aws_instance.sample will be created
  + resource "aws_instance" "sample" {
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
          + "Name" = "Hello World"
        }
      + tags_all                             = {
          + "Name" = "Hello World"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "1f89b4fde46ba68096c8d6eb801a3434fb72798e"
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

  # module.ec2_instance.aws_internet_gateway.gw will be created
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

  # module.ec2_instance.aws_launch_template.sample_launch_template will be created
  + resource "aws_launch_template" "sample_launch_template" {
      + arn             = (known after apply)
      + default_version = (known after apply)
      + id              = (known after apply)
      + image_id        = "ami-05718e63cb39fcdb1"
      + instance_type   = "t2.micro"
      + latest_version  = (known after apply)
      + name            = (known after apply)
      + name_prefix     = "template-name"
      + tags_all        = (known after apply)

      + metadata_options (known after apply)

      + network_interfaces {
          + associate_public_ip_address = "true"
          + security_groups             = (known after apply)
        }
    }

  # module.ec2_instance.aws_security_group.security_group_ec2 will be created
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
                  + "10.0.1.0/24",
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
                  + "10.0.1.0/24",
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

  # module.ec2_instance.aws_subnet.private_subnet will be created
  + resource "aws_subnet" "private_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "Private Subnet"
        }
      + tags_all                                       = {
          + "Name" = "Private Subnet"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.ec2_instance.aws_subnet.public_subnet will be created
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

  # module.ec2_instance.aws_subnet.public_subnet_2 will be created
  + resource "aws_subnet" "public_subnet_2" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.3.0/24"
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
          + "Name" = "Public Subnet 2"
        }
      + tags_all                                       = {
          + "Name" = "Public Subnet 2"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.ec2_instance.aws_vpc.main will be created
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

Plan: 14 to add, 0 to change, 0 to destroy.
module.ec2_instance.aws_vpc.main: Creating...
module.ec2_instance.aws_vpc.main: Creation complete after 1s [id=vpc-08a7d3a5956d74d54]
module.ec2_instance.aws_internet_gateway.gw: Creating...
module.ec2_instance.aws_subnet.private_subnet: Creating...
module.ec2_instance.aws_subnet.public_subnet: Creating...
module.ec2_instance.aws_subnet.public_subnet_2: Creating...
module.alb.aws_security_group.alb_sg: Creating...
module.alb.aws_lb_target_group.tg: Creating...
module.ec2_instance.aws_internet_gateway.gw: Creation complete after 1s [id=igw-03e204cd22712ca51]
module.alb.aws_lb_target_group.tg: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-west-1:590184075527:targetgroup/alb-target-group/a5a383ab44f59aa4]
module.alb.aws_security_group.alb_sg: Creation complete after 2s [id=sg-0f257643173707311]
module.ec2_instance.aws_subnet.private_subnet: Creation complete after 3s [id=subnet-02f32e62e9b7b9326]
module.ec2_instance.aws_subnet.public_subnet_2: Still creating... [10s elapsed]
module.ec2_instance.aws_subnet.public_subnet: Still creating... [10s elapsed]
module.ec2_instance.aws_subnet.public_subnet: Creation complete after 11s [id=subnet-00c2273d6bfd995c1]
module.ec2_instance.aws_security_group.security_group_ec2: Creating...
module.ec2_instance.aws_subnet.public_subnet_2: Creation complete after 11s [id=subnet-04dc6e7847481a072]
module.alb.aws_lb.alb: Creating...
module.ec2_instance.aws_security_group.security_group_ec2: Creation complete after 2s [id=sg-0dad38e7b8b5ae80b]
module.ec2_instance.aws_instance.sample: Creating...
module.ec2_instance.aws_launch_template.sample_launch_template: Creating...
module.ec2_instance.aws_launch_template.sample_launch_template: Creation complete after 6s [id=lt-0d7c5fcd416f790de]
module.ec2_instance.aws_autoscaling_group.autoscale: Creating...
module.alb.aws_lb.alb: Still creating... [10s elapsed]
module.ec2_instance.aws_instance.sample: Still creating... [10s elapsed]
module.ec2_instance.aws_instance.sample: Creation complete after 13s [id=i-0aaa3de5345a39424]
module.ec2_instance.aws_autoscaling_group.autoscale: Still creating... [10s elapsed]
module.alb.aws_lb.alb: Still creating... [20s elapsed]
module.ec2_instance.aws_autoscaling_group.autoscale: Creation complete after 15s [id=autoscale]
module.alb.aws_autoscaling_attachment.asg_attachment: Creating...
module.alb.aws_autoscaling_attachment.asg_attachment: Creation complete after 0s [id=autoscale-20250401232654120400000004]
module.alb.aws_lb.alb: Still creating... [30s elapsed]
module.alb.aws_lb.alb: Still creating... [40s elapsed]
module.alb.aws_lb.alb: Still creating... [50s elapsed]
module.alb.aws_lb.alb: Still creating... [1m0s elapsed]
module.alb.aws_lb.alb: Still creating... [1m10s elapsed]
module.alb.aws_lb.alb: Still creating... [1m20s elapsed]
module.alb.aws_lb.alb: Still creating... [1m30s elapsed]
module.alb.aws_lb.alb: Still creating... [1m40s elapsed]
module.alb.aws_lb.alb: Still creating... [1m50s elapsed]
module.alb.aws_lb.alb: Still creating... [2m0s elapsed]
module.alb.aws_lb.alb: Still creating... [2m10s elapsed]
module.alb.aws_lb.alb: Still creating... [2m20s elapsed]
module.alb.aws_lb.alb: Still creating... [2m30s elapsed]
module.alb.aws_lb.alb: Still creating... [2m40s elapsed]
module.alb.aws_lb.alb: Still creating... [2m50s elapsed]
module.alb.aws_lb.alb: Creation complete after 2m52s [id=arn:aws:elasticloadbalancing:eu-west-1:590184075527:loadbalancer/app/app-load-balancer/abd7ece0f4f775ff]
module.alb.aws_lb_listener.http: Creating...
module.alb.aws_lb_listener.http: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-west-1:590184075527:listener/app/app-load-balancer/abd7ece0f4f775ff/0ffc5d429559bc78]

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
```
</details>

# Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ./module-alb | n/a |
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | ./module-ec2 | n/a |

# Resources

No resources.

# Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_subnet_cidr"></a> [private\_subnet\_cidr](#input\_private\_subnet\_cidr) | Private Subnet CIDR | `string` | `"10.0.2.0/24"` | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | Public Subnet CIDR | `string` | `"10.0.1.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"eu-west-1"` | no |

# Outputs

No outputs.
<!-- END_TF_DOCS -->