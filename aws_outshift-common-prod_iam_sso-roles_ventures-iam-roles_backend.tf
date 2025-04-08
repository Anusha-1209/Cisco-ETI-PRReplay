terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "terraform-state/outshift-common-prod/iam/role/teams-sso-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}