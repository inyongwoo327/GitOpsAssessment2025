variable "region" {
    type = string
    default = "eu-west-1"
}

variable "bucket_name" {
  description = "Bootstrap Bucket Name"
  type        = string
  default = "module-practice-bucket"
}

variable "dynamodb_table_name" {
  description = "Dynamo DB Table Name"
  type        = string
  default = "module_practice_db"
}

variable "billing_mode" {
  description = "Billing Mode"
  type        = string
  default = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Hash Key"
  type        = string
  default = "LockID"
}