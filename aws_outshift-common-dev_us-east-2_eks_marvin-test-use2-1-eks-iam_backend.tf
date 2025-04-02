terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "terraform-state/outshift-common-dev/iam/role/marvin-dev-use2-1-custom-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
