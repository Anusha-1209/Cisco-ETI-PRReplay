terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-staging/aurora-postgres/eu-west-1/rds-dragonfly-staging-1.tfstate"
    region = "us-east-2"
  }
}
