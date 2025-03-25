terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/msk/eu-central-1/dragonfly-msk-prod-eu1.tfstate"
    region = "us-east-2"
  }
}
