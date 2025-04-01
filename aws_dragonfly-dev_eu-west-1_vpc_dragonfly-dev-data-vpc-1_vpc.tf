terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-dev-1/vpc/eu-west-1/dragonfly-data-vpc.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-west-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "dragonfly-data-vpc"
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

module "vpc" {
  source                          = "git::https://github.cisco.com/cisco-eti/sre-tf-module-aws-vpc?ref=2.0.4"
  region                          = "eu-west-1"
  vpc_cidr                        = "10.11.0.0/16"
  vpc_name                        = "dragonfly-data"
  cluster_name                    = "dragonfly-msk-eks"
  create_database_subnet_group    = true
  create_elasticache_subnet_group = false
}
