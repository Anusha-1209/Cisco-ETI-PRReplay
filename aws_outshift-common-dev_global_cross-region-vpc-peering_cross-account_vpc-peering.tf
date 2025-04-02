terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/cross-account-vpc-peering/rds-dev-3-data-comn-dev-clusters.tfstate"
    region = "us-east-2"
  }
}

module "primary_cluster_to_secondary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=main"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "outshift-common-dev"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "eticloud-preprod"
      region       = "us-east-2"
    }
  }
  accepter_vpc_name  = "common-dev-use2-vpc-data"
  requester_vpc_name  = "nonprod-db-vpc-3-vpc"
}

# module "secondary_cluster_to_primary"{
#   source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
#   aws_accounts_to_regions = {
#     "accepter" = {
#       account_name = "outshift-common-dev"
#       region       = "us-west-2"
#     }
#     "requester" = {
#       account_name = "outshift-common-dev"
#       region       = "us-east-2"
#     }
#   }
#   accepter_vpc_name  = "comn-dev-usw2-1"
#   requester_vpc_name = "common-dev-use2-vpc-data"
# }