data "aws_iam_policy_document" "pi-dev-policy-document" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::pi-labelbox-datasets"
    ]
  }

  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::pi-labelbox-datasets/*"
    ]
  }
}
resource "aws_iam_policy" "pi-dev-policy" {
  name        = "pi-dev-policy"
  description = "Prompt Intel OnCall IAM Policy"
  policy = data.aws_iam_policy_document.pi-dev-policy-document.json
}


# IAM Roles
resource "aws_iam_role" "pi-dev" {
  name                 = "pi-dev"
  description          = "Prompt Intel Dev SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = false
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
}

resource "aws_iam_role_policy_attachment" "pi-dev-policy-attachment" {
    role = aws_iam_role.pi-dev.name
    policy_arn = aws_iam_policy.pi-dev-policy.arn
}