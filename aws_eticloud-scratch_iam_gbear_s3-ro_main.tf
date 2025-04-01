# Assume role policy

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::380642323071:saml-provider/cloudsso.cisco.com"]
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
      identifiers = ["arn:aws:iam::380642323071:root"]
    }
  }
}

# IAM Role

resource "aws_iam_role" "gbear_s3_ro" {
    name = "gbear-s3-ro"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
    force_detach_policies = true
    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}
