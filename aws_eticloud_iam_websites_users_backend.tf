terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "backend/eti-websites-eticloud-iam-users.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
