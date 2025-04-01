terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-staging/msk/eu-west-1/dragonfly-staging-msk-1.tfstate"
    region = "us-east-2"
  }
}
