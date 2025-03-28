terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-prod/eu-central-1/s3/dragonfly-binaries-repository.tfstate"
    region = "us-east-2"
  }
}
