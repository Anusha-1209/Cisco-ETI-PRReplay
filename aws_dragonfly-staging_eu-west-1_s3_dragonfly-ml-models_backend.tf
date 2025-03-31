terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"
    key    = "terraform-state/aws/dragonfly-staging/s3/dragonfly-ml-models.tfstate"
    region = "us-east-2"
  }
}
