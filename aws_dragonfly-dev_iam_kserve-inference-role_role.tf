data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_id}",
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values = ["sts.amazonaws.com"]
      variable = "${local.oidc_id}:aud"
    }
    condition {
      test     = "StringEquals"
      values = ["system:serviceaccount:${local.service_account}"]
      variable = "${local.oidc_id}:sub"
    }
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::dragonfly-dev-ml-models"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:*Object",
    ]

    resources = [
      "arn:aws:s3:::dragonfly-dev-ml-models/*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  name        = local.role_name
  description = local.role_description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  inline_policy {
    name   = "kserve-inference-policy"
    policy = data.aws_iam_policy_document.policy.json
  }

  managed_policy_arns = []
}
