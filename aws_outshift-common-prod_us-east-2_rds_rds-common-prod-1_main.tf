terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"                                                
    key     = "terraform-state/aws/outshift-common-prod/us-east-2/rds/rds-common-prod-1.tfstate"     
    region  = "us-east-2"                                                                  
  }
}

locals {
  region           = "us-east-2"
  aws_account_name = "outshift-common-prod"
  data_vpc         = "eks-common-prod-1-data"
  eks_vpc          = "eks-common-prod-1"
  rds_name         = "rds-common-prod-1"
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
    values = [local.eks_vpc]
  }
}

module "rds" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = local.data_vpc
  database_name     = "postgressql"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/outshift-common-prod/rds-common-prod-1"
  db_engine_version = "15"
  db_allowed_cidrs  = [
    data.aws_vpc.eks_vpc.cidr_block,
  ]
}
