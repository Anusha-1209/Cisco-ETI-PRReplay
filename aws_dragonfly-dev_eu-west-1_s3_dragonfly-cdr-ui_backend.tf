terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-dev/s3/dragonfly-cdr-ui.tfstate"
    region = "us-east-2"
  }
}
