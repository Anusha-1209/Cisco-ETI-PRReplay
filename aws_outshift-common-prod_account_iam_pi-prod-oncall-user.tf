resource "aws_iam_policy" "pi-prod-oncall-policy" {
  name        = "pi-prod-oncall-policy"
  description = "Prompt Intel OnCall IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor1",
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "iam:ListRoles",
          "eks:DescribeAddonVersions",
          "eks:ListIdentityProviderConfigs"
        ],
        Resource = [
          "arn:aws:eks:us-east-2:${local.account_id}:cluster/pi-prod-use2-1"
        ]
      }
    ]
  })
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

