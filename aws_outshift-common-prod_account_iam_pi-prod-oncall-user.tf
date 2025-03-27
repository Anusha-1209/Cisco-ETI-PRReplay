data "aws_iam_policy_document" "pi-prod-oncall-policy-document" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "eks:ListClusters"
    ]
    resources = [
      "arn:aws:eks:us-east-2:${local.account_id}:cluster/*"
    ]
  }

  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListNodegroups",
      "iam:ListRoles",
      "eks:DescribeAddonVersions",
      "eks:ListIdentityProviderConfigs"
    ]
    resources = [
      "arn:aws:eks:us-east-2:${local.account_id}:cluster/pi-prod-use2-1"
    ]
  }
}
resource "aws_iam_policy" "pi-prod-oncall-policy" {
  name        = "pi-prod-oncall-policy"
  description = "Prompt Intel OnCall IAM Policy"
  policy = data.aws_iam_policy_document.pi-prod-oncall-policy-document.json
}


# IAM Roles
resource "aws_iam_role" "pi-prod-oncall-role" {
  name                 = "pi-prod-oncall"
  description          = "Prompt Intel OnCall SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = false
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
}

resource "aws_iam_role_policy_attachment" "pi-prod-oncall-policy-attachment" {
    role = aws_iam_role.pi-prod-oncall-role.name
    policy_arn = aws_iam_policy.pi-prod-oncall-policy.arn
}

