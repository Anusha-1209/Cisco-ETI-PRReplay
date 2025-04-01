terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/great-bear-eticloud-iam-policies.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
