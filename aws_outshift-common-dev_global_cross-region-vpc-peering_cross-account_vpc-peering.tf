terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/cross-account-vpc-peering/rds-dev-3-data-comn-dev-clusters.tfstate"
    region = "us-east-2"
  }
}

module "primary_cluster_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.1"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "eticloud-preprod"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "outshift-common-dev"
      region       = "us-east-2"
    }
  }
  accepter_vpc_name  = "nonprod-db-vpc-3-vpc"
  requester_vpc_name  = "common-dev-use2-vpc-data"
}
