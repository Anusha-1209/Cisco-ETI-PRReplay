locals {
  region           = "us-east-1"
  aws_account_name = "lightspin-prod"
  name             = "recon"
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-lightspin-prod/vpc/us-east-1/recon-prod-use2-data-vpc.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# AWS credentails are the same of cwpp-dev vault secret (we deploy on same aws account)
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.region
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "${local.name}-prod-use1-data-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

module "vpc" {
  source                          = "git::https://github.com/cisco-eti/sre-tf-module-aws-vpc?ref=2.0.6"
  region                          = local.region
  vpc_cidr                        = "10.0.0.0/16"
  vpc_name                        = "${local.name}-prod-use1-data"
  cluster_name                    = "${local.name}-prod-use1-data"
  create_database_subnet_group    = true
  create_elasticache_subnet_group = false
  create_secondary_subnets        = false
}
