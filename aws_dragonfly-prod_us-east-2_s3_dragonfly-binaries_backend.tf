terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-prod/s3/dragonfly-binaries-repository.tfstate"
    region = "us-east-2"
  }
}
