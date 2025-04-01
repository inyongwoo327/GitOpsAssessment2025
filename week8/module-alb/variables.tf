variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "asg_name" {
  description = "Name of the autoscaling group to attach to the ALB"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

# variable "public_subnet_cidr" {
#   description = "Public Subnet CIDR"
#   type        = string
#   default     = "10.0.1.0/24"
# }