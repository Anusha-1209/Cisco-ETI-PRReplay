terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/tfstate/cdn/us-east-1/eti-identity-assets-cdn-prod.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
