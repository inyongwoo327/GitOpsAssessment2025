variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bucket_name" {
  description = "Bootstrap Bucket Name"
  type        = string
  default = "module-practice-bucket"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_another" {
  description = "Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimal size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximal size"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired size"
  type        = number
  default     = 1
}

variable "aws_launch_template_name" {
  description = "AWS Launch Template Name"
  type        = string
  default = "template-name"
}

variable "key_name" {
  description = "Key Name"
  type        = string
  default = "terraform/state"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}