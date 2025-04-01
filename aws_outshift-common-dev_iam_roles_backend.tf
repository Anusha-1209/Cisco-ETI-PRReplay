terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"
    key     = "terraform-state/aws-apisec-dev/iam/roles.tfstate"
    region  = "us-east-2"
  }
}
