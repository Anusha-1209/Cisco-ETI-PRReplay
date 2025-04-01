terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/pi-dev-use2-1-motf-e2e-use2-data.tfstate"
    region = "us-east-2"
  }
}

module "vpc_peering_primary_to_primary"{
  source             = "git::https://github.com/cisco-eti/sre-tf-module-multi-region-vpc-peering.git?ref=1.1.0"
  aws_accounts_to_regions = {
    "vowel-genai-dev" = {
      account_name = "vowel-genai-dev"
      region       = "us-east-2"
    }
  }
  accepter_vpc_name  = "pi-dev-use2-1"
  requester_vpc_name = "motf-e2e-use2-data"
}
