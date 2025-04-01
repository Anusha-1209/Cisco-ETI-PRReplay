terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "backend/keeper/eticloud/apps/synthetica/aws-secrets-engines/aws-synthetica-dev.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
