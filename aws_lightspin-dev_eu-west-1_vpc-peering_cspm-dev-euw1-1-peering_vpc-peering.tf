terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/eu-west-1/cspm-dev-euw1-1-data.tfstate"
    region = "us-east-2"
  }
}

module "vpc_peering_primary_to_primary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=2.0.0"
  aws_accounts_to_regions = {
    "common" = {
      account_name = "lightspin-dev"
      region       = "eu-west-1"
    }
  }
  accepter_vpc_name  = "cspm-dev-euw1-1"
  requester_vpc_name = "lightspin-dev-1-vpc"
}