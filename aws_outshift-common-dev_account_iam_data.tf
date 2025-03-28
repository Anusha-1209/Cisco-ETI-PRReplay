data "aws_caller_identity" "current" {}

# IAM Policies
data "aws_iam_policy_document" "assume_role_with_saml" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::${local.account_id}:saml-provider/cloudsso.cisco.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_account" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }
}