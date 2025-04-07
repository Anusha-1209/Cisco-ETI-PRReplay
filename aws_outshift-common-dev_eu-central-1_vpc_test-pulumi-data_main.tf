# This file was created by Outshift Platform Self-Service automation.

terraform {
  backend "s3" {
    # We separate the different levels of development into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod.
    # The environment should match the CSBEnvironment below.
    bucket = "eticloud-tf-state-nonprod"
    # Note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    key = "terraform-state/outshift-common-dev/eu-central-1/vpc/test-pulumi-data.tfstate"
    # Do not change without talking to the SRE team. This is the region where the terraform backend bucket is located.
    region = "us-east-2"
  }
}

locals {
  name             = "test-pulumi-data"
  region           = "eu-central-1"
  aws_account_name = "outshift-common-dev"
}

module "vpc" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-vpc-allinone.git?ref=latest"
  name             = local.name             # VPC name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.4.0.0/16"      # VPC CIDR

  # Tags
  application_name    = "test-pulumi-data"
  component           = "test-pulumi-data"
  cisco_mail_alias    = "eti-sre-admins@cisco.com"
  data_classification = "Cisco Restricted"
  data_taxonomy       = "Cisco Operations Data"
  environment         = "NonProd"
  resource_owner      = "eti-sre-admins"
}

module "vpc_peering_compute_to_data" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-vpc-peering.git?ref=2.0.0"
  aws_accounts_to_regions = {
    "common" = {
      account_name = "outshift-common-dev"
      region       = "eu-central-1"
    }
  }
  accepter_vpc_name  = "outshift-platform-pulumi-test-vpc" # EKS VPC
  requester_vpc_name = "test-pulumi-data"
}
