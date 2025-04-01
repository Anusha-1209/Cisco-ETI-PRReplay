terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/msk/us-east-2/dragonfly-msk-prod-1.tfstate"
    region = "us-east-2"
  }
}
