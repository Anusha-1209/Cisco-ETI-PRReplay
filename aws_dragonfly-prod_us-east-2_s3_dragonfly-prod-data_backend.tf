terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/s3/dragonfly-prod-data.tfstate"
    region = "us-east-2"
  }
}
