terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/iam/dragonfly-event-manager-role.tfstate"
    region = "us-east-2"
  }
}
