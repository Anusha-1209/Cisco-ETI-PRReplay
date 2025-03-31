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

resource "aws_iam_policy" "aws_vowel_dev_rag_services_policy" {
  name        = "vowel-dev-rag-services-policy"
  description = "AWS rag services role IAM Policy"
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
          "arn:aws:iam::961088030672:role/vowel-dev-rag-services-role",
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

resource "aws_iam_role" "aws_vowel_dev_rag_services_role" {
  name = "vowel-dev-rag-services-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:sub" : "system:serviceaccount:vowel-system:rag-acquisition-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:sub" : "system:serviceaccount:vowel-system:rag-inference-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/849169A185E9E37DE274BF7BC92232A6:sub" : "system:serviceaccount:vowel-system:rag-ingestion-manager-sa"
          }
        }
      }
    ]
  })

  force_detach_policies = true
}


resource "aws_iam_role_policy_attachment" "aws_vowel_rag_services_policy_attachment" {
  role       = aws_iam_role.aws_vowel_dev_rag_services_role.name
  policy_arn = aws_iam_policy.aws_vowel_dev_rag_services_policy.arn
}
