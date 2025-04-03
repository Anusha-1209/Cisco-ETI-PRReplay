terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-production/msk/us-east-2/dragonfly-msk-connect-1.tfstate"
    region = "us-east-2"
  }
}
