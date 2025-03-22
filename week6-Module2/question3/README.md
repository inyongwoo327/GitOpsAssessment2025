# Result of terraform plan for IAM role, policy, and attachment

```
question3 git:(main) ✗ terraform plan
data.aws_iam_policy_document.ec2_policy: Reading...
data.aws_iam_policy_document.s3_policy: Reading...
data.aws_iam_policy_document.instance_assume_role_policy: Reading...
data.aws_iam_policy_document.instance_assume_role_policy: Read complete after 0s [id=2851119427]
data.aws_iam_policy_document.ec2_policy: Read complete after 0s [id=2218315402]
data.aws_iam_policy_document.s3_policy: Read complete after 0s [id=3732469000]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  aws_iam_policy.ec2_policy will be created
  + resource "aws_iam_policy" "ec2_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Policy for EC2 describe actions"
      + id               = (known after apply)
      + name             = "ec2_policies"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = "ec2:Describe*"
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  aws_iam_policy.s3_policy will be created
  + resource "aws_iam_policy" "s3_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Policy for S3 bucket listing"
      + id               = (known after apply)
      + name             = "s3_policies"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ListBucket",
                          + "s3:ListAllMyBuckets",
                          + "s3:HeadBucket",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  aws_iam_role.example will be created
  + resource "aws_iam_role" "example" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "terraform_role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  aws_iam_role_policy_attachment.ec2_attachment will be created
  + resource "aws_iam_role_policy_attachment" "ec2_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "terraform_role"
    }

  aws_iam_role_policy_attachment.s3_attachment will be created
  + resource "aws_iam_role_policy_attachment" "s3_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "terraform_role"
    }

Plan: 5 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.

```