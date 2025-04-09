# variable "vpc_cidr" {
#   description = "VPC CIDR"
#   type        = string
#   default     = "10.0.0.0/16"
# }

variable "bucket_name" {
  description = "Bootstrap Bucket Name"
  type        = string
  default = "module-practice-bucket"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the EC2 instance"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the autoscaling group"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_another" {
  description = "Another Instance Type for mixed instances policy"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimal size for ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximal size for ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired size for ASG"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "Key Name for EC2 instance"
  type        = string
  default     = "test"
}

variable "ubuntu_version" {
  description = "Ubuntu version (e.g., noble-24.04, jammy-22.04, focal-20.04)"
  type        = string
  default     = "jammy-22.04"
}

variable "instance_name_prefix" {
  description = "Prefix for EC2 instance name"
  type        = string
  default     = "web-server"
}

variable "instance_index" {
  description = "Index to make instance names unique"
  type        = string
  default     = "1"
}