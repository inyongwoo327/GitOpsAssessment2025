provider "aws" {
    region = "eu-west-1"
}

resource "aws_s3_bucket" "test_bucket" {
    bucket = "test"

    tags = {
        Name = "test"
        Environment = "DEV"
    }
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.test_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}