terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/eu-central-1/rds/dragonfly-rds-prod-1.tfstate"
    region = "us-east-2"
  }
}
