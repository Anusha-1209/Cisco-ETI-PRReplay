terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod" 
    key    = "terraform-state/aurora-postgres/us-east-2/ostinato-dev-1.tfstate"
    region = "us-east-2"
  }
}