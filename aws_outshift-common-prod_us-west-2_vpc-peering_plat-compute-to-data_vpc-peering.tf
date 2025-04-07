terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/vpc-peering/us-west-2/data-plat-prod-usw2-1.tfstate"
    region = "us-east-2"
  }
}

module "secondary_cluster_to_primary"{
  source                  = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "common" = {
      account_name = "outshift-common-prod"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "plat-prod-usw2-1"
  requester_vpc_name = "platform-prod-usw2-vpc-data"
}
