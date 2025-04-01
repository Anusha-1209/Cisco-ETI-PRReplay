terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/os/us-east-2/dragonfly-prod-1-osis.tfstate"
    region = "us-east-2"
  }
}
