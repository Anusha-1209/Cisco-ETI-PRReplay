terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/cross-account-vpc-peering/rds-dev-3-data-comn-dev-clusters.tfstate"
    region = "us-east-2"
  }
}

# module "primary_cluster_to_secondary"{
#   source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
#   aws_accounts_to_regions = {
#     "accepter" = {
#       account_name = "eticloud-preprod"
#       region       = "us-east-2"
#     }
#     "requester" = {
#       account_name = "outshift-common-dev"
#       region       = "us-east-2"
#     }
#   }
#   accepter_vpc_name  = "nonprod-db-vpc-3-vpc"
#   requester_vpc_name  = "common-dev-use2-vpc-data"
# }

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

// Creates a peering between VPCs different accounts and different regions
module "multi_account_multi_region" {
  source = "grem11n/vpc-peering/aws//examples/multi-account-multi-region"

  providers = {
    aws.this = aws.this
    aws.peer = aws.peer
  }

  this_vpc_id = "vpc-0c082861f90a7bd11"
  peer_vpc_id = "vpc-08cf360be9a13ba25"

  auto_accept_peering = true

  tags = {
    Name        = "tf-multi-account-multi-region"
    Environment = "Test"
  }
}