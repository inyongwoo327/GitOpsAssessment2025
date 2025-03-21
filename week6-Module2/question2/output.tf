output "s3_bucket_id" {
    description = "s3 bucket id"
    value = aws_s3_bucket.test_bucket.id
}