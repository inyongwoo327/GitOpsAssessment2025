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

variable "health_check_path" {
  description = "Path for the health check"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Protocol for the health check (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Port for the health check"
  type        = number
  default     = 80
}

variable "health_check_matcher" {
  description = "HTTP status code to use for health check success"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Interval between health checks (seconds)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health check response (seconds)"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks to consider healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks to consider unhealthy"
  type        = number
  default     = 2
}