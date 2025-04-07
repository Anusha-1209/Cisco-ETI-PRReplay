# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
data "vault_generic_secret" "aws_infra_credential" {
  path="secret/eticcprod/infra/prod/aws"
}

# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-prod" # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key           = "terraform-state/aurora-postgres/eu-west-1/rds-dev-2-rds.tfstate"  #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region        = "us-east-2" #do not change
  }
}

# Change this default to move the VPC into a a different region.
variable "AWS_INFRA_REGION" {
  description     = "AWS Region"
  default         = "eu-west-1"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region          = var.AWS_INFRA_REGION
  max_retries     = 3
}

module "rds" {
    source = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-aurora-postgres?ref=1.0.3" # The reference specifies the version of the module.
    vpc_name = "nonprod-db-vpc-2"           # the name of the VPC where the database instances and clusters will be created.
    cluster_name = "rds-dev-2"              # the name of the database instance
    database_name = "dev02"
    # pg_engine_version = "13.4"        # Options are 13.4, 12.8, 11.13. This module is specifically Aurora PostgreSQL.
    db_instance_type = "db.r5.xlarge" # Instance types list available here: https://aws.amazon.com/rds/instance-types/
    CSBApplicationName    = "rds-dev-2-db"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy  = "Cisco Operations Data"
    CSBEnvironment   = "NonProd"
    CSBResourceOwner = "eti"
}


