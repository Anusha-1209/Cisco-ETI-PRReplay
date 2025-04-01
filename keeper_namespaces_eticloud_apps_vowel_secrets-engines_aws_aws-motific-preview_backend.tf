terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-prod"
    key            = "backend/keeper/eticloud/apps/vowel/secret-engines/aws/motific-preview.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}