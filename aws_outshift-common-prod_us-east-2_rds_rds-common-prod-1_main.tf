terraform {
  required_version = ">= 1.5.5"
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"                                                
    key     = "terraform-state/aws/outshift-common-prod/us-east-2/rds/rds-common-prod-1.tfstate"     
    region  = "us-east-2"                                                                  
  }
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.primary, aws.secondary]
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

locals {
  aws_account_name  = "outshift-common-prod"
  data_vpc          = "common-prod-use2-vpc-data"
  primary_eks_vpc   = "comn-prod-use2-1"
  secondary_eks_vpc = "comn-prod-usw2-1"
  rds_name          = "rds-common-prod-1"
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
  alias      = "primary"
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

provider "aws" {
  alias      = "secondary"
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-west-2"
}

data "aws_vpc" "primary_eks_vpc" {
  provider = aws.primary
  filter {
    name   = "tag:Name"
    values = [local.primary_eks_vpc]
  }
}

data "aws_vpc" "secondary_eks_vpc" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = [local.secondary_eks_vpc]
  }
}

module "rds" {
  providers = {
    "aws" = aws.primary
  }
  source            = "git::https://github.com/cisco-eti/sre-tf-module-aws-aurora-postgres?ref=1.1.0"
  vpc_name          = local.data_vpc
  database_name     = "postgressql"
  db_instance_type  = "db.r5.xlarge"
  cluster_name      = local.rds_name
  secret_path       = "secret/eticcprod/infra/aurora-pg/us-east-2/outshift-common-prod/rds-common-prod-1"
  db_engine_version = "15"
  db_allowed_cidrs  = [
    data.aws_vpc.primary_eks_vpc.cidr_block, data.aws_vpc.secondary_eks_vpc.cidr_block,
  ]
}
