provider "aws" {
  region = "us-east-2"
}

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
  access_key    = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key    = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  alias         = "destination"
  region        = "us-east-2"  # to be updated accordingly
  max_retries   = 3

  default_tags {
    tags = {
      ApplicationName    = "${var.cluster_name}-argocd-iam-role"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

# O AWS account, where the EKS cluster lives
provider "aws" {
  access_key    = data.vault_generic_secret.aws_infra_credential_sub_aws_account.data["AWS_ACCESS_KEY_ID"]
  secret_key    = data.vault_generic_secret.aws_infra_credential_sub_aws_account.data["AWS_SECRET_ACCESS_KEY"]
  alias         = "source"
  region        = "eu-north-1"  # to be updated accordingly
  default_tags {
    tags = {
      ApplicationName    = "${var.cluster_name}-argocd-iam-role"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the EKS cluster lives. 
data "vault_generic_secret" "aws_infra_credential_sub_aws_account" {
  path      = "secret/eticcprod/infra/ci/aws"
  provider  = vault.eticcprod
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod" # We separate the different environments into different buckets. 
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. 
    # <bucket_name> in eticloud-tf-state-<bucket_name> should match the Environment tag below.
    key    = "terraform-state/aws-eticloud-preprod/eks/us-east-2/eks-gitops-cnapp-1-argocd-iam-role.tfstate" # The path should match the pattern terraform_state/<service>/<region>/<name>.tfstate
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

variable "cluster_name" {
  description = "EKS cluster name"
  type    = string
  default = "eks-gitops-cnapp-1" # The name of the associated EKS cluster. Must be updated.
}

# EKS cluster where the OTEL collector will be deployed
data "aws_eks_cluster" "eks_cluster" {
  provider = aws.source
  name     = var.cluster_name
}

variable "cluster_region" {
  description = "EKS cluster region"
  type    = string
  default = "eu-north-1" # The name of the associated EKS cluster. Must be updated.
}

# EKS cluster OpenID connect
data "aws_iam_openid_connect_provider" "eks_cluster" {
  provider = aws.source
  url = local.oidc_issuer_url
}

# IAM role for each cluster we want to export metrics from

resource "aws_iam_role_policy_attachment" "ecr_access_policy" {
  provider   = aws.destination
  role       = aws_iam_role.argocd-image-updater-role.name
  policy_arn = data.aws_iam_policy.ecr_readonly.arn
}

data "aws_iam_policy" "ecr_readonly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
  provider = aws.destination
}

# role

resource "aws_iam_role" "argocd-image-updater-role" {
  provider = aws.destination
  name     = "${var.cluster_name}-argocd-image-updater-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = local.cluster_name_for_iam
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::626007623524:oidc-provider/${local.oidc_issuer}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer}:aud" : "sts.amazonaws.com",
            "${local.oidc_issuer}:sub" : "system:serviceaccount:argocd-image-updater:argocd-image-updater-sa"
          }
        }
      },
    ]
  })
}
