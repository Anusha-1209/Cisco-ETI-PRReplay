terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/motific-dev-use2-vms.tfstate"
    region = "us-east-2"
  }
}

locals {
  name              = "motific-dev-use2-vms"
  region            = "us-east-2"
  aws_account_name  = "vowel-genai-dev"
}

module "vpc" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-vpc-allinone.git?ref=latest"
  name              = local.name              # VPC name
  region            = local.region            # AWS provider region
  aws_account_name  = local.aws_account_name  # AWS account name
  cidr              = "10.2.0.0/16"           # VPC CIDR
}