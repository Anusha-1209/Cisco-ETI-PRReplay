################################################################################
# TF Backend configuration
################################################################################
terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-prod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/outshift-common-prod/us-east-2/vpc/marvin-prod-use2-data.tfstate"  # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.
  }
}

locals {
  aws_region         = "us-east-2"
  vpc_name           = "marvin-prod-use2-data"
  vpc_cidr           = "10.3.0.0/16"
  eks_cluster_name   = "marvin-prod-use2-1"
  app_name           = "marvin-prod-use2-data" 
  aws_account_name   = "outshift-common-prod" 
  aws_account_id     = "058264538874"
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
  provider = vault.eticloud
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
      EnvironmentName    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

################################################################################
# VPC
################################################################################
module "vpc" {
  source                          = "git::https://github.com/cisco-eti/sre-tf-module-aws-vpc?ref=2.0.6"
  region                          = "us-east-2"
  vpc_name                        = "marvin-prod-use2-data"
  vpc_cidr                        = "10.3.0.0/16" 
  cluster_name                    = "marvin-prod-use2-data"
  create_database_subnet_group    = true
  create_elasticache_subnet_group = false
  create_secondary_subnets        = false               
}
