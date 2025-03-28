resource "aws_iam_role" "motific-staging" {
  name               = local.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json
}

resource "aws_iam_policy" "motific-staging" {
  name        = local.name
  path        = "/"
  description = "Policy for ${local.name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "motific-staging" {
  name       = local.name
  roles      = [aws_iam_role.motific-staging.name]
  policy_arn = aws_iam_policy.motific-staging.arn
}