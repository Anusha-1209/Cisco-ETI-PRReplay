terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-apisec-staging/msk/us-east-2/marvin-staging-1-msk.tfstate"
    region = "us-east-2"
  }
}
