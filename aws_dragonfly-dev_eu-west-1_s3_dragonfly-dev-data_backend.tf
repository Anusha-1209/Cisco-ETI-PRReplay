terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/s3/dragonfly-dev-data.tfstate"
    region = "us-east-2"
  }
}
