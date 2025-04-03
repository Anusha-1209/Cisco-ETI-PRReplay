# AWS account: eticloud
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/eticloud-plg-prod/s3/s3.tfstate"
    region = "us-east-2"
  }
}
