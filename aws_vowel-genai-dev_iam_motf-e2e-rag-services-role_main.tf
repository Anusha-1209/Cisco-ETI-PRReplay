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

resource "aws_iam_policy" "aws_motf_e2e_rag_services_policy" {
  name        = "motf-e2e-rag-services-policy"
  description = "AWS rag services role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
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
        Sid    = "VisualEditor1",
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint",
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::961088030672:role/motf-e2e-rag-services-role",
          "arn:aws:sagemaker:*:961088030672:endpoint/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "aws_motf_e2e_rag_services_role" {
  name = "motf-e2e-rag-services-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:sub" : "system:serviceaccount:vowel-system:rag-acquisition-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:sub" : "system:serviceaccount:vowel-system:rag-inference-sa"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:sub" : "system:serviceaccount:vowel-system:rag-ingestion-manager-sa"
          }
        }
      },
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
            StringEquals = {
                "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:aud" = "sts.amazonaws.com"
                "oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D:sub" = "system:serviceaccount:vowel-system:rag-doc-processor-sa"
              }
          }
        Effect    = "Allow"
        Principal = {
            Federated = "arn:aws:iam::961088030672:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/C1CB13EB43CD94EE17721A0719CCF08D"
          }
      }
    ]
  })

  force_detach_policies = false
}


resource "aws_iam_role_policy_attachment" "aws_motf_e2e_rag_services_policy_attachment" {
  role       = aws_iam_role.aws_motf_e2e_rag_services_role.name
  policy_arn = aws_iam_policy.aws_motf_e2e_rag_services_policy.arn
}
