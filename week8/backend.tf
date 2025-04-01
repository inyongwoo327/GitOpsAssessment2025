terraform {
    backend "s3" {
        bucket         = "module-practice-bucket"
        key            = "terraform/state"
        region         = "eu-west-1"
        dynamodb_table = "module_practice_db"
        encrypt        = true
    }
}