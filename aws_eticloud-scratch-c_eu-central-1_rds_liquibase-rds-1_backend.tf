terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/eticloud-scratch-c/eu-central-1/rds/liquibase-rds-1.tfstate"
    region = "us-east-2"
  }
}
