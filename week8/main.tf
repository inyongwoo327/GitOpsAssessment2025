provider "aws" {
  region = "eu-west-1"
}

# module "ec2_instance" {
#     source = "./module-ec2"
#     count = 2
# }

# module "alb" {
#   source     = "./module-alb"
#   vpc_id     = module.ec2_instance.vpc_id
#   subnet_ids = module.ec2_instance.public_subnet_ids
#   asg_name   = module.ec2_instance.autoscaling_group_name
# }

module "networking" {
  source = "./networking"
}

module "ec2_instance" {
  count              = 2
  source             = "./module-ec2"
  vpc_id             = module.networking.vpc_id
  subnet_id          = module.networking.public_subnet_ids[0]
  subnet_ids         = module.networking.public_subnet_ids
  instance_type      = "t2.micro"
  key_name           = "test"
  ubuntu_version     = "jammy-22.04"
  instance_name_prefix = "web-server"
  instance_index     = count.index + 1
}

module "alb" {
  source                        = "./module-alb"
  vpc_id                        = module.networking.vpc_id
  subnet_ids                    = module.networking.public_subnet_ids
  asg_name                      = module.ec2_instance[0].autoscaling_group_name
  health_check_path             = "/health"
  health_check_matcher          = "200-299"
  health_check_interval         = 15
  health_check_timeout          = 3
  health_check_healthy_threshold   = 3
  health_check_unhealthy_threshold = 3
}