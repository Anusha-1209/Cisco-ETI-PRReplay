
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aurora-postgres/us-east-2/marvin-prod-euc1-1.tfstate"
    region = "us-east-2"
  }
}
