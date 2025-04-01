terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-sandbox"
    key            = "backend/meissa-eticloud-scratch-c-iam-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
