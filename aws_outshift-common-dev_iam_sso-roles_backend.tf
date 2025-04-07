terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-dev"
    key            = "terraform-state/outshift-common-dev/iam/role/sso-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
