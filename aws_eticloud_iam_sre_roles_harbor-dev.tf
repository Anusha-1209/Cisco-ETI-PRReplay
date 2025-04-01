data "aws_iam_policy_document" "harbor_dev_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::626007623524:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/E0C6C89945F38AA7EB162DA79ED9A00F"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.us-east-2.amazonaws.com/id/E0C6C89945F38AA7EB162DA79ED9A00F:sub"
      values   = ["system:serviceaccount:harbor-dev:harbor"]
    }
  }
}

# https://docs.docker.com/registry/storage-drivers/s3/#s3-permission-scopes
data "aws_iam_policy_document" "harbor_dev_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]

    resources = ["arn:aws:s3:::cisco-eti-harbor-dev"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*", # Listed permissions are not enough (probably because of the health check?)
      # "s3:PutObject",
      # "s3:GetObject",
      # "s3:DeleteObject",
      # "s3:ListMultipartUploadParts",
      # "s3:AbortMultipartUpload",
    ]

    resources = ["arn:aws:s3:::cisco-eti-harbor-dev/*"]
  }
}

resource "aws_iam_role" "harbor_dev" {
  name        = "harbor-dev"
  description = "Harbor dev IAM service account role"
  path        = "/"

  assume_role_policy = data.aws_iam_policy_document.harbor_1_assume_role.json

  inline_policy {
    name   = "harbor-dev-s3-registry-data"
    policy = data.aws_iam_policy_document.harbor_1_data.json
  }

  force_detach_policies = false
  managed_policy_arns   = []
  max_session_duration  = 28800

  tags = var.tags
}
