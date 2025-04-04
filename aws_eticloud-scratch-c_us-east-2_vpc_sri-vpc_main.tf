# This file was created by Outshift Platform Self-Service automation.

terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod.
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-nonprod"
    # Note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key = "terraform-state/eticloud-scratch-c/us-east-2/vpc/sri-vpc.tfstate"
    # Do not change without talking to the SRE team. This is the region where the terraform backend bucket is located.
    region = "us-east-2"
  }
}

locals {
  name             = "sri-vpc"
  region           = "us-east-2"
  aws_account_name = "eticloud-scratch-c"
}

module "vpc" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-vpc-allinone.git?ref=latest"
  name             = local.name             # VPC name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.215.0.0/16"      # VPC CIDR

  # Tags
  cisco_mail_alias    = "sraradhy@cisco.com"
  data_classification = "Cisco Restricted"
  data_taxonomy       = "Cisco Operations Data"
  environment         = "NonProd"
  resource_owner      = "Sri Aradhyula"
}