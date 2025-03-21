terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }
  backend "s3" {
    bucket = "testevanwoo327"
    key = "terraform/state"
    region = "eu-west-1"
    dynamodb_table = "dynamodb-test"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "terraform-test"
}