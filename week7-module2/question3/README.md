# Exercise:
create a s3 module in terraform

## Folder Structure

```

```

# STEP 1: Create s3 backend (remote state) bucket first.

<details>
  <summary>Show the `terraform plan`</summary>
  
```
bootstrap git:(main) ✗ terraform apply               

Terraform used the selected providers to generate the following
execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  aws_dynamodb_table.terraform_locks will be created
  + resource "aws_dynamodb_table" "terraform_locks" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "terraform-locks"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Name" = "terraform-lock-table"
        }
      + tags_all         = {
          + "Name" = "terraform-lock-table"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  aws_s3_bucket.terraform_state will be created
  + resource "aws_s3_bucket" "terraform_state" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "evanwoo327-terraform-state"
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

  aws_s3_bucket_server_side_encryption_configuration.encryption will be created
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

  aws_s3_bucket_versioning.versioning will be created
  + resource "aws_s3_bucket_versioning" "versioning" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_dynamodb_table.terraform_locks: Creating...
aws_s3_bucket.terraform_state: Creating...
aws_s3_bucket.terraform_state: Creation complete after 3s [id=evanwoo327-terraform-state]
aws_s3_bucket_versioning.versioning: Creating...
aws_s3_bucket_server_side_encryption_configuration.encryption: Creating...
aws_s3_bucket_server_side_encryption_configuration.encryption: Creation complete after 0s [id=evanwoo327-terraform-state]
aws_s3_bucket_versioning.versioning: Creation complete after 1s [id=evanwoo327-terraform-state]
aws_dynamodb_table.terraform_locks: Creation complete after 7s [id=terraform-locks]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```
</details>

# STEP 2: Then create application s3 bucket

<details>
  <summary>Show the `terraform plan`</summary>
  
```
root git:(main) ✗ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.s3_bucket.aws_s3_bucket.bucket will be created
  + resource "aws_s3_bucket" "bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "evanwoo327-temp"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "Name"        = "evanwoo327-temp"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "Name"        = "evanwoo327-temp"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + object_lock_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)
    }

  # module.s3_bucket.aws_s3_bucket_public_access_block.public_access[0] will be created
  + resource "aws_s3_bucket_public_access_block" "public_access" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.encryption will be created
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

  # module.s3_bucket.aws_s3_bucket_versioning.versioning will be created
  + resource "aws_s3_bucket_versioning" "versioning" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + s3_bucket_arn = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.s3_bucket.aws_s3_bucket.bucket: Creating...
module.s3_bucket.aws_s3_bucket.bucket: Creation complete after 4s [id=evanwoo327-temp]
module.s3_bucket.aws_s3_bucket_public_access_block.public_access[0]: Creating...
module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.encryption: Creating...
module.s3_bucket.aws_s3_bucket_versioning.versioning: Creating...
module.s3_bucket.aws_s3_bucket_public_access_block.public_access[0]: Creation complete after 0s [id=evanwoo327-temp]
module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.encryption: Creation complete after 1s [id=evanwoo327-temp]
module.s3_bucket.aws_s3_bucket_versioning.versioning: Creation complete after 2s [id=evanwoo327-temp]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

s3_bucket_arn = "arn:aws:s3:::evanwoo327-temp"

```
</details>