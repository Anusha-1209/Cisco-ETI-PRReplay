terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-dev-1/aurora-postgres/eu-west-1/dragonfly-rds-1.tfstate"
    region = "us-east-2"
  }
}
