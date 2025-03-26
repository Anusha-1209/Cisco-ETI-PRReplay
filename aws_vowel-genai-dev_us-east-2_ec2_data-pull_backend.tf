terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc/us-east-2/ami-data-pull.tfstate"
    region = "us-east-2"
  }
}