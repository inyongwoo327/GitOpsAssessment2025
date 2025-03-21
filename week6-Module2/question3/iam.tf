data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "example" {
  name                = "terraform_role"
  assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json
}

# EC2 Policy Document
data "aws_iam_policy_document" "ec2_policy" {
  statement {
    actions   = ["ec2:Describe*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

# S3 Policy Document
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:HeadBucket"]
    effect    = "Allow"
    resources = ["*"]
  }
}

# Alternative: Separate Policies
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policies"
  description = "Policy for EC2 describe actions"
  policy      = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policies"
  description = "Policy for S3 bucket listing"
  policy      = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_attachment" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.s3_policy.arn
}