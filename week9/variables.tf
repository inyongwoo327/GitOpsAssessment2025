variable "aws_region" {
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "test"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "local_ip" {
  description = "Local CIDR"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "eu-west-1a"
}