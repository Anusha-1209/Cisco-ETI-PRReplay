terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/vpc/us-east-2/motf-prod-usw2-data-vpc-peering.tfstate"
    region = "us-east-2"
  }
}

module "motific_prod_vpc_peering_eks_us_west_2_data" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-vpc-peering.git?ref=1.1.1"
  aws_accounts_to_regions = {
    "accepter" = {
      account_name = "motific-prod"
      region       = "us-east-2"
    }
    "requester" = {
      account_name = "motific-prod"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "motf-prod-use2-1"
  requester_vpc_name = "motf-prod-usw2-data"
}
