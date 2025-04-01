terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-sandbox"
    key            = "terraform-state/eticloud-scratch/iam/gbear-s3-ro.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}
