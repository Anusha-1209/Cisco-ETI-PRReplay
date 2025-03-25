terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-dragonfly-production/aurora-postgres/us-east-2/dragonfly-rds-prod-1.tfstate"
    region = "us-east-2"
  }
}
