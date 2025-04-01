data "aws_iam_policy_document" "harbor_1_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::626007623524:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD:sub"
      values   = ["system:serviceaccount:harbor:harbor"]
    }
  }
}

# https://docs.docker.com/registry/storage-drivers/s3/#s3-permission-scopes
data "aws_iam_policy_document" "harbor_1_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]

    resources = ["arn:aws:s3:::cisco-eti-data-harbor-1"]
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

    resources = ["arn:aws:s3:::cisco-eti-data-harbor-1/*"]
  }
}

resource "aws_iam_role" "harbor_1" {
  name        = "harbor-1"
  description = "Harbor-1 IAM service account role"
  path        = "/"

  assume_role_policy = data.aws_iam_policy_document.harbor_1_assume_role.json

  inline_policy {
    name   = "harbor-1-s3-registry-data"
    policy = data.aws_iam_policy_document.harbor_1_data.json
  }

  force_detach_policies = false
  managed_policy_arns   = []
  max_session_duration  = 28800

  tags = var.tags
}
