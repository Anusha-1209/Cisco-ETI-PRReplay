terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "terraform-state/securecn-prod/account/iam.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
