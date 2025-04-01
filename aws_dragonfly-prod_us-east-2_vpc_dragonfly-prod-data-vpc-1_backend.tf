terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/vpc/us-east-2/dragonfly-data-prod-1-vpc.tfstate"
    region = "us-east-2"
  }
}
