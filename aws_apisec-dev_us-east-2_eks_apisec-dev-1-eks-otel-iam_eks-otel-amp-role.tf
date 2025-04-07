# This provider allows access to the eticloud namespace in Keeper. 
# Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# Change `path = "secret/infra/<account_name>/aws" to specify the account in which the resources will be created. 
# Must match the account in which the Amazon Managed Prometheus instance workspace was created.
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/eticloud/terraform_admin"
  provider = vault.eticloud
}

# eticloud, where the IAM roles and policies for Amazon Managed Prometheus and OTEL will be created
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]

  alias       = "destination"
  region      = "us-east-2"  # to be updated accordingly
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "amp-access-management"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

# other AWS account, where the EKS cluster live
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential_sub_aws_account.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential_sub_aws_account.data["AWS_SECRET_ACCESS_KEY"]

  alias  = "source"
  region = "us-east-2"  # to be updated accordingly
}

# Change `path = "secret/infra/<account_name>/aws" to specify the account in which the resources will be created. 
data "vault_generic_secret" "aws_infra_credential_sub_aws_account" {
  path     = "secret/infra/aws/apisec-dev/terraform_admin"
  provider = vault.eticloud
}

# Required to get the thumbprint of each EKS cluster OIDC provider
provider "external" {}


terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" # We separate the different environments into different buckets. 
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. 
    # <bucket_name> in eticloud-tf-state-<bucket_name> should match the Environment tag below.
    key    = "terraform-state/aws-apisec-dev/iam/eks-otel-amp-role.tfstate" # The path should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                       # Do not change.
    # profile = "eticloud" # If you are doing developing Terraform, you can specify a local AWS profile to use for accessing the statefile ONLY. 
    # A CLI login to Keeper is also required.
  }
}

locals {
  cluster_name_for_iam = upper(replace(var.cluster_name, "-", ""))
  oidc_issuer          = trimprefix(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://")
  oidc_issuer_url      = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

variable "aws_account" {
  description = "AWS account ID"
  type        = string
  default     = "626007623524"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type    = string
  default = "apisec-dev-1" # The name of the associated EKS cluster. Must be updated.
}

variable "cluster_region" {
  description = "EKS cluster region"
  type    = string
  default = "us-east-2" # The name of the associated EKS cluster. Must be updated.
}



# EKS cluster where the OTEL collector will be deployed
data "aws_eks_cluster" "eks_cluster" {
  provider = aws.source
  name     = var.cluster_name
}

# IAM policy that grants read/write permissions to AMP
resource "aws_iam_policy" "amp_ingest_policy" {
  provider    = aws.destination
  name        = "${var.cluster_name}-AMPIngestPolicy"
  description = "Ingest policy for AMP"

  policy = jsonencode({
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
  provider = aws.destination
  name     = "${var.cluster_name}-AMPIngestRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = local.cluster_name_for_iam
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account}:oidc-provider/${local.oidc_issuer}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer}:aud" : "sts.amazonaws.com",
            "${local.oidc_issuer}:sub" : "system:serviceaccount:opentelemetry-collector:${var.cluster_name}-opentelemetry-collector"
          }
        }
      },
    ]
  })
}

data "aws_iam_openid_connect_provider" "eks_cluster" {
  provider = aws.source
  url = local.oidc_issuer_url
}

resource "aws_iam_role_policy_attachment" "amp_ingest_policy" {
  provider   = aws.destination
  role       = aws_iam_role.amp_iamproxy_ingest.name
  policy_arn = aws_iam_policy.amp_ingest_policy.arn
}


resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  provider = aws.destination
  url      = local.oidc_issuer_url
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = data.aws_iam_openid_connect_provider.eks_cluster.thumbprint_list
}
