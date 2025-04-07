# This provider allows access to the eticloud/eticcprod namespace in Keeper. 
# Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created. 
# Must match the account in which the Amazon Managed Prometheus instance workspace was created.
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticcprod
}

# eticloud, where the IAM roles and policies for Amazon Managed Prometheus and OTEL will be created
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2" # to be updated accordingly
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "eks-prod-4-eks-amp-access-management"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                      # We separate the different environments into different buckets. 
    key    = "terraform-state/aws-eks-prod-4/eks/eks-prod-4-otel-iam.tfstate" # The path should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                      # Do not change.
  }
}

locals {
  cluster_name_for_iam = upper(replace(var.cluster_name, "-", ""))
  oidc_params          = regex("(?:\\/\\/)(?P<id>[^.]+).[^.]*.(?P<region>[^.]+)", var.cluster_address)
  oidc_template        = "https://oidc.eks.{region}.amazonaws.com/id/{id}"
  oidc_issuer_url = format(
    replace(local.oidc_template, "/{(${join("|", keys(local.oidc_params))})}/", "%s"),
    [
      for value in flatten(regexall("{(${join("|", keys(local.oidc_params))})}", local.oidc_template)) :
      lookup(local.oidc_params, value)
    ]...
  )
  oidc_issuer_trimmed = trimprefix(local.oidc_issuer_url, "https://")
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-prod-4" # The name of the associated EKS cluster. Must be updated.
}

variable "cluster_address" {
  description = "EKS cluster API server endpoint"
  type        = string
  default     = "https://1BF9D563311EC9FA4DC03950CBC19E41.gr7.us-west-2.eks.amazonaws.com"
}

# IAM policy that grants read/write permissions to AMP
resource "aws_iam_policy" "amp_ingest_policy" {
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
  name = "${var.cluster_name}-AMPIngestRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = local.cluster_name_for_iam
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::626007623524:oidc-provider/${local.oidc_issuer_trimmed}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_trimmed}:aud" : "sts.amazonaws.com",
            "${local.oidc_issuer_trimmed}:sub" : "system:serviceaccount:opentelemetry-collector:${var.cluster_name}-opentelemetry-collector"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amp_ingest_policy" {
  role       = aws_iam_role.amp_iamproxy_ingest.name
  policy_arn = aws_iam_policy.amp_ingest_policy.arn
}
