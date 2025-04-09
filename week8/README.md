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
week8 git:(0409) ✗ terraform apply --auto-approve
module.ec2_instance[0].data.aws_ami.ubuntu[0]: Reading...
module.ec2_instance[1].data.aws_ami.ubuntu[0]: Reading...
module.ec2_instance[1].data.aws_ami.ubuntu[0]: Read complete after 0s [id=ami-01c7096235204c7be]
module.ec2_instance[0].data.aws_ami.ubuntu[0]: Read complete after 0s [id=ami-01c7096235204c7be]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.alb.aws_autoscaling_attachment.asg_attachment will be created
  + resource "aws_autoscaling_attachment" "asg_attachment" {
      + autoscaling_group_name = "autoscale-1"
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
          + healthy_threshold   = 3
          + interval            = 15
          + matcher             = "200-299"
          + path                = "/health"
          + port                = "traffic-port"
          + protocol            = "HTTP"
          + timeout             = 3
          + unhealthy_threshold = 3
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
                  + "0.0.0.0/0",
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

  # module.ec2_instance[0].aws_autoscaling_group.autoscale will be created
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
      + name                             = "autoscale-1"
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

  # module.ec2_instance[0].aws_instance.sample will be created
  + resource "aws_instance" "sample" {
      + ami                                  = "ami-01c7096235204c7be"
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
          + "Name" = "web-server-1"
        }
      + tags_all                             = {
          + "Name" = "web-server-1"
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

  # module.ec2_instance[0].aws_launch_template.sample_launch_template will be created
  + resource "aws_launch_template" "sample_launch_template" {
      + arn             = (known after apply)
      + default_version = (known after apply)
      + id              = (known after apply)
      + image_id        = "ami-01c7096235204c7be"
      + instance_type   = "t2.micro"
      + latest_version  = (known after apply)
      + name            = (known after apply)
      + name_prefix     = "launch-template-1-"
      + tags_all        = (known after apply)

      + metadata_options (known after apply)

      + network_interfaces {
          + associate_public_ip_address = "true"
          + security_groups             = (known after apply)
        }
    }

  # module.ec2_instance[0].aws_security_group.security_group_ec2 will be created
  + resource "aws_security_group" "security_group_ec2" {
      + arn                    = (known after apply)
      + description            = "Allow SSH and HTTP inbound traffic"
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
                  + "0.0.0.0/0",
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
      + name                   = "security_group_ec2-1"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # module.ec2_instance[1].aws_autoscaling_group.autoscale will be created
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
      + name                             = "autoscale-2"
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

  # module.ec2_instance[1].aws_instance.sample will be created
  + resource "aws_instance" "sample" {
      + ami                                  = "ami-01c7096235204c7be"
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
          + "Name" = "web-server-2"
        }
      + tags_all                             = {
          + "Name" = "web-server-2"
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

  # module.ec2_instance[1].aws_launch_template.sample_launch_template will be created
  + resource "aws_launch_template" "sample_launch_template" {
      + arn             = (known after apply)
      + default_version = (known after apply)
      + id              = (known after apply)
      + image_id        = "ami-01c7096235204c7be"
      + instance_type   = "t2.micro"
      + latest_version  = (known after apply)
      + name            = (known after apply)
      + name_prefix     = "launch-template-2-"
      + tags_all        = (known after apply)

      + metadata_options (known after apply)

      + network_interfaces {
          + associate_public_ip_address = "true"
          + security_groups             = (known after apply)
        }
    }

  # module.ec2_instance[1].aws_security_group.security_group_ec2 will be created
  + resource "aws_security_group" "security_group_ec2" {
      + arn                    = (known after apply)
      + description            = "Allow SSH and HTTP inbound traffic"
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
                  + "0.0.0.0/0",
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
      + name                   = "security_group_ec2-2"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # module.networking.aws_internet_gateway.gw will be created
  + resource "aws_internet_gateway" "gw" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "main-igw"
        }
      + tags_all = {
          + "Name" = "main-igw"
        }
      + vpc_id   = (known after apply)
    }

  # module.networking.aws_route_table.public will be created
  + resource "aws_route_table" "public" {
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
          + "Name" = "public-rt"
        }
      + tags_all         = {
          + "Name" = "public-rt"
        }
      + vpc_id           = (known after apply)
    }

  # module.networking.aws_route_table_association.public_1 will be created
  + resource "aws_route_table_association" "public_1" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.networking.aws_route_table_association.public_2 will be created
  + resource "aws_route_table_association" "public_2" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.networking.aws_subnet.private_subnet will be created
  + resource "aws_subnet" "private_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.3.0/24"
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
          + "Name" = "private-subnet"
        }
      + tags_all                                       = {
          + "Name" = "private-subnet"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.networking.aws_subnet.public_subnet_1 will be created
  + resource "aws_subnet" "public_subnet_1" {
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
          + "Name" = "public-subnet-1"
        }
      + tags_all                                       = {
          + "Name" = "public-subnet-1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.networking.aws_subnet.public_subnet_2 will be created
  + resource "aws_subnet" "public_subnet_2" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
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
          + "Name" = "public-subnet-2"
        }
      + tags_all                                       = {
          + "Name" = "public-subnet-2"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.networking.aws_vpc.main will be created
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
          + "Name" = "main-vpc"
        }
      + tags_all                             = {
          + "Name" = "main-vpc"
        }
    }

Plan: 21 to add, 0 to change, 0 to destroy.
module.networking.aws_vpc.main: Creating...
module.networking.aws_vpc.main: Creation complete after 2s [id=vpc-06686fbc881ab1e80]
module.networking.aws_internet_gateway.gw: Creating...
module.networking.aws_subnet.public_subnet_2: Creating...
module.networking.aws_subnet.public_subnet_1: Creating...
module.networking.aws_subnet.private_subnet: Creating...
module.alb.aws_security_group.alb_sg: Creating...
module.ec2_instance[0].aws_security_group.security_group_ec2: Creating...
module.ec2_instance[1].aws_security_group.security_group_ec2: Creating...
module.alb.aws_lb_target_group.tg: Creating...
module.networking.aws_internet_gateway.gw: Creation complete after 1s [id=igw-02aaa868935e04790]
module.networking.aws_route_table.public: Creating...
module.networking.aws_subnet.private_subnet: Creation complete after 1s [id=subnet-04abd163f4f4d2c19]
module.alb.aws_lb_target_group.tg: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-west-1:590184075527:targetgroup/alb-target-group/09b7fc82f98d70cf]
module.networking.aws_route_table.public: Creation complete after 1s [id=rtb-0ddfc0271f39561c5]
module.alb.aws_security_group.alb_sg: Creation complete after 2s [id=sg-0c09c6ec917d91eb9]
module.ec2_instance[1].aws_security_group.security_group_ec2: Creation complete after 2s [id=sg-007826b6281368b70]
module.ec2_instance[0].aws_security_group.security_group_ec2: Creation complete after 2s [id=sg-0d0a73f988ccc0884]
module.ec2_instance[1].aws_launch_template.sample_launch_template: Creating...
module.ec2_instance[0].aws_launch_template.sample_launch_template: Creating...
module.ec2_instance[0].aws_launch_template.sample_launch_template: Creation complete after 6s [id=lt-00a635b31ee12dc3e]
module.ec2_instance[1].aws_launch_template.sample_launch_template: Creation complete after 6s [id=lt-07602891d34d81fe0]
module.networking.aws_subnet.public_subnet_1: Still creating... [10s elapsed]
module.networking.aws_subnet.public_subnet_2: Still creating... [10s elapsed]
module.networking.aws_subnet.public_subnet_2: Creation complete after 11s [id=subnet-07d5b3acbc079a03d]
module.networking.aws_route_table_association.public_2: Creating...
module.networking.aws_route_table_association.public_2: Creation complete after 1s [id=rtbassoc-0508baa06fd46156c]
module.networking.aws_subnet.public_subnet_1: Creation complete after 13s [id=subnet-0ae5cac89ac974b72]
module.networking.aws_route_table_association.public_1: Creating...
module.alb.aws_lb.alb: Creating...
module.ec2_instance[0].aws_instance.sample: Creating...
module.ec2_instance[1].aws_instance.sample: Creating...
module.ec2_instance[1].aws_autoscaling_group.autoscale: Creating...
module.ec2_instance[0].aws_autoscaling_group.autoscale: Creating...
module.networking.aws_route_table_association.public_1: Creation complete after 0s [id=rtbassoc-0cdbb8c0f9df73fde]
module.alb.aws_lb.alb: Still creating... [10s elapsed]
module.ec2_instance[0].aws_instance.sample: Still creating... [10s elapsed]
module.ec2_instance[1].aws_instance.sample: Still creating... [10s elapsed]
module.ec2_instance[1].aws_autoscaling_group.autoscale: Still creating... [10s elapsed]
module.ec2_instance[0].aws_autoscaling_group.autoscale: Still creating... [10s elapsed]
module.ec2_instance[0].aws_instance.sample: Creation complete after 12s [id=i-0592b69329de006d5]
module.ec2_instance[1].aws_instance.sample: Creation complete after 13s [id=i-0706daf9a0947791c]
module.ec2_instance[1].aws_autoscaling_group.autoscale: Creation complete after 15s [id=autoscale-2]
module.ec2_instance[0].aws_autoscaling_group.autoscale: Creation complete after 15s [id=autoscale-1]
module.alb.aws_autoscaling_attachment.asg_attachment: Creating...
module.alb.aws_autoscaling_attachment.asg_attachment: Creation complete after 0s [id=autoscale-1-20250409183625355000000008]
module.alb.aws_lb.alb: Still creating... [20s elapsed]
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
module.alb.aws_lb.alb: Creation complete after 2m52s [id=arn:aws:elasticloadbalancing:eu-west-1:590184075527:loadbalancer/app/app-load-balancer/5989dbf5281d6ca1]
module.alb.aws_lb_listener.http: Creating...
module.alb.aws_lb_listener.http: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-west-1:590184075527:listener/app/app-load-balancer/5989dbf5281d6ca1/227659213d4c9342]

Apply complete! Resources: 21 added, 0 changed, 0 destroyed.
```
</details>

# Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ./module-alb | n/a |
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | ./module-ec2 | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./networking | n/a |

# Resources

No resources.

# Inputs

No inputs.

# Outputs

No outputs.
<!-- END_TF_DOCS -->