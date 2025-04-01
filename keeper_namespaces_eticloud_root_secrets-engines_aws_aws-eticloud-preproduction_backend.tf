terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "backend/keeper/ci-secret-engines/aws-eticloud-preproduction.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}