variable "aws_region" {
  description = "AWS region for the S3 bucket and DynamoDB table"
  type        = string
  default     = "eu-west-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state (must be globally unique)"
  type        = string
  default     = "k3s-ha-ew-terraform-state-bucket"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "k3s-ha-terraform-state-lock"
}