terraform {
  backend "s3" {
    bucket         = "eticloud-tf-state-nonprod"
    key            = "terraform-state/iam/us-east-2/aws-cnapp-sscs-prod.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true
  }
}