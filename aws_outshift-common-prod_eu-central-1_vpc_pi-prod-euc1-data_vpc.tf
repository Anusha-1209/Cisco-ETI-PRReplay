################################################################################
# TF Backend configuration
################################################################################
terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-prod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/outshift-common-prod/us-east-2/vpc/pi-prod-euc1-data.tfstate"  # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2" # DO NOT CHANGE.
  }
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
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-central-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "pi-prod-euc1-data-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

################################################################################
# VPC
################################################################################
module "vpc" {
  source                          = "git::https://github.com/cisco-eti/sre-tf-module-aws-vpc?ref=2.0.6"
  region                          = "eu-central-1"
  vpc_name                        = "pi-prod-euc1-data"
  vpc_cidr                        = "10.4.0.0/16"
  cluster_name                    = "pi-prod-euc1-data"
  create_database_subnet_group    = true
  create_elasticache_subnet_group = true
  create_secondary_subnets        = false
}
