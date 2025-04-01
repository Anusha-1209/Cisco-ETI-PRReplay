terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-dev-1/os/eu-west-1/dragonfly-dev-1-osis.tfstate"
    region = "us-east-2"
  }
}
