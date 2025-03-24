
################################################################################
# OTel Provider
################################################################################


data "vault_generic_secret" "otel_destination_endpoint_aws_infra_credential" {
  path                = "secret/eticcprod/infra/prod/aws"
  provider            = vault.eticcprod
}

# eticloud, where the IAM roles and policies for Amazon Managed Prometheus and OTEL will be created
provider "aws" {
  access_key          = data.vault_generic_secret.otel_destination_endpoint_aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key          = data.vault_generic_secret.otel_destination_endpoint_aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]

  alias               = "otel_aws_destination"
  region              = "us-east-2"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the EKS cluster lives.
data "vault_generic_secret" "otel_source_cluster_aws_infra_credential" {
  path                = "secret/eticcprod/infra/${var.aws_account_name}/aws"
  provider            = vault.eticcprod
}

# other AWS account, where the EKS cluster live
provider "aws" {
  access_key          = data.vault_generic_secret.otel_source_cluster_aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key          = data.vault_generic_secret.otel_source_cluster_aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]

  alias               = "otel_aws_source"
  region              = "eu-central-1"  # to be updated accordingly
}

# EKS cluster OpenID connect
data "aws_iam_openid_connect_provider" "eks_cluster" {
  provider            = aws.otel_aws_source
  url                 = local.oidc_issuer_url
}

# IAM policy that grants read/write permissions to AMP
resource "aws_iam_policy" "amp_ingest_policy" {
  count               = var.create_otel_irsa ? 1 : 0
  provider            = aws.otel_aws_destination
  name                = "${local.name}-AMPIngestPolicy"
  description         = "Ingest policy for AMP"

  policy              = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Action" = [
          "aps:RemoteWrite",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ],
        "Resource" = "*"
      }
    ]
  })
}

# IAM role for each cluster we want to export metrics from
resource "aws_iam_role" "amp_iamproxy_ingest" {
  count               = var.create_otel_irsa ? 1 : 0
  provider            = aws.otel_aws_destination
  name                = "${local.name}-AMPIngestRole"
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = local.cluster_name_for_iam
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.otel_destination_endpoint_aws_account}:oidc-provider/${local.oidc_issuer}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer}:aud" : "sts.amazonaws.com",
            "${local.oidc_issuer}:sub" : "system:serviceaccount:opentelemetry-collector:${local.name}-opentelemetry-collector"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amp_ingest_policy" {
  count               = var.create_otel_irsa ? 1 : 0
  provider            = aws.otel_aws_destination
  role                = aws_iam_role.amp_iamproxy_ingest[0].name
  policy_arn          = aws_iam_policy.amp_ingest_policy[0].arn
}

resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  count               = var.create_otel_irsa ? 1 : 0
  provider            = aws.otel_aws_destination
  url                 = local.oidc_issuer_url
  client_id_list      = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = data.aws_iam_openid_connect_provider.eks_cluster.thumbprint_list
}