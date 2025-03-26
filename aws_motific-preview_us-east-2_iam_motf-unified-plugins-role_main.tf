provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/motific-preview/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

resource "aws_iam_policy" "aws_motf_unified_plugins_policy" {
  name        = "motf-preview-unified-plugins-policy"
  description = "AWS motific unified plugins Role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "sagemaker:ListEndpointConfigs",
          "sagemaker:ListEndpoints"
        ],
        Resource = "*"
      },
      {
        Sid    = "VisualEditor1",
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint",
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::961088030672:role/motf-preview-unified-plugins-role",
          "arn:aws:sagemaker:*:961088030672:endpoint/*"
        ]
      },
      {
        Sid    = "AdditionalPermissions",
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      },
      {
        Sid    = "KMSPermissions",
        Effect = "Allow",
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "FullS3Access",
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "aws_motf_unified_plugins_role" {
  name = "motf-preview-unified-plugins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::851725238184:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/50C45BFA06C99983803E5393083A11C3"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/50C45BFA06C99983803E5393083A11C3:aud" = "sts.amazonaws.com"
            "oidc.eks.us-east-2.amazonaws.com/id/50C45BFA06C99983803E5393083A11C3:sub" = "system:serviceaccount:vowel-system:default"
          }
        }
      }
    ]
  })

  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_motf_up_policy_attachment" {
  role       = aws_iam_role.aws_motf_unified_plugins_role.name
  policy_arn = aws_iam_policy.aws_motf_unified_plugins_policy.arn
}
