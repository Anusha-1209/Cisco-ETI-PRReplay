terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/securecn-eticloud-scratch-iam-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
