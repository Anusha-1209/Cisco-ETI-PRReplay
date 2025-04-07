terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/websites-eticloud-iam-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
