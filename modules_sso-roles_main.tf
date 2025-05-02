# IAM role 
resource "aws_iam_role" "this" {
  name                 = var.role_name
  max_session_duration = "3600"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_with_saml.json
  tags                 = var.tags
}

# Attach PowerUserAccess AWS Managed Policy 
resource "aws_iam_role_policy_attachment" "power_user_access_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn
}

# Attach the IAMReadOnlyAccess AWS Managed policy
resource "aws_iam_role_policy_attachment" "iam_read_only_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = var.iam_read_only_policy_arn
}