terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-production/msk/eu-central-1/dragonfly-msk-connect-1.tfstate"
    region = "us-east-2"
  }
}
