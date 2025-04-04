provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/vowel-genai-dev/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

resource "aws_iam_policy" "aws_mm_testset_s3_policy" {
  name        = "mm-testset-s3-policy"
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
          "arn:aws:iam::961088030672:role/mm-testset-s3-role"
        ]
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

resource "aws_iam_role" "aws_mm_testset_s3_role" {
  name = "mm-testset-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
            StringEquals = {
                "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:aud" = "sts.amazonaws.com"
              }
          }
        Effect    = "Allow"
        Principal = {
            Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6"
          }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "aws_mm_testset_s3_policy_attachment" {
  role       = aws_iam_role.aws_mm_testset_s3_role.name
  policy_arn = aws_iam_policy.aws_mm_testset_s3_policy.arn
}
