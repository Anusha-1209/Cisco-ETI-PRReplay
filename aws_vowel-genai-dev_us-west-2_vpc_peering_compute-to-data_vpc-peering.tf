terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/data-motific-dev-usw2-1.tfstate"
    region = "us-east-2"
  }
}

module "vpc_peering_us-east_2_eks_us_west_2_data" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-vpc-peering.git?ref=1.0.0"
  aws_account_name   = "vowel-genai-dev"
  accepter_vpc_name  = "motf-dev-use2-1"
  requester_vpc_name = "motf-dev-usw2-data"
  accepter_region    = "us-east-2"
  requester_region   = "us-west-2"
}

module "vpc_peering_vowel_dev_1_eks_us_west_2_data" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-vpc-peering.git?ref=1.0.0"
  aws_account_name   = "vowel-genai-dev"
  accepter_vpc_name  = "vowel-dev-1-vpc" # where the vowel-dev-1 EKS cluster lives
  requester_vpc_name = "motf-dev-usw2-data"
  accepter_region    = "us-east-2"
  requester_region   = "us-west-2"
}
