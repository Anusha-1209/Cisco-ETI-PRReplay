terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/us-east-2/ostinato-prod-1.tfstate"
    region = "us-east-2"
  }
}