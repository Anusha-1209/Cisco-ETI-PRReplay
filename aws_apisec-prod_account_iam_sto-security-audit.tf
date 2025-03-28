data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# IAM Roles
resource "aws_iam_role" "sto-security-audit-role" {
  name                 = "sto-security-audit"
  description          = "STO Security Audit SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = false
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json
}

resource "aws_iam_role_policy_attachment" "sto-security-audit-policy-attachment" {
    role = aws_iam_role.sto-security-audit-role.name
    policy_arn = aws_iam_policy.ReadOnlyAccess.arn
}

