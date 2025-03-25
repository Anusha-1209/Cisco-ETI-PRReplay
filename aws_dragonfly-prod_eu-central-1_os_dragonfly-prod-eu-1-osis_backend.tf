terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/eu-central-1/os/dragonfly-prod-1-osis.tfstate"
    region = "us-east-2"
  }
}
