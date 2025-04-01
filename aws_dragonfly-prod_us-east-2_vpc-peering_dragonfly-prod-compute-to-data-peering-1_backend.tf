terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/vpc-peering/us-east-2/dragonfly-compute-to-data-prod-1/vpc-peering.tfstate"
    region = "us-east-2"
  }
}
