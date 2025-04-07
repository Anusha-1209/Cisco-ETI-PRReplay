terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/vowel-dev-1-vpc.tfstate"
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
      ApplicationName    = "vowel-dev-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/vowel-genai-dev/aws"
  provider = vault.eticloud_eticcprod
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2"
}

module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=simple_vpc_without_secondary_cidr"
  region                          = var.AWS_INFRA_REGION
  vpc_cidr                        = "10.1.0.0/16"
  vpc_name                        = "vowel-dev-1"
  cluster_name                    = "vowel-dev-1"
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_secondary_subnets        = false
}
