terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/data-comn-staging-use2-1.tfstate"
    region = "us-east-2"
  }
}

module "vpc_peering_primary_to_primary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "common" = {
      account_name = "outshift-common-staging"
      region       = "us-east-2"
    }
  }
  accepter_vpc_name  = "comn-staging-use2-1"
  requester_vpc_name = "common-staging-use2-vpc-data"
}