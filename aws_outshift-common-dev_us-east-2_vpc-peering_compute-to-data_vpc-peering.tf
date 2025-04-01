terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/data-comn-dev-use2-1.tfstate"
    region = "us-east-2"
  }
}

module "vpc_peering_secondary_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=latest"
  aws_account_name   = "outshift-common-dev"
  accepter_vpc_name  = "comn-dev-use2-1"
  requester_vpc_name = "common-dev-use2-vpc-data"
  accepter_region    = "us-east-2"
  requester_region   = "us-east-2"
}
