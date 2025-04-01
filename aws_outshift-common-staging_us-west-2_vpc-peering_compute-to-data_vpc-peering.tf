terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-west-2/data-comn-staging-usw2-1.tfstate"
    region = "us-east-2"
  }
}

module "sre_tf_module_multi_region_vpc_peering" {
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering"
  aws_account_name   = "outshift-common-staging"
  accepter_vpc_name  = "comn-staging-usw2-1"
  requester_vpc_name = "common-staging-vpc-data"
  accepter_region    = "us-west-2"
  requester_region   = "us-east-2"
}
