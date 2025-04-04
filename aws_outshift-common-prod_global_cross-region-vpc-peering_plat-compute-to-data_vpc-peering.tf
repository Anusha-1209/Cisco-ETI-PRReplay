terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/cross-region-vpc-peering/data-plat-prod-clusters.tfstate"
    region = "us-east-2"
  }
}

module "primary_cluster_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "outshift-common-prod"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "outshift-common-prod"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "plat-prod-use2-1"
  requester_vpc_name = "platform-prod-usw2-vpc-data"
}

module "secondary_cluster_to_primary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "outshift-common-prod"
      region       = "us-west-2"
    }
    "requester" = {
      account_name = "outshift-common-prod"
      region       = "us-east-2"
    }
  }
  accepter_vpc_name  = "plat-prod-usw2-1"
  requester_vpc_name = "platform-prod-use2-vpc-data"
}