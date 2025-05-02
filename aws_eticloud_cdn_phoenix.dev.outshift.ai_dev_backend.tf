terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/eticloud/us-east-1/cdn/phoenix.dev.outshift.ai.tfstate"
    region = "us-east-2"
  }
}
