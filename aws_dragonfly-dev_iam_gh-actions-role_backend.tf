terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/iam/gh-actions.tfstate"
    region = "us-east-2"
  }
}
