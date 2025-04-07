# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/ci/aws"
}

# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                 # We separate the different environments into different buckets. The buckets are eticloud-tf-state-nonprod, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/vpc/us-east-1/etici-us-east-1-vpc.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                 # Do not change without talking to the SRE team.
  }
}

# Change this default to move the VPC into a a different region.
variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-1"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}
# Here we call the SRE team's VPC module.
module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.2.0" # The reference specifies the version of the 
  name                            = "etici-vpc-us-east-1"                                                     # The name of the VPC should be descriptive and must be unique.
  cidr                            = "10.43.0.0/16"                                                            # You should use a /16 RFC1918 CIDR. 
  region                          = var.AWS_INFRA_REGION                                                      # Do not change.
  hosted_zone_id                  = "Z10133912XLO390G5MKPV"                                                   #This must be changed and requires a manual lookup in Route53.
  cluster_name                    = "eks-etici-1"                                                             # The parameter sets tags on subnets for EKS to consume. Please contact the SRE team if you have need more than one EKS cluster in your VPC.
  create_database_subnet_group    = true                                                                      # Optional. If you do not currently need RDS, set to false. If `true`, database_subnets below MUST be populated.
  create_elasticache_subnet_group = true                                                                      # Optional. If you do not currently need Elasticache, set to false. If `true`, elasticache_subnets below MUST be populated.
  # All the subnets should by /24 CIDR's.
  # The list of subnets determines the number of subnets created. If you need more subnets of any type, add another CIDR to that list.
  public_subnets = [
    "10.43.11.0/24",
    "10.43.12.0/24",
    "10.43.13.0/24",
  ]
  private_subnets = [
    "10.43.1.0/24",
    "10.43.2.0/24",
    "10.43.3.0/24",
  ]
  # Only required if create_database_subnet_groups = true above
  database_subnets = [
    "10.43.21.0/24",
    "10.43.22.0/24",
    "10.43.23.0/24"
  ]
  # Only required if create_elasticache_subnet_groups = true above
  elasticache_subnets = [
    "10.43.31.0/24",
    "10.43.32.0/24",
    "10.43.33.0/24"
  ]
  CSBApplicationName    = "us-east-1-etici-vpc"
  CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
  CSBDataClassification = "Cisco Confidential"
  CSBDataTaxonomy       = "Cisco Operations Data"
  CSBEnvironment        = "NonProd"
  CSBResourceOwner      = "ETI SRE"
}
