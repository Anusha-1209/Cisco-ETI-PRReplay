terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"
    key     = "terraform-state/aws-apisec-prod/iam/roles.tfstate"
    region  = "us-east-2"
  }
}
