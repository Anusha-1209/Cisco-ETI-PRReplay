terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/vpc/eu-west-1/eks-gbear-prod-1-vpc.tfstate"
    region = "us-east-2"
  }
}
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-west-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "eks-gbear-prod-1-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
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
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticloud_eticcprod
}
module "vpc" {
  
  # The reference specifies the source location and tag version of the VPC module.
  source = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.4.1" 
  # AWS Region for Infrastructure Creation
  region = "eu-west-1"
  # VPC for EKS Cluster
  vpc_cidr = "10.4.0.0/16"
  vpc_name = "eks-gbear-prod-1"
  # Name of EKS Cluster
  cluster_name = "eks-gbear-prod-1"
  # Set to True if the cluster will require RDS Resources.
  create_database_subnet_group = true
  # Set to True if the cluster will require Elasticache Resources
  create_elasticache_subnet_group = true
}
