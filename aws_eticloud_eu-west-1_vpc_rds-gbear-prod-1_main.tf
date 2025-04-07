terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"                                   
    key    = "terraform-state/vpc/us-east-2/rds-gbear-prod-1-vpc.tfstate" 
    region = "us-east-2"                                                  
  }
}

provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/prod/aws"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-west-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "rds-gbear-prod-1-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.4.1" # The reference specifies the version of the 
  vpc_cidr                        = "10.200.0.0/16"                                                            # You should use a /16 RFC1918 CIDR. Subnets will be automatically calculated if not specificed.
  region                          = "eu-west-1"
  vpc_name                        = "rds-gbear-prod-1"                                                       # 
  cluster_name                    = "eks-gbear-prod-1"                                                       # The parameter sets tags on subnets for EKS to consume. Please contact the SRE team if you have need more than one EKS cluster in your VPC.
  create_database_subnet_group    = true                                                                      # Optional. If you do not currently need RDS, set to false. If `true`, database_subnets below MUST be populated.
  create_elasticache_subnet_group = false                                                                      # Optional. If you do not currently need Elasticache, set to false. If `true`, elasticache_subnets below MUST be populated.
}
