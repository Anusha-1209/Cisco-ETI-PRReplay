terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-west-2/data-comn-dev-usw2-1.tfstate"
    region = "us-east-2"
  }
}

module "vpc_peering_secondary_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "common" = {
      account_name = "outshift-common-dev"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "comn-dev-usw2-1"
  requester_vpc_name = "common-dev-usw2-vpc-data"
}