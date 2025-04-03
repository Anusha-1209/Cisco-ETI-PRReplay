terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/dragonfly-staging/s3/dragonfly-staging-data.tfstate"
    region = "us-east-2"
  }
}
