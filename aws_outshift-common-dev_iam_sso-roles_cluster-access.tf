data "aws_iam_policy_document" "cluster-access-policy-document" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "eks:ListClusters",
      "sts:AssumeRole",
      "sts:GetCallerIdentity",
      "sts:AssumeRoleWithSAML",
      "sts:AssumeRoleWithWebIdentity"
    ]
    resources = [
      "*"
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
resource "aws_iam_policy" "cluster-access-policy" {
  name        = "cluster-access-policy"
  description = "EKS Cluster Access IAM Policy"
  policy = data.aws_iam_policy_document.cluster-access-policy-document.json
}


# IAM Roles
resource "aws_iam_role" "cluster-access-role" {
  name                 = "cluster-access"
  description          = "EKS Cluster Access SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = false
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
}

resource "aws_iam_role_policy_attachment" "cluster-access-policy-attachment" {
    role = aws_iam_role.cluster-access-role.name
    policy_arn = aws_iam_policy.cluster-access-policy.arn
}

