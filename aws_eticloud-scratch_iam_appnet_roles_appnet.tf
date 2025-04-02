
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

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::738304443349:root"]
    }
  }
}



resource "aws_iam_role" "appnet" {
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
  description           = "AppNet EKS role"
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::380642323071:policy/appnet-create-role",
    "arn:aws:iam::380642323071:policy/appnet-tgw-policy",
    "arn:aws:iam::380642323071:policy/devopsAllEKS",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::380642323071:policy/banzai-artifacts"
  ]
  max_session_duration = 28800
  name                 = "appnet"
  path                 = "/"
  tags                 = var.tags
}