terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/iam/gh-actions.tfstate"
    region = "us-east-2"
  }
}
