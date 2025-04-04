terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/vpc/us-west-2/platform-prod-usw2-vpc-data.tfstate"
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
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
  provider = vault.eticloud
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-west-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "platform-prod-usw2-vpc-data-vpc"
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
  region                          = "us-east-2"
  vpc_cidr                        = "10.224.0.0/16"
  vpc_name                        = "platform-prod-usw2-vpc-data"
  cluster_name                    = "platform-prod-usw2-vpc-data"
  create_database_subnet_group    = true
  create_elasticache_subnet_group = false
  create_secondary_subnets        = false
}
