bootstrap git:(main) ✗ terraform apply --auto-approve
aws_dynamodb_table.terraform_locks: Refreshing state... [id=dynamodb-test]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.terraform_state will be created
  + resource "aws_s3_bucket" "terraform_state" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "testevanwoo327"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name" = "terraform-state-bucket"
        }
      + tags_all                    = {
          + "Name" = "terraform-state-bucket"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket_server_side_encryption_configuration.encryption will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm     = "AES256"
                # (1 unchanged attribute hidden)
            }
        }
    }

  # aws_s3_bucket_versioning.versioning will be created
  + resource "aws_s3_bucket_versioning" "versioning" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.
aws_s3_bucket.terraform_state: Creating...
aws_s3_bucket.terraform_state: Creation complete after 2s [id=testevanwoo327]
aws_s3_bucket_versioning.versioning: Creating...
aws_s3_bucket_server_side_encryption_configuration.encryption: Creating...
aws_s3_bucket_server_side_encryption_configuration.encryption: Creation complete after 1s [id=testevanwoo327]
aws_s3_bucket_versioning.versioning: Creation complete after 2s [id=testevanwoo327]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.




------------------------------------

question2 git:(main) ✗ terraform init -migrate-state                                 
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.92.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.