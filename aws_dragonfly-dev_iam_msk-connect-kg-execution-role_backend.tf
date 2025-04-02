terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/iam/msk-connect-kg-execution-role.tfstate"
    region = "us-east-2"
  }
}
