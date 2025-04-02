terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/motf-staging-usw2-rds.tfstate"
    region = "us-east-2"
  }
}
