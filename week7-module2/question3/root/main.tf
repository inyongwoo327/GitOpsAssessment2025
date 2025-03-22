provider "aws" {
    region = "eu-west-1"
}

module "s3_bucket" {
    source = "../s3_module"

    bucket_name = "evanwoo327-temp"
    environment = "dev"
    enable_versioning = true
    sse_algorithm = "AES256"
    block_public_access = true
}