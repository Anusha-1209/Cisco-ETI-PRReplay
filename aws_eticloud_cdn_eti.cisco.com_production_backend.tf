terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/eti-cdn-cisco-prod.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
