resource "aws_iam_user" "artifacts" {
  name = "gbear-artifacts"
  path = "/"
}

resource "aws_iam_user_policy" "artifacts" {
  name = "artifacts"
  user = aws_iam_user.artifacts.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::cisco-eti-gbear-artifacts*"
      },
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::cisco-eti-gbear-artifacts*/*"
      },
    ]
  })
}

# Atlantis can't access this namespace
resource "aws_iam_access_key" "artifacts" {
  user = aws_iam_user.artifacts.name
}

resource "vault_generic_secret" "artifacts" {
  # namespace = "eticloud/apps/alcor"

  path = "secret/eticcprod/iam/gbear-artifacts"
  data_json = jsonencode({
    access-key = aws_iam_access_key.artifacts.id
    secret-key = aws_iam_access_key.artifacts.secret
  })
}
