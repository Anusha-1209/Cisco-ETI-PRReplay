resource "aws_db_proxy" "motf_staging" {
  name                   = "motf-staging-1"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 5400
  require_tls            = true
  role_arn               = aws_iam_role.example.arn
  vpc_security_group_ids = [aws_security_group.example.id]
  vpc_subnet_ids         = [aws_subnet.example.id]

  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.example.arn
  }

  tags = {
    Name = "example"
    Key  = "value"
  }
}

resource "aws_iam_role" "secrets_manager_motf_staging" {
  name = "secrets-manager-motf-staging-1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_policy_motf_staging" {
  name        = "secrets_manager_policy"
  description = "Policy to allow access to AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.secrets_manager_motf_staging.name
  policy_arn = aws_iam_policy.secrets_manager_policy_motf_staging.arn
}
