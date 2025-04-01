
data "aws_iam_policy_document" "cil_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::075967417574:saml-provider/cloudsso.cisco.com"]
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
      identifiers = ["arn:aws:iam::075967417574:root"]
    }
  }
}



resource "aws_iam_role" "cil" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description           = "CIL role"
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::075967417574:policy/cil-policy",
  ]
  max_session_duration = 28800
  name                 = "cil"
  path                 = "/"
  tags                 = var.tags
}