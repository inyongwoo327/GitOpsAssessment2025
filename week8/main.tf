provider "aws" {
  region = "eu-west-1"
}

module "ec2_instance" {
    source = "./module-ec2"
}

module "alb" {
  source     = "./module-alb"
  vpc_id     = module.ec2_instance.vpc_id
  subnet_ids = module.ec2_instance.public_subnet_ids
  asg_name   = module.ec2_instance.autoscaling_group_name
}