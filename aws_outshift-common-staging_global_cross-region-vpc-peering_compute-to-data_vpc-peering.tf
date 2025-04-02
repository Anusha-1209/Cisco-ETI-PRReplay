terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/cross-region-vpc-peering/data-comn-staging-clusters.tfstate"
    region = "us-east-2"
  }
}

module "primary_cluster_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "outshift-common-staging"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "outshift-common-staging"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "comn-staging-use2-1"
  requester_vpc_name = "common-staging-usw2-vpc-data"
}

module "secondary_cluster_to_primary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "outshift-common-staging"
      region       = "us-west-2"
    }
    "requester" = {
      account_name = "outshift-common-staging"
      region       = "us-east-2"
    }
  }
  accepter_vpc_name  = "comn-staging-usw2-1"
  requester_vpc_name = "common-staging-use2-vpc-data"
}