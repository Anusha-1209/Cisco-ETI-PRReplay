# This file was created by Outshift Platform Self-Service automation.

terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod.
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-nonprod"
    # Note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key = "terraform-state/outshift-common-dev/us-east-2/vpc/outshift-sandbox-vms.tfstate"
    # Do not change without talking to the SRE team. This is the region where the terraform backend bucket is located.
    region = "us-east-2"
  }
}

locals {
  name             = "outshift-sandbox-vms"
  region           = "us-east-2"
  aws_account_name = "outshift-common-dev"
}

module "vpc" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-vpc-allinone.git?ref=latest"
  name             = local.name             # VPC name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.175.0.0/16"      # VPC CIDR

  # Tags
  application_name    = "outshift_infrastructure"
  component           = "jarvis"
  cisco_mail_alias    = "openg-admins@cisco.com"
  data_classification = "Cisco Confidential"
  data_taxonomy       = "Cisco Operations Data"
  environment         = "NonProd"
  resource_owner      = "openg"
}