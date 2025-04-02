provider "aws" {
  region = local.aws_region
}

# Define the IAM policy for S3 access
data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}

# Create the IAM role
resource "aws_iam_role" "eks_s3_access_role" {
  name = "${local.aws_account_name}-eks-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_provider_url}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_url}:sub" = "system:serviceaccount:dragonfly-backend:*"
          }
        }
      }
    ]
  })
}

# Attach the S3 access policy to the role
resource "aws_iam_policy" "s3_access_policy" {
  name   = "${local.aws_account_name}-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.eks_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Get the AWS account ID
data "aws_caller_identity" "current" {}

# OIDC Provider URL
locals {
  eks_oidc_provider_url = "oidc.eks.${local.aws_region}.amazonaws.com/id/${local.eks_oidc_provider_id}"
}