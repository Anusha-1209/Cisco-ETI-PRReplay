terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"                                                
    key     = "terraform-state/aws/cnapp-policy-dev/eu-west-1/rds/cnapp-policy-dev-euw1-1.tfstate"     
    region  = "us-east-2"                                                                  
  }
}

locals {
  name             = "policy-dev-euw1-1"
  region           = "eu-west-1"
  aws_account_name = "cnapp-policy-dev"
  vpc_data         = "policy-data-dev-euw1-1"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider    = vault.eticloud
  path        = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.name]
  }
}

module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  
  vpc_name          = local.vpc_data
  database_name     = "cnapp-policy"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = "policy-rds-dev-euw1"
  secret_path       = "secret/eticloud/infra/cnapp-policy-dev/policy-rds-dev-euw1"
  db_engine_version = "15"
  db_allowed_cidrs  = [
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
