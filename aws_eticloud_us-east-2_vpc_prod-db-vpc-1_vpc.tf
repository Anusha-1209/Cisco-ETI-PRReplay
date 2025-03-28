provider "vault" {
    alias = "eticcprod"
    address = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path="secret/eticcprod/infra/prod/aws"
}
terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-prod" # Do not change without talking to the SRE team.
    key           = "terraform-state/vpc/us-east-2/prod-db-vpc-1.tfstate" # The statefile name should be descriptive and must be unique.
    region        = "us-east-2" # Do not change without talking to the SRE team.
  }
}

variable "AWS_INFRA_REGION" {
  description     = "AWS Region"
  default         = "us-east-2"
}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region          = var.AWS_INFRA_REGION
  max_retries     = 3
}


module "vpc" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.2.4" # The reference specifies the version of the
  name            = "prod-db-vpc-1" # The name of the VPC should be descriptive and must be unique.
  cidr            = "10.220.0.0/16" # You should use a /16 RFC1918 CIDR.
  region          = var.AWS_INFRA_REGION # Do not change.
  cluster_name    = "nonprod-db-vpc-1" # The parameter sets tags on subnets for EKS to consume. Please contact the SRE team if you have need more than one EKS cluster in your VPC.
  create_database_subnet_group = true # Optional. If you do not currently need RDS, set to false. If `true`, database_subnets below MUST be populated.
  create_elasticache_subnet_group = false # Optional. If you do not currently need Elasticache, set to false. If `true`, elasticache_subnets below MUST be populated.
  hosted_zone_id  = "Z09984062UH4ME1C1V3GD"
  # All the subnets should by /24 CIDR's.
  # The list of subnets determines the number of subnets created. If you need more subnets of any type, add another CIDR to that list.
  public_subnets = [
    "10.220.11.0/24",
    "10.220.12.0/24",
    "10.220.13.0/24",
  ]
  private_subnets =  [
    "10.220.1.0/24",
    "10.220.2.0/24",
    "10.220.3.0/24",
  ]
  # Only required if create_database_subnet_groups = true above
  database_subnets = [
    "10.220.21.0/24",
    "10.220.22.0/24",
    "10.220.23.0/24"
  ]
  # Only required if create_elasticache_subnet_groups = true above
  # elasticache_subnets = [
  #     "10.200.31.0/24",
  #     "10.200.32.0/24",
  #     "10.200.33.0/24"
  # ]
  CSBApplicationName = "prod-db-vpc-1"
  CSBCiscoMailAlias = "eti-sre@cisco.com"
  CSBDataClassification = "Cisco Confidential"
  CSBDataTaxonomy = "Cisco Operations Data"
  CSBEnvironment = "NonProd"
  CSBResourceOwner = "ETI SRE"
}