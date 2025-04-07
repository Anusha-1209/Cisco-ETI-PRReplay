terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/iam/codeartifact-access.tfstate"
    region = "us-east-2"
  }
}
