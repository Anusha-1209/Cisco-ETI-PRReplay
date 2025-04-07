provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

resource "aws_iam_policy" "aws_ostinato_dev_rag_services_policy" {
  name        = "ostinato-dev-rag-services-policy"
  description = "AWS rag services role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "OstinatoDevPolicy0",
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "s3:*",
          "kms:*",
          "sagemaker:ListEndpoints"
        ],
        Resource = "*"
      },
      {
        Sid    = "OstinatoDevPolicy1",
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint",
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::471112537430:role/ostinato-dev-rag-services-role",
          "arn:aws:sagemaker:*:471112537430:endpoint/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "aws_ostinato_dev_rag_services_role" {
  name = "ostinato-dev-rag-services-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::471112537430:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:sub" : "system:serviceaccount:ostinato-system:rag-acquisition-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::471112537430:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:sub" : "system:serviceaccount:ostinato-system:rag-inference-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::471112537430:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:sub" : "system:serviceaccount:ostinato-system:rag-ingestion-manager-sa"
          }
        }
      },
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
            StringEquals = {
                "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:aud" = "sts.amazonaws.com"
                "oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27:sub" = "system:serviceaccount:ostinato-system:rag-doc-processor-sa"
              }
          }
        Effect    = "Allow"
        Principal = {
            Federated = "arn:aws:iam::471112537430:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A9EDA6D83ABE1896B92C50B3BACC7C27"
          }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "aws_ostinato_rag_services_policy_attachment" {
  role       = aws_iam_role.aws_ostinato_dev_rag_services_role.name
  policy_arn = aws_iam_policy.aws_ostinato_dev_rag_services_policy.arn
}
