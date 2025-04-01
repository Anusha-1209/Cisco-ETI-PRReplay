terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state"
    key            = "backend/palladium-stt-serviceaccount.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
  }
}
