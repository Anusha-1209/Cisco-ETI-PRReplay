terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-staging/os/eu-west-1/dragonfly-staging-1-osis.tfstate"
    region = "us-east-2"
  }
}
