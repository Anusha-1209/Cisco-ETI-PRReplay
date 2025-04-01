terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/test-peering.tfstate"
    region = "us-east-2"
  }
}

module "primary_cluster_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=single-region"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "outshift-common-dev"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "outshift-common-dev"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "common-dev-use2-vpc-data"
  requester_vpc_name = "common-dev-usw2-vpc-data"
}
