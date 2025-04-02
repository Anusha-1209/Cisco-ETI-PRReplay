
# IAM Policies
data "aws_iam_policy_document" "assume_role_with_saml" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::792074902331:saml-provider/cloudsso.cisco.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::792074902331:root"]
    }
  }
}

data "aws_iam_policy" "developer-access" {
    name = "developer-access"
}

# IAM Roles
resource "aws_iam_role" "deneb" {
  name                 = "deneb"
  description          = "Deneb SSO IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = false
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_saml.json

  managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess" ]

}

resource "aws_iam_role_policy_attachment" "deneb-developer-access" {
    role = aws_iam_role.deneb.name
    policy_arn = data.aws_iam_policy.developer-access.arn
}

