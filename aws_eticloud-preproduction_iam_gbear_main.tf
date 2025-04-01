locals {
  number_of_role_policy_arns = coalesce(var.number_of_role_policy_arns, length(var.role_policy_arns))
}

# IAM Policies
data "aws_iam_policy_document" "assume_role_with_saml" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::792074902331:saml-provider/cloudsso.cisco.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = [var.aws_saml_endpoint]
    }
  }

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::792074902331:root"]
    }
  }
}
# IAM Roles
resource "aws_iam_role" "gbear" {
  name                 = "gbear"
  description          = "GreatBear SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = var.force_detach_policies
  permissions_boundary  = var.role_permissions_boundary_arn

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json

  inline_policy {
    name   = "artifacts"
    policy = data.aws_iam_policy_document.artifacts.json
  }

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_role ? local.number_of_role_policy_arns : 0

  role       = join("", aws_iam_role.gbear.*.name)
  policy_arn = var.role_policy_arns[count.index]
}

# access to harbor-dev

data "aws_iam_policy_document" "harbor_prep_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::792074902331:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/CA69980120572BAEE934CBCF59E61009"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.eu-west-1.amazonaws.com/id/CA69980120572BAEE934CBCF59E61009:sub"
      values   = ["system:serviceaccount:harbor:harbor"]
    }
  }
}

# https://docs.docker.com/registry/storage-drivers/s3/#s3-permission-scopes
data "aws_iam_policy_document" "harbor_prep_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]

    resources = ["arn:aws:s3:::cisco-eti-harbor-gbear-dev"]
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

    resources = ["arn:aws:s3:::cisco-eti-harbor-gbear-dev/*"]
  }
}

resource "aws_iam_role" "harbor_prep" {
  name        = "harbor-gbear-prep"
  description = "Harbor gbear prep IAM service account role"
  path        = "/"

  assume_role_policy = data.aws_iam_policy_document.harbor_prep_assume_role.json

  inline_policy {
    name   = "harbor-dev-s3-registry-data"
    policy = data.aws_iam_policy_document.harbor_prep_data.json
  }

  force_detach_policies = false
  managed_policy_arns   = []
  max_session_duration  = 28800

  tags = var.tags
}
