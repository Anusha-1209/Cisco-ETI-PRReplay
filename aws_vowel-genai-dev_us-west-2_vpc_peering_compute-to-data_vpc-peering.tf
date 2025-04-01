terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/data-motific-dev-usw2-1.tfstate"
    region = "us-east-2"
  }
}

module "vpc-peering-us-east-2-eks-us-west-2-data" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-vpc-peering.git?ref=latest"
  aws_accounts_to_regions = {
    "vowel-genai-dev" = {
      account_name = "vowel-genai-dev"
      region       = "us-west-2"
    }
  }
  accepter_vpc_name  = "motf-dev-use2-1"
  requester_vpc_name = "motf-dev-usw2-data"
}
