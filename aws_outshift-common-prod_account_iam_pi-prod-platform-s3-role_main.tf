provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

resource "aws_iam_policy" "aws_pi_dev_platform_s3_policy" {
  name        = "pi-prod-platform-s3-policy"
  description = "AWS motific unified plugins Role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor1",
        Effect = "Allow",
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::961088030672:role/pi-prod-platform-s3-role"
        ]
      },
      {
        Sid    = "FullS3Access",
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = [
          "arn:aws:s3:::pi-prod-platform-s3/*",
          "arn:aws:s3:::pi-prod-platform-s3"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "aws_pi_dev_platform_s3_role" {
  name = "pi-prod-platform-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/06C50AA8E04F72BD02243B0A49DCC8D8"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/06C50AA8E04F72BD02243B0A49DCC8D8:aud" = "sts.amazonaws.com"
            "oidc.eks.us-east-2.amazonaws.com/id/06C50AA8E04F72BD02243B0A49DCC8D8:sub" = "system:serviceaccount:platform-s3-sa"
          }
        }
      }
    ]
  })

  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_pi_dev_platform_s3_policy_attachment" {
  role       = aws_iam_role.aws_pi_dev_platform_s3_role.name
  policy_arn = aws_iam_policy.aws_pi_dev_platform_s3_policy.arn
}
