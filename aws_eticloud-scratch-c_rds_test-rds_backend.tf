
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aurora-postgres/us-east-2/eticloud-scratch-c/test-rds.tfstate"
    region = "us-east-2"
  }
}
