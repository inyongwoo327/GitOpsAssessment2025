variable "environment" {
  description = "Environment for the bucket (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "block_public_access" {
  description = "Block all public access to the bucket"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
  default     = "evanwoo327-temp"
}