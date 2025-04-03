terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/motf-staging-usw2-data-vpc-peering.tfstate"
    region = "us-east-2"
  }
}

module "motific_staging_vpc_peering_eks_us_west_2_data" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-vpc-peering.git?ref=1.1.1"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "motific-staging"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "motific-staging"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "motf-staging-use2-1"
  requester_vpc_name = "motf-staging-usw2-data"
}
