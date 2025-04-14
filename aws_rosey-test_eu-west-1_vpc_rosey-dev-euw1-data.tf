################################################################################
# TF Backend configuration
################################################################################
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/vpc/us-east-2/scs-prod-1-vpc.tfstate"
    region = "us-east-2"
  }
}

locals {
  aws_region         = "eu-west-1"
  vpc_name           = "rosey-dev-data-euw1-1"
  vpc_cidr           = "10.3.0.0/16"
  eks_cluster_name   = "rosey-dev-data-euw1-1"
  app_name           = "rosey-dev" 
  aws_account_name   = "rosey-dev" 
  aws_account_id     = "475589446868"
}

################################################################################
# Provider configuration
################################################################################
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.aws_region
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = local.app_name
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

################################################################################
# VPC
################################################################################
module "vpc" {
  source                          = "https://github.com/cisco-eti/sre-tf-module-aws-vpc.git?ref=2.0.5"
  region                          = local.aws_region
  vpc_name                        = local.vpc_name
  vpc_cidr                        = local.vpc_cidr
  cluster_name                    = local.eks_cluster_name
  create_database_subnet_group    = true
}