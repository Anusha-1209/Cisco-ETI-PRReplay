# AWS account: eticloud
terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"
    key     = "terraform-state/eticloud-plg-prod/iam/iam-roles.tfstate"
    region  = "us-east-2"
  }
}
