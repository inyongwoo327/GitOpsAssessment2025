variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "eu-west-1a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "eu-west-1b"
}