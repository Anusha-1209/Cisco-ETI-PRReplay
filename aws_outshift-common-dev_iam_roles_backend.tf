terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/outshift-common-dev/iam/roles.tfstate"
    region  = "us-east-2"
  }
}