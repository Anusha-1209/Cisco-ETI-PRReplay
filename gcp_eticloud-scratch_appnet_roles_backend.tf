terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/appnet-prassark-role.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
  }
}
