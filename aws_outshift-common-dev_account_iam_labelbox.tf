data "aws_iam_policy_document" "labelbox-policy-document" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
        "arn:aws:s3:::pi-labelbox-datasets/*",
        "arn:aws:s3:::pi-labelbox-datasets"
    ]

  }
}

resource "aws_iam_role" "labelbox" {
  name                 = "labelbox"
  description          = "Prompt Intel LabelBox IAM role access"
  path                 = "/"
  max_session_duration = "3600"

  force_detach_policies = true
  permissions_boundary  = ""

  assume_role_policy = data.aws_iam_policy_document.labelbox-external-account.json
}

resource "aws_iam_role_policy_attachment" "labelbox-policy-attachment" {
    role = aws_iam_role.labelbox.name
    policy_arn = aws_iam_policy.labelbox-policy.arn
}

resource "aws_iam_policy" "labelbox-policy" {
  name        = "labelbox-policy"
  description = "Prompt Intel OnCall IAM Policy"
  policy = data.aws_iam_policy_document.labelbox-policy-document.json
}

