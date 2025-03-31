resource "aws_iam_role" "motific-staging" {
  name               = local.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json
}

resource "aws_iam_policy" "motific-staging-s3" {
  name        = "${local.name}-s3"
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

resource "aws_iam_policy" "s3-cross-account-access" {
  name        = "${local.name}-s3-cross-account-access"
  path        = "/"
  description = "Policy for ${local.name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
          "Sid": "0",
          "Effect": "Allow",
          "Action": [
              "s3:*"
          ],
          "Resource": "arn:aws:s3:::vowel-dev-sagemaker/*"
      },
      {
          "Sid": "1",
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket"
          ],
          "Resource": "arn:aws:s3:::vowel-dev-sagemaker"
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "motific-staging-s3" {
  name       = "${local.name}-s3"
  roles      = [aws_iam_role.motific-staging.name]
  policy_arn = aws_iam_policy.motific-staging-s3.arn
}

resource "aws_iam_policy_attachment" "motific-staging-sagemaker" {
  name       = "${local.name}-sagemaker"
  roles      = [aws_iam_role.motific-staging.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_policy_attachment" "motific-staging-s3-cross-account-access" {
  name       = "${local.name}-s3-cross-account-access"
  roles      = [aws_iam_role.motific-staging.name]
  policy_arn = aws_iam_policy.s3-cross-account-access.arn
}