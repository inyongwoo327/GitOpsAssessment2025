terraform {
  backend "s3" {
    bucket         = "k3s-ha-ew-terraform-state-bucket"
    key            = "k3s-ha-cluster/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "k3s-ha-terraform-state-lock"
    encrypt        = true
  }
}