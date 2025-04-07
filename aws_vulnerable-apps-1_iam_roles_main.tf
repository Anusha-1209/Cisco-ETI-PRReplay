
# IAM Policies
data "aws_iam_policy_document" "vae_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::787431943109:saml-provider/cloudsso.cisco.com"]
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
      identifiers = ["arn:aws:iam::787431943109:root"]
    }
  }
}

# IAM Roles
resource "aws_iam_role" "vae" {
  assume_role_policy   = data.aws_iam_policy_document.vae_assume_role.json
  description          = "vae SSO IAM role access"
  force_detach_policies = false
  managed_policy_arns   = [
     "arn:aws:iam::787431943109:policy/vae-policy",
     ]
  max_session_duration = "3600"
  name                 = "vae"
  path                 = "/"
}