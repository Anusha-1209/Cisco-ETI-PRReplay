resource "aws_iam_policy" "secretsmanager-syc-rw" {
  name        = "secretsmanager-syc-rw"
  path        = "/"
  description = "secretsmanager rw access for symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : "arn:aws:secretsmanager:us-east-2:626007623524:secret:syc/dev/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:RestoreSecret"
        ],
        "Resource" : "arn:aws:secretsmanager:us-east-2:626007623524:secret:syc/dev/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:GetRandomPassword"
        ],
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })

  tags = {
    Name = "secretsmanager-syc-rw"
  }
}
