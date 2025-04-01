data "aws_iam_policy_document" "artifacts" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = ["arn:aws:s3:::cisco-eti-gbear-artifacts-*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = ["arn:aws:s3:::cisco-eti-gbear-artifacts-*/*"]
  }
}
