terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/cross-region-vpc-peering/data-comn-dev-clusters.tfstate"
    region = "us-east-2"
  }
}

module "primary_cluster_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=latest"
  aws_account_name   = "outshift-common-dev"
  accepter_vpc_name  = "comn-staging-use2-1"
  requester_vpc_name = "common-dev-usw2-vpc-data"
  accepter_region    = "us-east-2"
  requester_region   = "us-west-2"
}

module "secondary_cluster_to_primary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=latest"
  aws_account_name   = "outshift-common-dev"
  accepter_vpc_name  = "comn-staging-usw2-1"
  requester_vpc_name = "common-dev-use2-vpc-data"
  accepter_region    = "us-west-2"
  requester_region   = "us-east-2"
}