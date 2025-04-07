terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-eti-ci/vpc/us-east-2/dragonfly-dev-1-vpc.tfstate"
    region = "us-east-2"
  }
}

provider "aws" { 
    access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
    secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
    region      = var.AWS_INFRA_REGION
    max_retries = 3
    default_tags {
      tags = {
        ApplicationName    = var.ApplicationName
        CiscoMailAlias     = var.CiscoMailAlias
        DataClassification = var.DataClassification
        DataTaxonomy       = var.DataTaxonomy
        EnvironmentName    = var.EnvironmentName
        ResourceOwner      = var.ResourceOwner
      }
    }
}

provider "vault" {
    alias     = "eticloud_eticcprod"
    address   = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

# AWS credentails are the same of lightspin-dev vault secret (we deploy on same aws account)
data "vault_generic_secret" "aws_infra_credential" {
    path     = "secret/eticcprod/infra/ci/aws"
    provider = vault.eticloud_eticcprod
}

module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=2.0.1" 
  region                          = var.AWS_INFRA_REGION
  vpc_name                        = var.vpc_name
  vpc_cidr                        = var.vpc_cidr
  cluster_name                    = var.cluster_name
  create_database_subnet_group    = var.create_database_subnet_group
  create_elasticache_subnet_group = var.create_elasticache_subnet_group
  create_secondary_subnets        = var.create_secondary_subnets
}
