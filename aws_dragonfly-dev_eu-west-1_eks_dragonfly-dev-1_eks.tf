terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-dev-1/eks/eu-west-1/eks-dragonfly-dev-2-eks.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-west-1"
  default_tags {
    tags = {
      ApplicationName    = "dragonfly-dev-2-eks"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-dev/terraform_admin"
  provider = vault.eticloud
}

data "aws_caller_identity" "current" {}

locals {
  name             = "eks-dragonfly-dev-2"
  region           = "eu-west-1"
  aws_account_name = "dragonfly-dev-1"
}

module "eks" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.10.0.0/16"         # VPC CIDR
  cluster_version  = "1.27"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m5a.2xlarge"] # EKS instance types
  min_size       = 5               # EKS node group min size
  max_size       = 10              # EKS node group max size
  desired_size   = 5               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA
}
