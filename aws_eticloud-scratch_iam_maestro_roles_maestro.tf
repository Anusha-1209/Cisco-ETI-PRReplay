
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::380642323071:saml-provider/cloudsso.cisco.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::380642323071:root"]
    }
  }
}



resource "aws_iam_role" "maestro" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  # jsonencode(
  #     {
  #         Statement = [
  #             {
  #                 Action    = "sts:AssumeRoleWithSAML"
  #                 Condition = {
  #                     StringEquals = {
  #                         SAML:aud = "https://signin.aws.amazon.com/saml"
  #                     }
  #                 }
  #                 Effect    = "Allow"
  #                 Principal = {
  #                     Federated = "arn:aws:iam::380642323071:saml-provider/cloudsso.cisco.com"
  #                 }
  #             },
  #             {
  #                 Action    = "sts:AssumeRole"
  #                 Effect    = "Allow"
  #                 Principal = {
  #                     AWS = "arn:aws:iam::380642323071:root"
  #                 }
  #             },
  #             {
  #                 Action    = "sts:AssumeRole"
  #                 Condition = {}
  #                 Effect    = "Allow"
  #                 Principal = {
  #                     AWS = "arn:aws:iam::738304443349:root"
  #                 }
  #             },
  #         ]
  #         Version   = "2012-10-17"
  #     }
  # )
  description           = "Maestro Developer role"
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::380642323071:policy/maestro-developer-policy",
    "arn:aws:iam::380642323071:policy/sre-list-aliases-fix"
  ]
  max_session_duration = 28800
  name                 = "maestro"
  path                 = "/"
  tags                 = var.tags
}