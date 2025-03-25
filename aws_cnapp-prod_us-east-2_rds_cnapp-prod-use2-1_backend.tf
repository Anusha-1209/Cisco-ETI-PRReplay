
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/eu-west-1/rds-cnapp-prod-use2-1.tfstate"
    region = "us-east-2"
  }
}