terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-apisec-prod/vpc/us-east-2/apisec-prod-1-vpc.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "apisec-prod-1-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
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
  path     = "secret/infra/aws/apisec-prod/terraform_admin"
  provider = vault.eticloud
}

module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=2.0.4"
  region                          = "us-east-2"
  vpc_cidr                        = "10.1.0.0/16"
  private_subnets                 = ["10.1.16.0/20","10.1.32.0/20","10.1.64.0/20"]
  create_secondary_subnets        = false
  vpc_name                        = "apisec-prod-1"
  cluster_name                    = "apisec-prod-1"
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  # secondary_cidr_block            = ["100.64.0.0/16"] # Default. Do not use anything but the default.
}


