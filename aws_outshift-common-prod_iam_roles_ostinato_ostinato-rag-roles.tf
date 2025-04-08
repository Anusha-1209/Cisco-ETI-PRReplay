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

resource "aws_iam_policy" "aws_ostinato_prod_rag_services_policy" {
  name        = "ostinato-prod-rag-services-policy"
  description = "AWS rag services role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "OstinatoProdPolicy0",
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
        Sid    = "OstinatoProdPolicy1",
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint",
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::058264538874:role/ostinato-prod-rag-services-role",
          "arn:aws:sagemaker:*:058264538874:endpoint/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "aws_ostinato_prod_rag_services_role" {
  name = "ostinato-prod-rag-services-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::058264538874:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:sub" : "system:serviceaccount:ostinato-system:rag-acquisition-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::058264538874:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:sub" : "system:serviceaccount:ostinato-system:rag-inference-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::058264538874:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:sub" : "system:serviceaccount:ostinato-system:rag-ingestion-manager-sa"
          }
        }
      },
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
            StringEquals = {
                "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:aud" = "sts.amazonaws.com"
                "oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5:sub" = "system:serviceaccount:ostinato-system:rag-doc-processor-sa"
              }
          }
        Effect    = "Allow"
        Principal = {
            Federated = "arn:aws:iam::058264538874:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/39E6F8D301761D65BAFA5DADA4DEB5A5"
          }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "aws_ostinato_rag_services_policy_attachment" {
  role       = aws_iam_role.aws_ostinato_prod_rag_services_role.name
  policy_arn = aws_iam_policy.aws_ostinato_prod_rag_services_policy.arn
}
