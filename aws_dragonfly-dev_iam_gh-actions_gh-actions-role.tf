data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:cisco-eti/*:*"]
    }
  }
}

# GHA IAM policy
data "aws_iam_policy_document" "gha_policy" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = ["arn:aws:s3:::dragonfly-*"]
    effect    = "Allow"
  }
}

# GHA IAM Role
resource "aws_iam_role" "gha_role" {
  name        = "gh-actions-role"
  description = "IAM Role for GH Actions workflows"
  tags        = var.tags

  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json
  inline_policy {
    name   = "gha-policy"
    policy = data.aws_iam_policy_document.gha_policy.json
  }
  managed_policy_arns = []
}
