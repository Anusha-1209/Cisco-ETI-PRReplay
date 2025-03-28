terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/eks-common-dev-1-data.tfstate"
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
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
  provider = vault.eticloud
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "eks-common-dev-1-data-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "PreProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

module "vpc" {
  source                          = "git::https://github.com/cisco-eti/sre-tf-module-aws-vpc?ref=2.0.6"
  region                          = "us-east-2"
  vpc_cidr                        = "10.22.0.0/16"
  vpc_name                        = "eks-common-dev-1-data"
  cluster_name                    = "eks-common-dev-1-data"
  create_database_subnet_group    = true
  create_elasticache_subnet_group = false
  create_secondary_subnets        = false
}
