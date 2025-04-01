data "aws_iam_policy_document" "banzai_artifacts" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    resources = [
      "arn:aws:ecr:us-east-2:033498657557:repository/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::cisco-eti-banzai-binaries"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::cisco-eti-banzai-binaries/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::cisco-eti-banzai-charts"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::cisco-eti-banzai-charts/*"]
  }
}

resource "aws_iam_policy" "banzai_artifacts" {
  name        = "appnet-banzai-artifacts"
  path        = "/"
  description = "Appnet Banzai artifact access"

  policy = data.aws_iam_policy_document.banzai_artifacts.json
}
