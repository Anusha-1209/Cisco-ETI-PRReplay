resource "aws_iam_policy" "aws_motf_unified_plugins_policy" {
  name        = "motf-preview-unified-plugins-policy"
  description = "AWS motific unified plugins Role IAM Policy"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid      = "VisualEditor0",
        Effect   = "Allow",
        Action   = [
          "sagemaker:ListEndpointConfigs",
          "sagemaker:ListEndpoints"
        ],
        Resource = "*"
      },
      {
        Sid      = "VisualEditor1",
        Effect   = "Allow",
        Action   = [
          "sagemaker:InvokeEndpoint",
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::961088030672:role/motf-preview-unified-plugins-role",
          "arn:aws:sagemaker:*:961088030672:endpoint/*"
        ]
      },
      {
        Sid      = "AdditionalPermissions",
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      },
      {
        Sid      = "KMSPermissions",
        Effect   = "Allow",
        Action   = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid      = "FullS3Access",
        Effect   = "Allow",
        Action   = [
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "aws_motf_unified_plugins_role" {
  name                = "motf-preview-unified-plugins-role"
  assume_role_policy  = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_motf_up_policy_attachment" {
  role       = aws_iam_role.aws_motf_unified_plugins_role[0].name
  policy_arn = aws_iam_policy.aws_motf_unified_plugins_policy[0].arn
}
