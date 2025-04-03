terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-dev/cdn/cdr-ui-dev.tfstate"
    region = "us-east-1"
  }
}
