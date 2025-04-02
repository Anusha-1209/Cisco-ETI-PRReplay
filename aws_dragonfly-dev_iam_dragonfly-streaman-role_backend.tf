terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/iam/dragonfly-streaman-role.tfstate"
    region = "us-east-2"
  }
}
