terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
    backend "s3" {
        bucket         = "evanwoo327-terraform-state"
        key            = "terraform/state"
        region         = "eu-west-1"
        dynamodb_table = "terraform-locks"
        encrypt        = true
    }
}