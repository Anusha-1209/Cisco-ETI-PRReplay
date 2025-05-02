terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/outshift-common-dev/us-east-2/cdn/phoenix-ui-cdn.tfstate"
    region = "us-east-2"
  }
}
