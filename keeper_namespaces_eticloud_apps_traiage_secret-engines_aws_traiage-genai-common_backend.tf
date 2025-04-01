terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "backend/keeper/eticloud/apps/traiage/aws-secrets-engines/aws-genai-common.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
