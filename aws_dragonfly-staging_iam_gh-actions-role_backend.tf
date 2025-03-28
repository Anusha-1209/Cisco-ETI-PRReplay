terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-staging/iam/gh-actions.tfstate"
    region = "us-east-2"
  }
}
