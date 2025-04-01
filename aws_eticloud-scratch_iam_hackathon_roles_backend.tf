terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/hackathon-eticloud-scratch-iam-roles.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
