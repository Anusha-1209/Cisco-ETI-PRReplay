locals {
  number_of_role_policy_arns = coalesce(var.number_of_role_policy_arns, length(var.role_policy_arns))
}
data "aws_iam_policy_document" "assume_role_with_saml" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::626007623524:saml-provider/cloudsso.cisco.com"]
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

      identifiers = ["arn:aws:iam::626007623524:root"]
    }
  }
}

resource "aws_iam_role" "great-bear" {
  name                 = "great-bear"
  description          = "Great-Bear SSO IAM role access"
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

  role       = join("", aws_iam_role.great-bear.*.name)
  policy_arn = var.role_policy_arns[count.index]
}

