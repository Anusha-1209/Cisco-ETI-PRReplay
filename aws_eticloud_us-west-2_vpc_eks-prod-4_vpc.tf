provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/prod/aws"
}

# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"                                   # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/vpc/us-east-2/eks-prod-4-vpc.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                   # Do not change without talking to the SRE team.
  }
}

# Change this default to move the VPC into a a different region.
variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-west-2"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "eks-prod-4-vpc"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}
# Here we call the SRE team's VPC module.
module "vpc" {
  source                          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-vpc?ref=1.4.1" # The reference specifies the version of the 
  vpc_cidr                        = "10.43.0.0/16"                                                            # You should use a /16 RFC1918 CIDR. Subnets will be automatically calculated if not specificed.
  region                          = var.AWS_INFRA_REGION
  vpc_name                        = "eks-prod-4"                                                       # 
  cluster_name                    = "eks-prod-4"                                                       # The parameter sets tags on subnets for EKS to consume. Please contact the SRE team if you have need more than one EKS cluster in your VPC.
  create_database_subnet_group    = true                                                                      # Optional. If you do not currently need RDS, set to false. If `true`, database_subnets below MUST be populated.
  create_elasticache_subnet_group = true                                                                      # Optional. If you do not currently need Elasticache, set to false. If `true`, elasticache_subnets below MUST be populated.
}